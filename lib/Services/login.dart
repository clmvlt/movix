import 'dart:convert';

import 'package:movix/API/login_fetcher.dart' as login_api;
import 'package:movix/Models/Profil.dart';
import 'package:movix/Services/globals.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<Profil?> login(String identifiant, String password) async {
  try {
    Profil? profil = await login_api.login(identifiant, password);
    if (profil != null) {
      var profilJson = jsonEncode(profil.toJson());
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('profil', profilJson);
      Globals.profil = profil;
      return profil;
    }
  } catch (e) {
    print("Erreur lors de la connexion : $e");
  }
  return null;
}

Future<Profil?> me() async {
  try {
    Profil? profil = await login_api.me();
    if (profil != null) {
      final prefs = await SharedPreferences.getInstance();
      var profilJson = jsonEncode(profil.toJson());
      await prefs.setString('profil', profilJson);
      Globals.profil = profil;
      return profil;
    }
  } catch (e) {
    print("Erreur lors de la récupération du profil : $e");
  }
  return null;
}

Future<bool> isLogged() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey('profil');
  } catch (e) {
    print("Erreur lors de la vérification de la connexion : $e");
    return false;
  }
}

Future<Profil?> getProfil() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final profilJson = prefs.getString('profil');
    if (profilJson == null) return null;
    
    var profil = jsonDecode(profilJson) as Map<String, dynamic>;
    Profil? userProfil = Profil.fromJson(profil);
    Globals.profil = userProfil;

    userProfil = await me();
    return userProfil;
  } catch (e) {
    print("Erreur lors de la récupération du profil : $e");
    return null;
  }
}

Future<bool> logout() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('profil');
    Globals.profil = null;
    return true;
  } catch (e) {
    print("Erreur lors de la déconnexion : $e");
    return false;
  }
}
