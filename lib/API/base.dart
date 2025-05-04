import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:movix/Services/globals.dart';

class ApiBase {
  static Future<http.Response> get(String endpoint) async {
    final url = Uri.parse('${Globals.API_URL}$endpoint');
    try {
      return await http.get(url, headers: _headers());
    } on SocketException {
      Globals.showSnackbar("Aucune connexion internet.", backgroundColor: Globals.COLOR_MOVIX_RED);
      return _errorResponse("Aucune connexion Internet.");
    } catch (e) {
      print("Erreur inattendue : $e");
      return _errorResponse("Erreur inattendue : $e");
    }
  }

  static Future<http.Response> post(String endpoint, Map<String, dynamic> body) async {
    final url = Uri.parse('${Globals.API_URL}$endpoint');
    try {
      return await http.post(
        url,
        headers: _headers(contentType: true),
        body: jsonEncode(body),
      );
    } on SocketException {
      Globals.showSnackbar("Aucune connexion internet.", backgroundColor: Globals.COLOR_MOVIX_RED);
      return _errorResponse("Aucune connexion Internet.");
    } catch (e) {
      print("Erreur inattendue : $e");
      return _errorResponse("Erreur inattendue : $e");
    }
  }

  static Map<String, String> _headers({bool contentType = false}) {
    final headers = {
      'Authorization': Globals.profil?.token ?? "",
    };

    if (contentType) {
      headers['Content-Type'] = 'application/json';
    }

    return headers;
  }

  static Map<String, dynamic> decodeResponse(http.Response response) {
    return json.decode(response.body);
  }

  static bool isSuccess(int statusCode) {
    return statusCode >= 200 && statusCode < 300;
  }

  static http.Response _errorResponse(String message) {
    return http.Response(jsonEncode({'error': message}), 500);
  }
}
