package io.kryptonite.api.dto

import org.eclipse.xtend.lib.annotations.Data
import java.time.LocalDateTime

@Data
class Candle {
  public val LocalDateTime time       //time-stamp
  
  public val Double open              //First execution during the time frame
  public val Double close             //Last execution during the time frame
  
  public val Double high              //Highest execution during the time frame
  public val Double low               //Lowest execution during the timeframe
  
  public val Double volume            //Quantity of symbol traded within the timeframe
}