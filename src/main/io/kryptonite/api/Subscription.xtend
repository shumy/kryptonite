package io.kryptonite.api

import com.fasterxml.jackson.databind.node.ArrayNode
import io.kryptonite.api.dto.Candle
import io.kryptonite.api.dto.Ticker
import java.time.LocalDateTime
import java.time.format.DateTimeFormatter

class Subscription<DTO> {
  static val formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd'T'HH:mm:ss.SSSX")
  
  val Exchanger ex
  val (ArrayNode)=>DTO processor
  
  var DTO lastDto = null 
  var (DTO)=>void onMessage = null
  
  public val Class<DTO> type
  public val Long id
  
  //processors...
  val (ArrayNode)=>DTO parseTicker = [
    new Ticker(
      get(6).asDouble,
      get(0).asDouble,
      get(2).asDouble,
      
      get(7).asDouble,
      get(8).asDouble,
      get(9).asDouble
    ) as DTO
  ]
  
  val (ArrayNode)=>DTO parseCandle = [
    val timeTxt = get(0).asText
    
    new Candle(
      LocalDateTime.parse(timeTxt, formatter),
      
      get(1).asDouble,
      get(2).asDouble,
      
      get(3).asDouble,
      get(4).asDouble,
      
      get(5).asDouble
    ) as DTO
  ]
  
  new(Exchanger ex, Class<DTO> type, Long id) {
    this.ex = ex
    this.type = type
    this.id = id
    
    this.processor = switch(type) {
      case Ticker: parseTicker
      case Candle: parseCandle
    }
  }
  
  package def void message(ArrayNode msg) {
    if (type === Candle && lastDto === null) {
      val time = LocalDateTime.parse("1900-01-01T00:00:00.000Z", formatter)
      lastDto = new Candle(time, 0.0, 0.0, 0.0, 0.0, 0.0) as DTO
      return
    }
    
    val dto = processor.apply(msg)
    if (type === Candle && (dto as Candle).time < (lastDto as Candle).time)
      return;
    
    lastDto = dto
    onMessage?.apply(lastDto)
  }
  
  package def void heartbeating() {
    //println("Heartbeating on: " + id)
  }
  
  def void close() {
    ex.subscriptions.remove(id)
    ex.adapter.send(#{ "event" -> "unsubscribe", "chanId" -> id })
  }
  
  def void onMessage((DTO)=>void onMessage) {
    this.onMessage = onMessage
  }
}