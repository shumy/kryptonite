package io.kryptonite;

import io.kryptonite.RCommand;
import io.kryptonite.api.Bittrex;
import io.kryptonite.api.CurrencyPair;
import io.kryptonite.api.dto.Ticker;
import org.eclipse.xtend2.lib.StringConcatenation;
import org.eclipse.xtext.xbase.lib.Exceptions;
import org.eclipse.xtext.xbase.lib.InputOutput;
import org.eclipse.xtext.xbase.lib.ObjectExtensions;
import org.eclipse.xtext.xbase.lib.Procedures.Procedure1;
import picocli.CommandLine;

@SuppressWarnings("all")
public class KryptoCLI {
  public static void main(final String[] args) {
    RCommand _xtrycatchfinallyexpression = null;
    try {
      RCommand _rCommand = new RCommand();
      _xtrycatchfinallyexpression = CommandLine.<RCommand>populateCommand(_rCommand, args);
    } catch (final Throwable _t) {
      if (_t instanceof Throwable) {
        final Throwable ex = (Throwable)_t;
        RCommand _rCommand_1 = new RCommand();
        CommandLine.usage(_rCommand_1, System.out);
        return;
      } else {
        throw Exceptions.sneakyThrow(_t);
      }
    }
    final RCommand cmd = _xtrycatchfinallyexpression;
    try {
      if (cmd.help) {
        RCommand _rCommand_2 = new RCommand();
        CommandLine.usage(_rCommand_2, System.out);
        return;
      }
      if (cmd.test) {
        KryptoCLI.test();
        return;
      }
    } catch (final Throwable _t_1) {
      if (_t_1 instanceof Throwable) {
        final Throwable ex_1 = (Throwable)_t_1;
        if (cmd.stack) {
          ex_1.printStackTrace();
        } else {
          StringConcatenation _builder = new StringConcatenation();
          _builder.append("ERROR -> ");
          String _name = ex_1.getClass().getName();
          _builder.append(_name);
          _builder.append(": ");
          String _message = ex_1.getMessage();
          _builder.append(_message);
          InputOutput.<String>println(_builder.toString());
        }
      } else {
        throw Exceptions.sneakyThrow(_t_1);
      }
    }
  }
  
  public static void test() {
    Bittrex _bittrex = new Bittrex();
    final Procedure1<Bittrex> _function = (Bittrex it) -> {
      CurrencyPair _currencyPair = new CurrencyPair("BTC", "XLM");
      final Ticker ticker = it.getTicker(_currencyPair, "thirtyMin");
      InputOutput.<Ticker>println(ticker);
    };
    ObjectExtensions.<Bittrex>operator_doubleArrow(_bittrex, _function);
  }
}
