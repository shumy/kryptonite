package io.kryptonite;

import ch.qos.logback.classic.Level;
import io.kryptonite.RCommand;
import io.kryptonite.adapter.Bitfinex;
import io.kryptonite.api.Exchanger;
import io.kryptonite.api.dto.Candle;
import io.kryptonite.db.ModelService;
import io.kryptonite.db.NeoDB;
import io.kryptonite.db.Range;
import java.io.FileWriter;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.List;
import java.util.Map;
import java.util.function.Consumer;
import org.eclipse.xtend2.lib.StringConcatenation;
import org.eclipse.xtext.xbase.lib.Conversions;
import org.eclipse.xtext.xbase.lib.Exceptions;
import org.eclipse.xtext.xbase.lib.InputOutput;
import org.eclipse.xtext.xbase.lib.IteratorExtensions;
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
      if (cmd.summary) {
        KryptoCLI.summary();
        return;
      }
      if ((cmd.load != null)) {
        Integer _elvis = null;
        if (cmd.size != null) {
          _elvis = cmd.size;
        } else {
          _elvis = Integer.valueOf(1);
        }
        final Integer size = _elvis;
        final String[] split = cmd.load.split("\\|");
        String _xifexpression = null;
        int _length = split.length;
        boolean _tripleEquals = (_length == 2);
        if (_tripleEquals) {
          _xifexpression = split[1];
        } else {
          _xifexpression = ("BTCUSD ETHUSD XRPUSD EOSUSD BCHUSD IOTAUSD NEOUSD LTCUSD ETCUSD XMRUSD DASHUSD OMGUSD BTGUSD ZECUSD SANUSD QTUMUSD QASHUSD TNBUSD ZRXUSD" + 
            "ETPUSD SNPUSD YYWUSD DATAUSD MNAUSD FUNUSD EDOUSD GNTUSD BATUSD SPKUSD AVTUSD RRTUSD TRXUSD RCNUSD RLCUSD AIDUSD SNGUSD REPUSD ELFUSD");
        }
        final String pairs = _xifexpression;
        KryptoCLI.load(split[0], size, pairs);
        return;
      }
      if ((cmd.get != null)) {
        Integer _elvis_1 = null;
        if (cmd.size != null) {
          _elvis_1 = cmd.size;
        } else {
          _elvis_1 = Integer.valueOf(1440);
        }
        final Integer size_1 = _elvis_1;
        final String[] split_1 = cmd.get.split("\\|");
        int _length_1 = split_1.length;
        boolean _tripleNotEquals = (_length_1 != 2);
        if (_tripleNotEquals) {
          InputOutput.<String>println("--get arguments are not correct!");
          return;
        }
        if ((cmd.file != null)) {
          KryptoCLI.getToFile(split_1[0], size_1, split_1[1], cmd.file);
          return;
        } else {
          KryptoCLI.get(split_1[0], size_1, split_1[1]);
          return;
        }
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
  
  public static void summary() {
    final NeoDB db = new NeoDB("data");
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("MATCH (c:Candle)");
    _builder.newLine();
    _builder.append("RETURN c.pair as pair, min(c.stamp) as min, max(c.stamp) as max");
    _builder.newLine();
    _builder.append("ORDER BY pair");
    _builder.newLine();
    final String query = _builder.toString();
    final Consumer<Map<String, Object>> _function = (Map<String, Object> it) -> {
      Object _get = it.get("min");
      final LocalDateTime min = Candle.stampToDate(((Long) _get));
      Object _get_1 = it.get("max");
      final LocalDateTime max = Candle.stampToDate(((Long) _get_1));
      StringConcatenation _builder_1 = new StringConcatenation();
      Object _get_2 = it.get("pair");
      _builder_1.append(_get_2);
      _builder_1.append(": ");
      String _format = min.format(KryptoCLI.formatter);
      _builder_1.append(_format);
      _builder_1.append(" TO ");
      String _format_1 = max.format(KryptoCLI.formatter);
      _builder_1.append(_format_1);
      InputOutput.<String>println(_builder_1.toString());
    };
    IteratorExtensions.<Map<String, Object>>toList(db.cypher(query)).forEach(_function);
    System.exit(0);
  }
  
  public static void load(final String start, final Integer size, final String pairs) {
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
  
  public static void get(final String start, final Integer size, final String pair) {
    final NeoDB db = new NeoDB("data");
    final Range range = ModelService.calcRange(start, size);
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("MATCH (c:Candle { pair:\"");
    _builder.append(pair);
    _builder.append("\" })");
    _builder.newLineIfNotEmpty();
    _builder.append("WHERE c.stamp IN range(");
    _builder.append(range.start);
    _builder.append(", ");
    _builder.append(range.end);
    _builder.append(")");
    _builder.newLineIfNotEmpty();
    _builder.append("RETURN c.stamp as stamp, c.open as open, c.close as close, c.high as high, c.low as low, c.volume as volume");
    _builder.newLine();
    _builder.append("ORDER BY stamp");
    _builder.newLine();
    final String query = _builder.toString();
    InputOutput.<String>println(db.cypher(query).resultAsString());
    System.exit(0);
  }
  
  public static void getToFile(final String start, final Integer size, final String pair, final String file) {
    try {
      Files.deleteIfExists(Paths.get(file));
      final FileWriter writer = new FileWriter(file);
      writer.append("stamp,ts,open,close,high,low,volume\n");
      final ModelService db = new ModelService();
      final Consumer<Candle> _function = (Candle it) -> {
        try {
          StringConcatenation _builder = new StringConcatenation();
          _builder.append(it.stamp);
          _builder.append(",");
          LocalDateTime _timestamp = it.getTimestamp();
          _builder.append(_timestamp);
          _builder.append(",");
          _builder.append(it.open);
          _builder.append(",");
          _builder.append(it.close);
          _builder.append(",");
          _builder.append(it.high);
          _builder.append(",");
          _builder.append(it.low);
          _builder.append(",");
          _builder.append(it.volume);
          writer.append(_builder);
          writer.append("\n");
        } catch (Throwable _e) {
          throw Exceptions.sneakyThrow(_e);
        }
      };
      db.getCandles(pair, start, size).forEach(_function);
      writer.flush();
      writer.close();
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
