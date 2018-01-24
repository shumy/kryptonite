package io.kryptonite.db

import io.kryptonite.api.dto.Candle
import java.util.List
import org.slf4j.LoggerFactory
import java.time.ZoneId
import java.time.LocalDateTime
import java.time.format.DateTimeFormatter

class ModelService {
  static val logger = LoggerFactory.getLogger(ModelService)
  static val formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss")
  
  static val CANDLE_COUNTS = '''MATCH (c:«Candle.simpleName») RETURN count(c) as n''' 
  
  val db = new NeoDB("data", false)
  
  new () {
    db.cypher('''CREATE INDEX ON :«Candle.simpleName»(stamp)''')
  }
  
  def saveCandles(String pair, List<Candle> candles) {
    val input = db.cypher(CANDLE_COUNTS).head.get('n') as Long
    db.tx[
      candles.forEach[
        db.cypher('''
          MERGE (c:«Candle.simpleName» { pair: "«pair»", stamp: $stamp })
          ON CREATE SET
            c.open = $open,
            c.close = $close,
            c.high = $high,
            c.low = $low,
            c.volume = $volume
        ''', toMap)
      ]
    ]
    
    val output = db.cypher(CANDLE_COUNTS).head.get('n') as Long
    logger.info("INSERTED (Candles): {}", output - input)
    return output - input
  }
  
  def List<Candle> getCandles(String pair, String start, Integer size) {
    val startSrt = if (start.split(" ").length === 1) start + " 00:00:00" else start
    
    val mStart = timeToMillis(startSrt)
    val mEnd = mStart + 60000 * (size -1)
    
    val res = db.cypher('''
      MATCH (c:«Candle.simpleName» { pair: "«pair»" })
      WHERE c.stamp IN range(«mStart», «mEnd»)
      RETURN c.stamp as stamp, c.open as open, c.close as close, c.high as high, c.low as low, c.volume as volume
      ORDER BY stamp
    ''').toList
    
    logger.info("RETURNED (Candles): {}", res.size)
    return res.map[ Candle.fromMap(it) ]
  }
  
  private def timeToMillis(String timeStr) {
    val time = LocalDateTime.parse(timeStr, formatter)
    return time.atZone(ZoneId.systemDefault).toInstant.toEpochMilli
  }
}