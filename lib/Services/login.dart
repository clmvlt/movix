import 'package:movix/Models/Profil.dart';
import 'package:movix/Services/globals.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:http/http.dart' as http;

Future<Profil?> login(String identifiant, String password) async {
  try {
    final url = Uri.parse('${Globals.API_URL}/mobileLogin');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'identifiant': identifiant, 'password': password}),
    );

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body) as Map<String, dynamic>;
      if (responseData['data'] != null) {
        Profil profil = Profil.fromJson(responseData['data']);
        var profilJson = jsonEncode(profil.toJson());
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('profil', profilJson);
        Globals.profil = profil;
        return profil;
      }
    }
  } catch (_) {}
  return null;
}

Future<Profil?> me(String token) async {
  try {
    final url = Uri.parse('${Globals.API_URL}/mobileMe');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json', 'Authorization': token}
    );

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body) as Map<String, dynamic>;
      if (responseData['data'] != null) {
        Profil profil = Profil.fromJson(responseData['data']);
        final prefs = await SharedPreferences.getInstance();
        var profilJson = jsonEncode(profil.toJson());
        await prefs.setString('profil', profilJson);
        Globals.profil = profil;
        return profil;
      }
    }
  } catch (_) {}
  return null;
}

Future<bool> isLogged() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.containsKey('profil');
}

Future<Profil?> getProfil() async {
  final prefs = await SharedPreferences.getInstance();
  final profilJson = prefs.getString('profil');
  var profil = jsonDecode(profilJson!);

  Profil? userProfil = Profil.fromJson(profil);

  userProfil = await me(userProfil.token);

  return userProfil;
}

Future<bool> logout() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('profil');
    Globals.profil = null;
    return true;
  } catch (_) {
    return false;
  }
}
