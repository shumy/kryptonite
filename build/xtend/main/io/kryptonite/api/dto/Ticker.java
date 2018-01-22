package io.kryptonite.api.dto;

import java.time.LocalDateTime;
import org.eclipse.xtend.lib.annotations.Data;
import org.eclipse.xtext.xbase.lib.Pure;
import org.eclipse.xtext.xbase.lib.util.ToStringBuilder;

@Data
@SuppressWarnings("all")
public class Ticker {
  public final LocalDateTime time = LocalDateTime.now();
  
  public final Double price;
  
  public final Double bid;
  
  public final Double ask;
  
  public final Double volume;
  
  public final Double high;
  
  public final Double low;
  
  public Ticker(final Double price, final Double bid, final Double ask, final Double volume, final Double high, final Double low) {
    super();
    this.price = price;
    this.bid = bid;
    this.ask = ask;
    this.volume = volume;
    this.high = high;
    this.low = low;
  }
  
  @Override
  @Pure
  public int hashCode() {
    final int prime = 31;
    int result = 1;
    result = prime * result + ((this.time== null) ? 0 : this.time.hashCode());
    result = prime * result + ((this.price== null) ? 0 : this.price.hashCode());
    result = prime * result + ((this.bid== null) ? 0 : this.bid.hashCode());
    result = prime * result + ((this.ask== null) ? 0 : this.ask.hashCode());
    result = prime * result + ((this.volume== null) ? 0 : this.volume.hashCode());
    result = prime * result + ((this.high== null) ? 0 : this.high.hashCode());
    result = prime * result + ((this.low== null) ? 0 : this.low.hashCode());
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
    if (this.time == null) {
      if (other.time != null)
        return false;
    } else if (!this.time.equals(other.time))
      return false;
    if (this.price == null) {
      if (other.price != null)
        return false;
    } else if (!this.price.equals(other.price))
      return false;
    if (this.bid == null) {
      if (other.bid != null)
        return false;
    } else if (!this.bid.equals(other.bid))
      return false;
    if (this.ask == null) {
      if (other.ask != null)
        return false;
    } else if (!this.ask.equals(other.ask))
      return false;
    if (this.volume == null) {
      if (other.volume != null)
        return false;
    } else if (!this.volume.equals(other.volume))
      return false;
    if (this.high == null) {
      if (other.high != null)
        return false;
    } else if (!this.high.equals(other.high))
      return false;
    if (this.low == null) {
      if (other.low != null)
        return false;
    } else if (!this.low.equals(other.low))
      return false;
    return true;
  }
  
  @Override
  @Pure
  public String toString() {
    ToStringBuilder b = new ToStringBuilder(this);
    b.add("time", this.time);
    b.add("price", this.price);
    b.add("bid", this.bid);
    b.add("ask", this.ask);
    b.add("volume", this.volume);
    b.add("high", this.high);
    b.add("low", this.low);
    return b.toString();
  }
  
  @Pure
  public LocalDateTime getTime() {
    return this.time;
  }
  
  @Pure
  public Double getPrice() {
    return this.price;
  }
  
  @Pure
  public Double getBid() {
    return this.bid;
  }
  
  @Pure
  public Double getAsk() {
    return this.ask;
  }
  
  @Pure
  public Double getVolume() {
    return this.volume;
  }
  
  @Pure
  public Double getHigh() {
    return this.high;
  }
  
  @Pure
  public Double getLow() {
    return this.low;
  }
}
