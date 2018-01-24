package io.kryptonite.api.dto

import java.time.Instant
import java.time.LocalDateTime
import java.time.ZoneId
import java.util.Map

class Ticker {
  public val Long stamp
  
  public val Double price
  public val Double bid
  public val Double ask
  
  public val Double high
  public val Double low
  
  public val Double volume
  
  def getTimestamp() { Instant.ofEpochMilli(stamp).atZone(ZoneId.systemDefault).toLocalDateTime }
  
  new (LocalDateTime timestamp, Double price, Double bid, Double ask, Double high, Double low, Double volume) {
    this.stamp = timestamp.atZone(ZoneId.systemDefault).toInstant.toEpochMilli
    
    this.price = price
    this.bid = bid
    this.ask = ask
    
    this.high = high
    this.low = low
    
    this.volume = volume
  }
  
  new (Long millis, Double price, Double bid, Double ask, Double high, Double low, Double volume) {
    this.stamp = millis
    
    this.price = price
    this.bid = bid
    this.ask = ask
    
    this.high = high
    this.low = low
    
    this.volume = volume
  }
  
  def Map<String, Object> toMap() {
    #{
      "stamp" -> stamp,
      
      "price" -> price,
      "bid" -> bid,
      "ask" -> ask,
      
      "high" -> high,
      "low" -> low,
      
      "volume" -> volume
    }
  }
  
  static def Ticker fromMap(Map<String, Object> obj) {
    new Ticker(
      obj.get("stamp") as Long,
      obj.get("price") as Double,
      obj.get("bid") as Double,
      obj.get("ask") as Double,
      obj.get("high") as Double,
      obj.get("low") as Double,
      obj.get("volume") as Double
    )
  }
  
  override toString()
    '''TICKER (ts=«timestamp», price=«price», bid=«bid», ask=«ask», high=«high», low=«low», vol=«volume»)'''
}