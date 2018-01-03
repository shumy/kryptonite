package io.kryptonite.api.dto

import org.eclipse.xtend.lib.annotations.Data
import java.time.LocalDateTime

@Data
class Ticker {
  public val LocalDateTime timestamp
  public val double volume 
  
  public val double open
  public val double high
  public val double low
  public val double close
  
  
}