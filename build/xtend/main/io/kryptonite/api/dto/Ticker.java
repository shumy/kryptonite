package io.kryptonite.api.dto;

import java.time.Instant;
import java.time.LocalDateTime;
import java.time.ZoneId;
import java.util.Collections;
import java.util.Map;
import org.eclipse.xtend2.lib.StringConcatenation;
import org.eclipse.xtext.xbase.lib.CollectionLiterals;
import org.eclipse.xtext.xbase.lib.Pair;

@SuppressWarnings("all")
public class Ticker {
  public final Long stamp;
  
  public final Double price;
  
  public final Double bid;
  
  public final Double ask;
  
  public final Double high;
  
  public final Double low;
  
  public final Double volume;
  
  public LocalDateTime getTimestamp() {
    return Instant.ofEpochMilli((this.stamp).longValue()).atZone(ZoneId.systemDefault()).toLocalDateTime();
  }
  
  public Ticker(final LocalDateTime timestamp, final Double price, final Double bid, final Double ask, final Double high, final Double low, final Double volume) {
    this.stamp = Long.valueOf(timestamp.atZone(ZoneId.systemDefault()).toInstant().toEpochMilli());
    this.price = price;
    this.bid = bid;
    this.ask = ask;
    this.high = high;
    this.low = low;
    this.volume = volume;
  }
  
  public Ticker(final Long millis, final Double price, final Double bid, final Double ask, final Double high, final Double low, final Double volume) {
    this.stamp = millis;
    this.price = price;
    this.bid = bid;
    this.ask = ask;
    this.high = high;
    this.low = low;
    this.volume = volume;
  }
  
  public Map<String, Object> toMap() {
    Pair<String, Long> _mappedTo = Pair.<String, Long>of("stamp", this.stamp);
    Pair<String, Double> _mappedTo_1 = Pair.<String, Double>of("price", this.price);
    Pair<String, Double> _mappedTo_2 = Pair.<String, Double>of("bid", this.bid);
    Pair<String, Double> _mappedTo_3 = Pair.<String, Double>of("ask", this.ask);
    Pair<String, Double> _mappedTo_4 = Pair.<String, Double>of("high", this.high);
    Pair<String, Double> _mappedTo_5 = Pair.<String, Double>of("low", this.low);
    Pair<String, Double> _mappedTo_6 = Pair.<String, Double>of("volume", this.volume);
    return Collections.<String, Object>unmodifiableMap(CollectionLiterals.<String, Object>newHashMap(_mappedTo, _mappedTo_1, _mappedTo_2, _mappedTo_3, _mappedTo_4, _mappedTo_5, _mappedTo_6));
  }
  
  public static Ticker fromMap(final Map<String, Object> obj) {
    Object _get = obj.get("stamp");
    Object _get_1 = obj.get("price");
    Object _get_2 = obj.get("bid");
    Object _get_3 = obj.get("ask");
    Object _get_4 = obj.get("high");
    Object _get_5 = obj.get("low");
    Object _get_6 = obj.get("volume");
    return new Ticker(
      ((Long) _get), 
      ((Double) _get_1), 
      ((Double) _get_2), 
      ((Double) _get_3), 
      ((Double) _get_4), 
      ((Double) _get_5), 
      ((Double) _get_6));
  }
  
  @Override
  public String toString() {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("TICKER (ts=");
    LocalDateTime _timestamp = this.getTimestamp();
    _builder.append(_timestamp);
    _builder.append(", price=");
    _builder.append(this.price);
    _builder.append(", bid=");
    _builder.append(this.bid);
    _builder.append(", ask=");
    _builder.append(this.ask);
    _builder.append(", high=");
    _builder.append(this.high);
    _builder.append(", low=");
    _builder.append(this.low);
    _builder.append(", vol=");
    _builder.append(this.volume);
    _builder.append(")");
    return _builder.toString();
  }
}
