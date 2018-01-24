package io.kryptonite.api.dto

import java.time.Instant
import java.time.LocalDateTime
import java.time.ZoneId
import java.util.Map

class Candle {
  public val Long stamp               //time-stamp
  
  public val Double open              //First execution during the time frame
  public val Double close             //Last execution during the time frame
  
  public val Double high              //Highest execution during the time frame
  public val Double low               //Lowest execution during the timeframe
  
  public val Double volume            //Quantity of symbol traded within the timeframe
  
  def getTimestamp() { Instant.ofEpochMilli(stamp * 1000).atZone(ZoneId.systemDefault).toLocalDateTime }
  
  new (LocalDateTime timestamp, Double open, Double close, Double high, Double low, Double volume) {
    this.stamp = timestamp.atZone(ZoneId.systemDefault).toInstant.toEpochMilli / 1000
    
    this.open = open
    this.close = close
    
    this.high = high
    this.low = low
    
    this.volume = volume
  }
  
  new(Long millis, Double open, Double close, Double high, Double low, Double volume) {
    this.stamp = millis
    
    this.open = open
    this.close = close
    
    this.high = high
    this.low = low
    
    this.volume = volume
  }
  
  def Map<String, Object> toMap() {
    #{
      "stamp" -> stamp,
      
      "open" -> open,
      "close" -> close,
      
      "high" -> high,
      "low" -> low,
      
      "volume" -> volume
    }
  }
  
  static def Candle fromMap(Map<String, Object> obj) {
    new Candle(
      obj.get("stamp") as Long,
      obj.get("open") as Double,
      obj.get("close") as Double,
      obj.get("high") as Double,
      obj.get("low") as Double,
      obj.get("volume") as Double
    )
  }
  
  override toString()
    '''CANDLE (ts=«timestamp», open=«open», close=«close», high=«high», low=«low», vol=«volume»)'''
}