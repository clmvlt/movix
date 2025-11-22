import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:movix/API/base.dart';
import 'package:movix/Models/Profil.dart';
import 'package:movix/Services/globals.dart';

const String _BETA_API_URL = "https://api.beta.movix.fr";

Future<Profil?> login(String identifiant, String password) async {
  try {
    final response = await ApiBase.post('/auth/login', {
      'identifiant': identifiant,
      'password': password
    });

    if (ApiBase.isSuccess(response.statusCode)) {
      final responseData = ApiBase.decodeResponse(response) as Map<String, dynamic>;
      return Profil.fromJson(responseData);
    }

    // Si erreur d'identifiant en prod, réessayer sur api.beta.movix.fr
    if (!kDebugMode && response.statusCode == 401) {
      final betaResponse = await _loginOnBeta(identifiant, password);
      if (betaResponse != null) {
        return betaResponse;
      }
    }

    return null;
  } catch (e) {
    print(e);
    return null;
  }
}

Future<Profil?> _loginOnBeta(String identifiant, String password) async {
  try {
    final url = Uri.parse('$_BETA_API_URL/auth/login');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'identifiant': identifiant,
        'password': password
      }),
    );

    if (!ApiBase.isSuccess(response.statusCode)) return null;

    final responseData = json.decode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
    return Profil.fromJson(responseData);
  } catch (e) {
    print('Beta login error: $e');
    return null;
  }
}

Future<Profil?> me() async {
  try {
    final response = await ApiBase.get('/auth/me');

    if (ApiBase.isSuccess(response.statusCode)) {
      final responseData = ApiBase.decodeResponse(response) as Map<String, dynamic>;
      return Profil.fromJson(responseData);
    }

    // Si erreur en prod, réessayer sur api.beta.movix.fr
    if (!kDebugMode && response.statusCode == 401) {
      final betaResponse = await _meOnBeta();
      if (betaResponse != null) {
        return betaResponse;
      }
    }

    return null;
  } catch (e) {
    print(e);
    return null;
  }
}

Future<Profil?> _meOnBeta() async {
  try {
    final token = Globals.profil?.token;
    if (token == null || token.isEmpty) return null;

    final url = Uri.parse('$_BETA_API_URL/auth/me');
    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': token,
      },
    );

    if (!ApiBase.isSuccess(response.statusCode)) return null;

    final responseData = json.decode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
    return Profil.fromJson(responseData);
  } catch (e) {
    debugPrint('Beta me error: $e');
    return null;
  }
} 