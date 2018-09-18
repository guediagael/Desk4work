import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

class NetworkUtil {
  // next three lines makes this class a Singleton
  static NetworkUtil _instance = new NetworkUtil.internal();
  NetworkUtil.internal();
  factory NetworkUtil() => _instance;

  final JsonDecoder _decoder = new JsonDecoder();

  Future<dynamic> get(String url,{Map headers}) {
    return http.get(url, headers: headers).then((http.Response response) {
      final String res = response.body;
      final int statusCode = response.statusCode;
      print('status code: $statusCode');
      if (statusCode < 200 || statusCode > 400 || json == null) {
        print("raw response ${response.reasonPhrase}");
        print("headers : ${response.toString()}");
        throw new Exception("Error while fetching data");
      }
      return _decoder.convert(res);
    });
  }

  Future<dynamic> post(String url, {Map headers, body, encoding}) {
    return http
        .post(url, body: body, headers: headers, encoding: encoding)
        .then((http.Response response) {
      final String res = response.body;
      final int statusCode = response.statusCode;
      if (statusCode < 200 || statusCode > 400 || json == null) {
        print('response: $statusCode ${response.body.toString()}');
        print("error respone: ${response.reasonPhrase}");
        print("query $url , $headers , $body");
        throw new Exception(res);
      }
      print("response code ${response.statusCode}");
      return _decoder.convert(res);
    });
  }
}