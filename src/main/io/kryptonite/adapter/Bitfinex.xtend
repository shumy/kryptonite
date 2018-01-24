package io.kryptonite.adapter

import com.fasterxml.jackson.databind.JsonNode
import com.fasterxml.jackson.databind.ObjectMapper
import java.net.URI
import java.util.Map
import org.java_websocket.client.WebSocketClient
import org.java_websocket.handshake.ServerHandshake
import org.slf4j.LoggerFactory
import okhttp3.OkHttpClient
import okhttp3.Request

class Bitfinex implements IAdapter {
  static val logger = LoggerFactory.getLogger(Bitfinex)
  
  val mapper = new ObjectMapper
  val httpURL = "https://api.bitfinex.com/v2"
  val wsURL = new URI("wss://api.bitfinex.com/ws/2")
  
  val clt = new OkHttpClient
  val WebSocketClient ws
  
  var (JsonNode)=>void onMessage = null
  
  new() {
    ws = new WebSocketClient(wsURL) {
      override onOpen(ServerHandshake handshakedata) {
        logger.info("OPEN: {}", handshakedata.httpStatus)
        send(#{ "event" -> "conf", "flags" -> 32 }) //Enable all times as date strings.
      }
      
      override onMessage(String txtMsg) {
        logger.info("RECEIVED: {}", txtMsg)
        val msg = mapper.readTree(txtMsg)
        
        if (!process(msg))
          onMessage?.apply(msg)
      }
      
      override onClose(int code, String reason, boolean remote) {
        logger.info("CLOSED: {}", reason)
        
        //TODO: reconnect?
      }
      
      override onError(Exception ex) {
        logger.error("{}", ex.message)
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
      
      logger.error("Can't handle info codes, not implemented! CODE = {}", codeNode.asLong)
      System.exit(-1)
      return true
    }
    
    val version = msg.get("version").asLong
    if (version !== 2) {
      logger.error("Version {} is not supported! Only version 2.", version)
      System.exit(-1)
    }
    
    return true
  }
  
  private def boolean processConf(JsonNode msg) {
    val statusNode = msg.get("status")
    if (statusNode === null || statusNode.asText != "OK") {
      logger.error("Configuration status not OK!")
      System.exit(-1)
    }
    
    return true
  }
    
  override send(JsonNode msg) {
    val txtMsg = mapper.writeValueAsString(msg)
    logger.info("SEND: {}", txtMsg)
    ws.send(txtMsg)
  }
  
  override send(Map<String, ?> msg) {
    val txtMsg = mapper.writeValueAsString(msg)
    logger.info("SEND: {}", txtMsg)
    ws.send(txtMsg)
  }
  
  override onMessage((JsonNode)=>void onMessage) {
    this.onMessage = onMessage
  }
  
  override get(String uri) { get(uri, null) }
  
  override get(String uri, Map<String, String> params) {
    val txtParams = if (params === null || params.empty) "" else '''?«FOR key: params.keySet SEPARATOR '&'»«key»=«params.get(key)»«ENDFOR»'''
    val url = '''«httpURL»«IF !uri.startsWith("/")»/«ENDIF»«uri»«txtParams»'''
    
    logger.info("GET: {}", url)
    val req = new Request.Builder().url(url).build
    
    val res = clt.newCall(req).execute
    val txtRes = res.body.string
    if (res.code !== 200) {
      logger.error("GET-ERROR: {} {}", res.code, txtRes)
      return null
    }
    
    logger.info("GET-RESULT: {}", txtRes)
    return mapper.readTree(txtRes)
  }
}