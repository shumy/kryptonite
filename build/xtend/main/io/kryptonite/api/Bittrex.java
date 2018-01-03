package io.kryptonite.api;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.google.common.base.Objects;
import io.kryptonite.api.CurrencyPair;
import io.kryptonite.api.dto.Ticker;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import okhttp3.OkHttpClient;
import okhttp3.Request;
import okhttp3.Response;
import org.eclipse.xtend2.lib.StringConcatenation;
import org.eclipse.xtext.xbase.lib.Exceptions;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

@SuppressWarnings("all")
public class Bittrex {
  private final static Logger logger = LoggerFactory.getLogger(Bittrex.class);
  
  private final DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd\'T\'HH:mm:ss");
  
  private final ObjectMapper mapper = new ObjectMapper();
  
  private final OkHttpClient client = new OkHttpClient();
  
  private final String baseUrl = "https://bittrex.com/Api/v2.0/";
  
  public Ticker getTicker(final CurrencyPair pair, final String tickInterval) {
    try {
      Request.Builder _builder = new Request.Builder();
      StringConcatenation _builder_1 = new StringConcatenation();
      _builder_1.append(this.baseUrl);
      _builder_1.append("pub/market/GetLatestTick?marketName=");
      _builder_1.append(pair.c1);
      _builder_1.append("-");
      _builder_1.append(pair.c2);
      _builder_1.append("&tickInterval=");
      _builder_1.append(tickInterval);
      final Request request = _builder.url(_builder_1.toString()).build();
      final Response response = this.client.newCall(request).execute();
      final String value = response.body().string();
      Bittrex.logger.debug(value);
      final JsonNode obj = this.mapper.readTree(value);
      JsonNode _get = obj.get("success");
      boolean _equals = Objects.equal(_get, Boolean.valueOf(false));
      if (_equals) {
        JsonNode _get_1 = obj.get("message");
        String _plus = ("Error in getTicker -> " + _get_1);
        throw new RuntimeException(_plus);
      }
      final JsonNode result = obj.get("result").get(0);
      LocalDateTime _parse = LocalDateTime.parse(result.get("T").asText(), this.formatter);
      double _asDouble = result.get("V").asDouble();
      double _asDouble_1 = result.get("O").asDouble();
      double _asDouble_2 = result.get("H").asDouble();
      double _asDouble_3 = result.get("L").asDouble();
      double _asDouble_4 = result.get("C").asDouble();
      return new Ticker(_parse, _asDouble, _asDouble_1, _asDouble_2, _asDouble_3, _asDouble_4);
    } catch (Throwable _e) {
      throw Exceptions.sneakyThrow(_e);
    }
  }
}
