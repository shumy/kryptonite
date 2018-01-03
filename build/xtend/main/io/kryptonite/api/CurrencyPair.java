package io.kryptonite.api;

import org.eclipse.xtend.lib.annotations.FinalFieldsConstructor;

@FinalFieldsConstructor
@SuppressWarnings("all")
public class CurrencyPair {
  public final String c1;
  
  public final String c2;
  
  public CurrencyPair(final String c1, final String c2) {
    super();
    this.c1 = c1;
    this.c2 = c2;
  }
}
