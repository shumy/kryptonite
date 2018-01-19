package io.kryptonite.adapter

import com.fasterxml.jackson.databind.JsonNode
import com.fasterxml.jackson.databind.ObjectMapper
import java.net.URI
import java.util.Map
import org.java_websocket.client.WebSocketClient
import org.java_websocket.handshake.ServerHandshake

class Bitfinex implements IAdapter {
  val mapper = new ObjectMapper
  val url = new URI("wss://api.bitfinex.com/ws/2")
  
  val WebSocketClient ws
  
  var (JsonNode)=>void onMessage = null
  
  new() {
    ws = new WebSocketClient(url) {
      override onOpen(ServerHandshake handshakedata) {
        println("OPEN: " + handshakedata.httpStatus)
        send(#{ "event" -> "conf", "flags" -> 32 }) //Enable all times as date strings.
      }
      
      override onMessage(String txtMsg) {
        println("RECEIVED: " + txtMsg)
        val msg = mapper.readTree(txtMsg)
        
        if (!process(msg))
          onMessage?.apply(msg)
      }
      
      override onClose(int code, String reason, boolean remote) {
        println("CLOSED: " + reason)
        
        //TODO: reconnect?
      }
      
      override onError(Exception ex) {
        println("ERROR: " + ex.message)
        ex.printStackTrace
      }
    }
    
    ws.connectBlocking
  }
  
  private def boolean process(JsonNode msg) {
    val evt = msg.get("event")
    if (evt !== null)
      switch (evt.asText) {
        case "info": return msg.processInfo
        case "conf": return msg.processConf
      }
    
    return false
  }
  
  private def boolean processInfo(JsonNode msg) {
    val codeNode = msg.get("code")
    if (codeNode !== null) {
      //val code = codeNode.asLong
      
      //TODO: Process codes:
      //20051 : Stop/Restart Websocket Server (please reconnect)
      //20060 : Entering in Maintenance mode. Please pause any activity and resume after receiving the info message 20061 (it should take 120 seconds at most).
      //20061 : Maintenance ended. You can resume normal activity. It is advised to unsubscribe/subscribe again all channels.
      
      println('''ERROR: Can't handle info codes, not implemented!''')
      System.exit(-1)
      return true
    }
    
    val version = msg.get("version").asLong
    if (version !== 2) {
      println('''ERROR: Version «version» is not supported! Only version 2.''')
      System.exit(-1)
    }
    
    return true
  }
  
  private def boolean processConf(JsonNode msg) {
    val statusNode = msg.get("status")
    if (statusNode === null || statusNode.asText != "OK") {
      println("ERROR: Configuration status not OK!")
      System.exit(-1)
    }
    
    return true
  }
  
  override send(JsonNode msg) {
    val txtMsg = mapper.writeValueAsString(msg)
    println("SEND: " + txtMsg)
    ws.send(txtMsg)
  }
  
  override send(Map<String, ?> msg) {
    val txtMsg = mapper.writeValueAsString(msg)
    println("SEND: " + txtMsg)
    ws.send(txtMsg)
  }
  
  override onMessage((JsonNode)=>void onMessage) {
    this.onMessage = onMessage
  }
}