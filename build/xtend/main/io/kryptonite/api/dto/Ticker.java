package io.kryptonite.api.dto;

import java.time.LocalDateTime;
import org.eclipse.xtend.lib.annotations.Data;
import org.eclipse.xtext.xbase.lib.Pure;
import org.eclipse.xtext.xbase.lib.util.ToStringBuilder;

@Data
@SuppressWarnings("all")
public class Ticker {
  public final LocalDateTime timestamp;
  
  public final double volume;
  
  public final double open;
  
  public final double high;
  
  public final double low;
  
  public final double close;
  
  public Ticker(final LocalDateTime timestamp, final double volume, final double open, final double high, final double low, final double close) {
    super();
    this.timestamp = timestamp;
    this.volume = volume;
    this.open = open;
    this.high = high;
    this.low = low;
    this.close = close;
  }
  
  @Override
  @Pure
  public int hashCode() {
    final int prime = 31;
    int result = 1;
    result = prime * result + ((this.timestamp== null) ? 0 : this.timestamp.hashCode());
    result = prime * result + (int) (Double.doubleToLongBits(this.volume) ^ (Double.doubleToLongBits(this.volume) >>> 32));
    result = prime * result + (int) (Double.doubleToLongBits(this.open) ^ (Double.doubleToLongBits(this.open) >>> 32));
    result = prime * result + (int) (Double.doubleToLongBits(this.high) ^ (Double.doubleToLongBits(this.high) >>> 32));
    result = prime * result + (int) (Double.doubleToLongBits(this.low) ^ (Double.doubleToLongBits(this.low) >>> 32));
    result = prime * result + (int) (Double.doubleToLongBits(this.close) ^ (Double.doubleToLongBits(this.close) >>> 32));
    return result;
  }
  
  @Override
  @Pure
  public boolean equals(final Object obj) {
    if (this == obj)
      return true;
    if (obj == null)
      return false;
    if (getClass() != obj.getClass())
      return false;
    Ticker other = (Ticker) obj;
    if (this.timestamp == null) {
      if (other.timestamp != null)
        return false;
    } else if (!this.timestamp.equals(other.timestamp))
      return false;
    if (Double.doubleToLongBits(other.volume) != Double.doubleToLongBits(this.volume))
      return false; 
    if (Double.doubleToLongBits(other.open) != Double.doubleToLongBits(this.open))
      return false; 
    if (Double.doubleToLongBits(other.high) != Double.doubleToLongBits(this.high))
      return false; 
    if (Double.doubleToLongBits(other.low) != Double.doubleToLongBits(this.low))
      return false; 
    if (Double.doubleToLongBits(other.close) != Double.doubleToLongBits(this.close))
      return false; 
    return true;
  }
  
  @Override
  @Pure
  public String toString() {
    ToStringBuilder b = new ToStringBuilder(this);
    b.add("timestamp", this.timestamp);
    b.add("volume", this.volume);
    b.add("open", this.open);
    b.add("high", this.high);
    b.add("low", this.low);
    b.add("close", this.close);
    return b.toString();
  }
  
  @Pure
  public LocalDateTime getTimestamp() {
    return this.timestamp;
  }
  
  @Pure
  public double getVolume() {
    return this.volume;
  }
  
  @Pure
  public double getOpen() {
    return this.open;
  }
  
  @Pure
  public double getHigh() {
    return this.high;
  }
  
  @Pure
  public double getLow() {
    return this.low;
  }
  
  @Pure
  public double getClose() {
    return this.close;
  }
}
