package io.kryptonite;

import picocli.CommandLine;

@CommandLine.Command(name = "kryptonite-cli", footer = "Copyright(c) 2017", description = "Kryptonite Helper")
@SuppressWarnings("all")
public class RCommand {
  @CommandLine.Option(names = { "-h", "--help" }, help = true, description = "Display this help and exit.")
  public boolean help;
  
  @CommandLine.Option(names = { "--stack" }, help = true, description = "Display the stack trace error if any.")
  public boolean stack;
  
  @CommandLine.Option(names = { "--test" }, help = true, description = "Test the streaming API.")
  public boolean test;
}
