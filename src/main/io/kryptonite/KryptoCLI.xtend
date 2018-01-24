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
import java.io.FileWriter
import java.nio.file.Paths
import java.nio.file.Files

import io.kryptonite.api.dto.Candle

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
  
  
  @Option(names = #["--summary"], help = true, description = "Summary of the loaded candles.")
  public boolean summary
  
  @Option(names = #["--load"], help = true, description = "Load candles from the server for a set of pairs. Format: " + "<YYYY-MM-DD>|<PAIR> [...PAIRS]")
  public String load
  
  @Option(names = "--get", help = true, description = "Get candles from the database. Format: " + "<YYYY-MM-DD>|<PAIR>")
  public String get
  
  @Option(names = "--size", help = true, description = "Number of days to load, or lines to get.")
  public Integer size
  
  @Option(names = "--file", help = true, description = "CSV file to save candles.")
  public String file
  
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
      
      if (cmd.summary) {
        summary
        return
      }
      
      if (cmd.load !== null) {
        val size = cmd.size ?: 1
        val split = cmd.load.split("\\|")
        val pairs = if (split.length === 2) split.get(1) else //load all USD pairs
          'BTCUSD ETHUSD XRPUSD EOSUSD BCHUSD IOTAUSD NEOUSD LTCUSD ETCUSD XMRUSD DASHUSD OMGUSD BTGUSD ZECUSD SANUSD QTUMUSD QASHUSD TNBUSD ZRXUSD' +
          'ETPUSD SNPUSD YYWUSD DATAUSD MNAUSD FUNUSD EDOUSD GNTUSD BATUSD SPKUSD AVTUSD RRTUSD TRXUSD RCNUSD RLCUSD AIDUSD SNGUSD REPUSD ELFUSD'
        
        load(split.get(0), size, pairs)
        return
      }
      
      if (cmd.get !== null) {
        val size = cmd.size ?: 1440
        val split = cmd.get.split("\\|")
        if (split.length !== 2) {
          println("--get arguments are not correct!")
          return
        }
        
        if (cmd.file !== null) {
          //save to file
          getToFile(split.get(0), size, split.get(1), cmd.file)
          return
        } else {
          //show in table
          get(split.get(0), size, split.get(1))
          return
        }
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
  
  def static void summary() {
    val db = new NeoDB("data")
    
    val query = '''
      MATCH (c:Candle)
      RETURN c.pair as pair, min(c.stamp) as min, max(c.stamp) as max
      ORDER BY pair
    '''
    
    db.cypher(query).toList.forEach[
      val min = Candle.stampToDate(get("min") as Long)
      val max = Candle.stampToDate(get("max") as Long)
      println('''«get("pair")»: «min.format(formatter)» TO «max.format(formatter)»''')
    ]
    
    System.exit(0)
  }
  
  def static void load(String start, Integer size, String pairs) {
    val date = LocalDate.parse(start, formatter)
    
    val db = new ModelService
    val clt = new Exchanger(new Bitfinex)
    
    val pairsList = pairs.split(" ")
    for (pair : pairsList) {
      for (var i = 0; i < size; i++) {
        val from = date.plusDays(i).format(formatter)
        val candles = clt.getDayHistory(pair, from)
        val saved = db.saveCandles(pair, candles)
        println('''LOAD: (pair=«pair», from=«from», saved=«saved»)''')
        Thread.sleep(10_000) //don't exceed the rate limit...
      }
    }
    System.exit(0)
  }
  
  def static void get(String start, Integer size, String pair) {
    val db = new NeoDB("data")
    val range = ModelService.calcRange(start, size)
    
    val query = '''
      MATCH (c:Candle { pair:"«pair»" })
      WHERE c.stamp IN range(«range.start», «range.end»)
      RETURN c.stamp as stamp, c.open as open, c.close as close, c.high as high, c.low as low, c.volume as volume
      ORDER BY stamp
    '''
    
    println(db.cypher(query).resultAsString)
    System.exit(0)
  }
  
  def static void getToFile(String start, Integer size, String pair, String file) {
    Files.deleteIfExists(Paths.get(file))
    
    val writer = new FileWriter(file)
    writer.append("stamp,ts,open,close,high,low,volume\n")
    
    val db = new ModelService
    db.getCandles(pair, start, size).forEach[
      writer.append('''«stamp»,«timestamp»,«open»,«close»,«high»,«low»,«volume»''')
      writer.append("\n")
    ]
    
    writer.flush
    writer.close
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