package io.kryptonite.api

import com.fasterxml.jackson.databind.JsonNode
import com.fasterxml.jackson.databind.node.ArrayNode
import io.kryptonite.adapter.IAdapter
import io.kryptonite.api.async.Promise
import io.kryptonite.api.dto.Candle
import io.kryptonite.api.dto.Ticker
import java.time.LocalDateTime
import java.time.ZoneId
import java.util.LinkedList
import java.util.List
import java.util.concurrent.ConcurrentHashMap
import java.util.concurrent.Executors
import java.util.concurrent.TimeUnit
import java.util.Collections

class Exchanger {
  package val IAdapter adapter
  
  val executor = Executors.newSingleThreadScheduledExecutor
  val listeners = new ConcurrentHashMap<String, (JsonNode)=>void>
  
  package val subscriptions = new ConcurrentHashMap<Long, Subscription<?>>
  
  new(IAdapter adapter) {
    this.adapter = adapter
    adapter.onMessage[
      val evt = get("event")
      if (evt !== null) {
        val rpl = listeners.remove(evt.asText)
        rpl?.apply(it)
        return
      }
      
      //process subscription event...
      if (array) {
        val chanId = get(0).asLong
        val value = get(1)
        
        val sub = subscriptions.get(chanId)
        if (value.array)
          sub.message(value as ArrayNode)
        else if (value.asText == "hb")
          sub.heartbeating
      }
      
    ]
  }
  
  package def void listener(String id, (JsonNode)=>void onReply) {
   listeners.put(id, onReply)
   
   executor.schedule([
      listeners.remove(id)
      //rpl?.apply(new JsonNode)
      return null
    ], 5, TimeUnit.SECONDS)
  }
  
  def <DTO> Promise<Subscription<DTO>> subscribe(Class<DTO> type, String symbol) {
    new Promise<Subscription<DTO>>[
      listener("subscribed")[ rpl |
        val chanId = rpl.get("chanId").asLong
        
        val sub = new Subscription<DTO>(this, type, chanId)
        subscriptions.put(chanId, sub)
        
        resolve(sub)
      ]
      
      switch(type) {
        case Ticker: adapter.send(#{ "event" -> "subscribe", "channel" -> "ticker", "symbol" -> symbol }) 
        case Candle: adapter.send(#{ "event" -> "subscribe", "channel" -> "candles", "key" -> "trade:" + symbol })
      }
    ]
  }
  
  def List<Candle> getDayHistory(String pair, String date) {
    val split = date.split("-")
    val year = Integer.parseInt(split.get(0))
    val month = Integer.parseInt(split.get(1))
    val day = Integer.parseInt(split.get(2))
    
    val start = LocalDateTime.of(year, month, day, 0, 0, 0)
    val startMillis = start.atZone(ZoneId.systemDefault).toInstant.toEpochMilli
    
    val res1 = adapter.get('''/candles/trade:1m:t«pair»/hist''', #{
      "limit" -> "1000",
      "start" -> ""+ startMillis,
      //"stop" -> ""+ (startMillis + 1000*60),
      "sort" -> "1"
    })
    
    if (res1 === null || res1.empty)
      return Collections.EMPTY_LIST
    
    val newStartMillis = res1.last.get(0).asLong + 60000
    val res2 = adapter.get('''/candles/trade:1m:t«pair»/hist''', #{
      "limit" -> "440",
      "start" -> "" + newStartMillis,
      //"stop" -> "" + (newStartMillis + 440*60),
      "sort" -> "1"
    })
    
    if (res2 === null || res2.empty)
      return Collections.EMPTY_LIST
    
    
    val res = new LinkedList<JsonNode> => [
      addAll(res1)
      addAll(res2)
    ]
    
    return res.map[
      new Candle(
        get(0).asLong / 1000,
        
        get(1).asDouble,
        get(2).asDouble,
        
        get(3).asDouble,
        get(4).asDouble,
        
        get(5).asDouble
      )
    ].toList
  }
}