import 'dart:convert';
import 'package:sinoniza_app/helpers/utils.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class Api {
  static Uri _buildUri(path, [params]) {
    final isDebug = Utils.isDebug();
    return Uri(
      host: isDebug ? '192.168.1.104' : 'api.sinoniza.thiagosf.net',
      port: isDebug ? 3000 : 443,
      scheme: isDebug ? 'http' : 'https',
      path: path,
      queryParameters: params,
    );
  }

  static Future<http.Response> get(
    String path, [
    params,
    String token = '',
  ]) async {
    Map<String, String> headers = new Map();
    if (token != '') {
      headers['Authorization'] = "Token $token";
    }
    final uri = _buildUri(path, params);
    return http.get(uri, headers: headers);
  }

  static Future<http.Response> post(
    String path, [
    Map<dynamic, dynamic> body,
    String token = '',
  ]) async {
    Map<String, String> headers = new Map();
    headers['Content-type'] = 'application/json';
    if (token != '') {
      headers['Authorization'] = "Token $token";
    }
    final uri = _buildUri(path);
    return http.post(
      uri,
      body: jsonEncode(body),
      headers: headers,
    );
  }

  static Future<String> getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }
}

class ApiException implements Exception {
  final message;
  ApiException([this.message]);

  String toString() {
    if (message == null) return "Exception";
    return message;
  }
}
