package io.kryptonite.trader

import io.kryptonite.api.dto.Ticker

interface ITrader {
  def void process(Ticker current, long deltaTime)
}