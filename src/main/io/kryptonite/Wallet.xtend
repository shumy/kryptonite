package io.kryptonite

import io.kryptonite.adapter.Bitfinex
import io.kryptonite.api.Exchanger
import io.kryptonite.trader.SimulationTrader

import javafx.application.Application
import javafx.stage.Stage
import javafx.scene.Scene
import javafx.scene.layout.FlowPane

class Wallet extends Application {
  var double balance = 100
  
  override start(Stage stage) throws Exception {
    val clt = new Exchanger(new Bitfinex)
    val sim = new SimulationTrader(this, clt, 100)
    
    val root = new FlowPane => [
      
    ]
    
    stage => [
      title = "Kryptonite"
      scene = new Scene(root, 1200, 800)
      show
    ]
  }
  
  def void log(String msg) {
    println(msg)
  }
}