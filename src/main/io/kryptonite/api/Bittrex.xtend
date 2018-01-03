package io.kryptonite.api

import com.fasterxml.jackson.databind.ObjectMapper
import io.kryptonite.api.dto.Ticker
import java.time.LocalDateTime
import java.time.format.DateTimeFormatter
import okhttp3.OkHttpClient
import okhttp3.Request
import org.slf4j.LoggerFactory

class Bittrex {
  static val logger = LoggerFactory.getLogger(Bittrex)
  
  val formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd'T'HH:mm:ss")
  val mapper = new ObjectMapper
   
  val client = new OkHttpClient
  val baseUrl = "https://bittrex.com/Api/v2.0/"
  
  def getTicker(CurrencyPair pair, String tickInterval) {
    val request = new Request.Builder()
      .url('''«baseUrl»pub/market/GetLatestTick?marketName=«pair.c1»-«pair.c2»&tickInterval=«tickInterval»''')
      .build
    
    val response = client.newCall(request).execute
    val value = response.body.string
    logger.debug(value)
    
    val obj = mapper.readTree(value)
    if (obj.get("success") == false)
      throw new RuntimeException("Error in getTicker -> " + obj.get("message"))
    
    val result = obj.get("result").get(0)
    
    return new Ticker(
      LocalDateTime.parse(result.get("T").asText, formatter),
      result.get("V").asDouble,
      result.get("O").asDouble,
      result.get("H").asDouble,
      result.get("L").asDouble,
      result.get("C").asDouble
    )
  }
}