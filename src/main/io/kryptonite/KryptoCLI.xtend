package io.kryptonite

import ch.qos.logback.classic.Level
import ch.qos.logback.classic.Logger
import io.kryptonite.adapter.Bitfinex
import io.kryptonite.api.Exchanger
import io.kryptonite.db.ModelService
import io.kryptonite.db.NeoDB
import java.time.LocalDate
import java.time.format.DateTimeFormatter
import org.slf4j.LoggerFactory
import picocli.CommandLine
import picocli.CommandLine.Command
import picocli.CommandLine.Option

@Command(
  name = "kryptonite-cli", footer = "Copyright(c) 2017",
  description = "Kryptonite Helper"
)
class RCommand {
  @Option(names = #["-h", "--help"], help = true, description = "Display this help and exit.")
  public boolean help
  
  @Option(names = #["--stack"], help = true, description = "Display the stack trace error if any.")
  public boolean stack
  
  @Option(names = #["--log"], help = true, description = "Display info logs.")
  public boolean log
  
  @Option(names = "--query", help = true, description = "Execute a Cypher query.")
  public String query
  
  @Option(names = #["--collect"], help = true, description = "Collect history from a set of pairs.")
  public String collect
  
  @Option(names = "--size", help = true, description = "Number of days to collect.")
  public Integer size
  
  @Option(names = #["--test"], help = true, description = "Test the streaming API.")
  public boolean test
  
  //@Option(names = #["--server"], help = true, description = "Run the HTTP server.")
  //public boolean server
  
  //@Option(names = #["-l", "--load"], help = true, description = "Load CSV file.")
  //public String path
}


class KryptoCLI {
  static val formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd")
  
  def static void main(String[] args) {
    val cmd =  try {
      CommandLine.populateCommand(new RCommand, args)
    } catch (Throwable ex) {
      CommandLine.usage(new RCommand, System.out)
      return
    }
    
    val logger = LoggerFactory.getLogger(Logger.ROOT_LOGGER_NAME) as Logger
    if (cmd.log)
      logger.level = Level.INFO
    else
      logger.level = Level.ERROR
    
    try {
      if (cmd.help) {
        CommandLine.usage(new RCommand, System.out)
        return
      }
      
      if (cmd.query !== null) {
        val db = new NeoDB("data")
        println(db.cypher(cmd.query).resultAsString)
        return
      }
      
      if (cmd.collect !== null) {
        val size = cmd.size ?: 1
        val split = cmd.collect.split("\\|")
        if (split.length !== 2) {
          println("--collect arguments are not correct!")
          return
        }
        
        collect(split.get(0), size, split.get(1))
        return
      }
      
      if (cmd.test) {
        test
        return
      }
      
      /*if (cmd.server) {
        HTTPServer.start
        return
      }*/
      
    } catch (Throwable ex) {
      if (cmd.stack)
        ex.printStackTrace
      else
        println('''ERROR -> «ex.class.name»: «ex.message»''')
    }
  }
  
  def static void collect(String start, Integer size, String pairs) {
    val date = LocalDate.parse(start, formatter)
    
    val db = new ModelService
    val clt = new Exchanger(new Bitfinex)
    
    val pairsList = pairs.split(" ")
    for (pair : pairsList) {
      for (var i = 0; i < size; i++) {
        val from = date.plusDays(i).format(formatter)
        val candles = clt.getDayHistory(pair, from)
        val saved = db.saveCandles(pair, candles)
        println('''COLLECTED-CANDLES: (pair=«pair», from=«from», saved=«saved»)''')
        Thread.sleep(10_000) //don't exceed the rate limit...
      }
    }
    System.exit(0)
  }
  
  def static void test() {
    val clt = new Exchanger(new Bitfinex)
    val res = clt.getDayHistory("2018-01-01", "XRPUSD")
    
    for (var i = 0; i < res.length; i++)
      println(i+ ": " + res.get(i))
    
    /*val clt = new Exchanger(new Bitfinex)
    clt.subscribe(Candle, "1m:tXRPUSD").then[
      println("Subscribed to XRPUSD 1m candles...")
      onMessage[
        println(it)
      ]
    ]*/
  }
}