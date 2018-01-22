package io.kryptonite.api

import com.fasterxml.jackson.databind.JsonNode
import com.fasterxml.jackson.databind.node.ArrayNode
import io.kryptonite.adapter.IAdapter
import io.kryptonite.api.async.Promise
import io.kryptonite.api.dto.Candle
import io.kryptonite.api.dto.Ticker
import java.util.concurrent.ConcurrentHashMap
import java.util.concurrent.Executors
import java.util.concurrent.TimeUnit

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
}