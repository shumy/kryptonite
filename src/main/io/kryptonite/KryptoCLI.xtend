package io.kryptonite

import io.kryptonite.api.Bittrex
import io.kryptonite.api.CurrencyPair
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
  
  @Option(names = #["--test"], help = true, description = "Test the streaming API.")
  public boolean test
  
  //@Parameters(index = "0", description = "Execute a Cypher query.")
  //public String query
  
  //@Option(names = #["--server"], help = true, description = "Run the HTTP server.")
  //public boolean server
  
  //@Option(names = #["-l", "--load"], help = true, description = "Load CSV file.")
  //public String path
}


class KryptoCLI {
  //static val logger = LoggerFactory.getLogger(KryptoCLI)
  
  def static void main(String[] args) {
    val cmd =  try {
      CommandLine.populateCommand(new RCommand, args)
    } catch (Throwable ex) {
      CommandLine.usage(new RCommand, System.out)
      return
    }
    
    try {
      if (cmd.help) {
        CommandLine.usage(new RCommand, System.out)
        return
      }
      
      if (cmd.test) {
        test
        return
      }
      
      /*if (cmd.server) {
        HTTPServer.start
        return
      }
      
      if (cmd.path !== null)
        loadFiles(cmd.path)
      
      if (cmd.query !== null) {
        val db = new NeoDB("data/viu")
        println(db.cypher(cmd.query).resultAsString)
      }*/
      
    } catch (Throwable ex) {
      if (cmd.stack)
        ex.printStackTrace
      else
        println('''ERROR -> «ex.class.name»: «ex.message»''')
    }
  }
  
  def static void test() {
    new Bittrex() => [
      val ticker = getTicker(new CurrencyPair("BTC", "XLM"), "thirtyMin")
      println(ticker)
    ]
  }
}