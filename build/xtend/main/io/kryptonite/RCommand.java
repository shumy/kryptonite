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
  
  @CommandLine.Option(names = { "--collect" }, help = true, description = "Collect history from a set of pairs.")
  public String collect;
  
  @CommandLine.Option(names = "--size", help = true, description = "Number of days to collect.")
  public Integer size;
  
  @CommandLine.Option(names = { "--test" }, help = true, description = "Test the streaming API.")
  public boolean test;
}
