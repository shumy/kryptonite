package io.kryptonite.api

import com.fasterxml.jackson.databind.JsonNode
import com.fasterxml.jackson.databind.node.ArrayNode
import org.eclipse.xtend.lib.annotations.FinalFieldsConstructor

@FinalFieldsConstructor
class Subscription {  
  val Exchanger ex
  
  public val String type
  public val Long id
  
  package def void message(ArrayNode msg) {
    println("VALUE: " + msg)
  }
  
  package def void heartbeating() {
    println("Heartbeating on: " + id)
  }
  
  def void close() {
    ex.subscriptions.remove(id)
    ex.adapter.send(#{ "event" -> "unsubscribe", "chanId" -> id })
  }
  
  def void onMessage((JsonNode)=>void onMessage) {
    
  }
}