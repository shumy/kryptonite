package io.kryptonite;

import picocli.CommandLine;

@CommandLine.Command(name = "kryptonite-cli", footer = "Copyright(c) 2017", description = "Kryptonite Helper")
@SuppressWarnings("all")
public class RCommand {
  @CommandLine.Option(names = { "-h", "--help" }, help = true, description = "Display this help and exit.")
  public boolean help;
  
  @CommandLine.Option(names = { "--stack" }, help = true, description = "Display the stack trace error if any.")
  public boolean stack;
  
  @CommandLine.Option(names = { "--log" }, help = true, description = "Display info logs.")
  public boolean log;
  
  @CommandLine.Option(names = "--query", help = true, description = "Execute a Cypher query.")
  public String query;
  
  @CommandLine.Option(names = { "--summary" }, help = true, description = "Summary of the loaded candles.")
  public boolean summary;
  
  @CommandLine.Option(names = { "--load" }, help = true, description = ("Load candles from the server for a set of pairs. Format: " + "<YYYY-MM-DD>|<PAIR> [...PAIRS]"))
  public String load;
  
  @CommandLine.Option(names = "--get", help = true, description = ("Get candles from the database. Format: " + "<YYYY-MM-DD>|<PAIR>"))
  public String get;
  
  @CommandLine.Option(names = "--size", help = true, description = "Number of days to load, or lines to get.")
  public Integer size;
  
  @CommandLine.Option(names = "--file", help = true, description = "CSV file to save candles.")
  public String file;
  
  @CommandLine.Option(names = { "--test" }, help = true, description = "Test the streaming API.")
  public boolean test;
}
