package io.kryptonite.trader

import io.kryptonite.Wallet
import io.kryptonite.api.Exchanger
import io.kryptonite.api.dto.Ticker
import java.time.temporal.ChronoUnit

class SimulationTrader implements ITrader {
  val Wallet wallet
  val Exchanger clt
  
  var Ticker last = null
  
  var double momentum = 0.0
  var double acum = 0.0
  
  //wall values...
  var double wallPrice = 0.0
  
  var in = false
  var double atPrice = 0
  
  //stop loss...
  var double trail = 0.0
  var double stop = 0.0
  
  var double balance
  
  new(Wallet wallet, Exchanger clt, double balance) {
    this.wallet = wallet
    this.clt = clt
    this.balance = balance
    
    clt.subscribe(Ticker, "tXRPUSD").then[
      println("Subscribed to XRPUSD")
      onMessage[
        if (last === null) {
          wallet.log('''INIT-PRICE: «price»''')
          last = it
          return
        }
        
        val deltaTime = last.time.until(time, ChronoUnit.SECONDS)
        if (deltaTime === 0) return;
        
        process(it, deltaTime)
        last = it
      ]
    ]
  }
  
  override process(Ticker current, long deltaTime) {
    val deltaPrice = 100 * current.price/last.price - 100
    val dp_dt = 100 * deltaPrice / deltaTime
    
    //calculate trailing stop...
    trail = current.price * 0.99
    if (trail > stop)
      stop = trail //change per dp/dt!
    
    acum += dp_dt
    momentum += Math.abs(dp_dt * 10)
    momentum /= deltaTime
    
    wallet.log('''TICK: (time=«current.time», dt=«deltaTime»s, dp=«deltaPrice»%, stop=«stop») -> «current.price»''')
    wallet.log('''  (dp/dt=«dp_dt», acum=«acum», mom=«momentum»)''')
    
    if (acum < -2 || acum > 6)
      sell(current.price)
    
    if (acum < -6)
      buy(current.price)
    
    if (momentum < 0.03) {
      //buy and sell at walls...
      if (acum < -1)
        buy(current.price)
      //else if (acum > 2) //if (current.price > 1.02 * atPrice)
      //  sell(current.price)
      
      val wallDp = 100 * current.price/wallPrice - 100
      wallet.log('''  WALL-«IF acum >0»UP«ELSE»DOWN«ENDIF» (last=«wallPrice», current=«current.price», dp=«wallDp»%)''')
      
      wallPrice = current.price
      if (!in)
        acum = 0.0
    }
    
    //buy and sell signals...
    /*if (!in && dp_dt > 0.5) {
      in = true
      
      atPrice = current.price
      stop = trail
      wallet.log('''BUY (price=«atPrice», stop=«stop»)''')
    }
    
    if (in && current.price < stop) {
      in = false
      
      val perc = (current.price/atPrice)
      balance *= perc
      wallet.log('''SELL (buy=«atPrice», sell=«current.price», perc=«perc - 1», balance=«balance»)''')
    }*/
  }
  
  def void buy(double price) {
    if (!in) {
      in = true
      acum = 0.0
      
      atPrice = price
      stop = trail
      wallet.log('''  BUY (price=«atPrice», stop=«stop»)''')
    }
  }
  
  def void sell(double price) {
    if (in) {
      in = false
      acum = 0.0
      
      val perc = (price/atPrice)
      balance *= perc
      wallet.log('''  SELL (buy=«atPrice», sell=«price», perc=«perc - 1», balance=«balance»)''')
    }
  }
}