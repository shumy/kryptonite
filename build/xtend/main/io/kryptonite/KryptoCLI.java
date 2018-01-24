package io.kryptonite;

import ch.qos.logback.classic.Level;
import io.kryptonite.RCommand;
import io.kryptonite.adapter.Bitfinex;
import io.kryptonite.api.Exchanger;
import io.kryptonite.api.dto.Candle;
import io.kryptonite.db.ModelService;
import io.kryptonite.db.NeoDB;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.List;
import org.eclipse.xtend2.lib.StringConcatenation;
import org.eclipse.xtext.xbase.lib.Conversions;
import org.eclipse.xtext.xbase.lib.Exceptions;
import org.eclipse.xtext.xbase.lib.InputOutput;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import picocli.CommandLine;

@SuppressWarnings("all")
public class KryptoCLI {
  private final static DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd");
  
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
    Logger _logger = LoggerFactory.getLogger(ch.qos.logback.classic.Logger.ROOT_LOGGER_NAME);
    final ch.qos.logback.classic.Logger logger = ((ch.qos.logback.classic.Logger) _logger);
    if (cmd.log) {
      logger.setLevel(Level.INFO);
    } else {
      logger.setLevel(Level.ERROR);
    }
    try {
      if (cmd.help) {
        RCommand _rCommand_2 = new RCommand();
        CommandLine.usage(_rCommand_2, System.out);
        return;
      }
      if ((cmd.query != null)) {
        final NeoDB db = new NeoDB("data");
        InputOutput.<String>println(db.cypher(cmd.query).resultAsString());
        return;
      }
      if ((cmd.collect != null)) {
        Integer _elvis = null;
        if (cmd.size != null) {
          _elvis = cmd.size;
        } else {
          _elvis = Integer.valueOf(1);
        }
        final Integer size = _elvis;
        final String[] split = cmd.collect.split("\\|");
        int _length = split.length;
        boolean _tripleNotEquals = (_length != 2);
        if (_tripleNotEquals) {
          InputOutput.<String>println("--collect arguments are not correct!");
          return;
        }
        KryptoCLI.collect(split[0], size, split[1]);
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
  
  public static void collect(final String start, final Integer size, final String pairs) {
    try {
      final LocalDate date = LocalDate.parse(start, KryptoCLI.formatter);
      final ModelService db = new ModelService();
      Bitfinex _bitfinex = new Bitfinex();
      final Exchanger clt = new Exchanger(_bitfinex);
      final String[] pairsList = pairs.split(" ");
      for (final String pair : pairsList) {
        for (int i = 0; (i < (size).intValue()); i++) {
          {
            final String from = date.plusDays(i).format(KryptoCLI.formatter);
            final List<Candle> candles = clt.getDayHistory(pair, from);
            final long saved = db.saveCandles(pair, candles);
            StringConcatenation _builder = new StringConcatenation();
            _builder.append("COLLECTED-CANDLES: (pair=");
            _builder.append(pair);
            _builder.append(", from=");
            _builder.append(from);
            _builder.append(", saved=");
            _builder.append(saved);
            _builder.append(")");
            InputOutput.<String>println(_builder.toString());
            Thread.sleep(10_000);
          }
        }
      }
      System.exit(0);
    } catch (Throwable _e) {
      throw Exceptions.sneakyThrow(_e);
    }
  }
  
  public static void test() {
    Bitfinex _bitfinex = new Bitfinex();
    final Exchanger clt = new Exchanger(_bitfinex);
    final List<Candle> res = clt.getDayHistory("2018-01-01", "XRPUSD");
    for (int i = 0; (i < ((Object[])Conversions.unwrapArray(res, Object.class)).length); i++) {
      String _plus = (Integer.valueOf(i) + ": ");
      Candle _get = res.get(i);
      String _plus_1 = (_plus + _get);
      InputOutput.<String>println(_plus_1);
    }
  }
}
