package io.kryptonite;

import ch.qos.logback.classic.Level;
import io.kryptonite.RCommand;
import io.kryptonite.adapter.Bitfinex;
import io.kryptonite.api.Exchanger;
import io.kryptonite.api.Subscription;
import io.kryptonite.api.dto.Candle;
import org.eclipse.xtend2.lib.StringConcatenation;
import org.eclipse.xtext.xbase.lib.Exceptions;
import org.eclipse.xtext.xbase.lib.InputOutput;
import org.eclipse.xtext.xbase.lib.ObjectExtensions;
import org.eclipse.xtext.xbase.lib.Procedures.Procedure1;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
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
    Logger _logger = LoggerFactory.getLogger(ch.qos.logback.classic.Logger.ROOT_LOGGER_NAME);
    final Procedure1<ch.qos.logback.classic.Logger> _function = (ch.qos.logback.classic.Logger it) -> {
      it.setLevel(Level.ERROR);
    };
    ObjectExtensions.<ch.qos.logback.classic.Logger>operator_doubleArrow(
      ((ch.qos.logback.classic.Logger) _logger), _function);
    Bitfinex _bitfinex = new Bitfinex();
    final Exchanger clt = new Exchanger(_bitfinex);
    final Procedure1<Subscription<Candle>> _function_1 = (Subscription<Candle> it) -> {
      InputOutput.<String>println("Subscribed to XRPUSD 1m candles...");
      final Procedure1<Candle> _function_2 = (Candle it_1) -> {
        InputOutput.<Candle>println(it_1);
      };
      it.onMessage(_function_2);
    };
    clt.<Candle>subscribe(Candle.class, "1m:tXRPUSD").then(_function_1);
  }
}
