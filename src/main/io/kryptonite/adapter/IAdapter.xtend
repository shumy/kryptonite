package io.kryptonite.adapter

import com.fasterxml.jackson.databind.JsonNode
import java.util.Map

interface IAdapter {
  def void send(JsonNode msg)
  def void send(Map<String, ?> msg)
  
  def void onMessage((JsonNode)=>void onMessage)
}