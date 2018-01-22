package io.kryptonite.api.dto

import java.time.LocalDateTime
import org.eclipse.xtend.lib.annotations.Data

@Data
class Ticker {
  public val time = LocalDateTime.now
  
  public val Double price
  public val Double bid
  public val Double ask
  
  public val Double volume
  public val Double high
  public val Double low
}