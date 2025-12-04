import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:movix/API/login_fetcher.dart' as login_api;
import 'package:movix/Models/Profil.dart';
import 'package:movix/Services/globals.dart';
import 'package:movix/Services/update_check_cache.dart';
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

/// Vérifie /auth/me avec gestion du cache (12h) et timeout de 3 secondes
/// Si le réseau est lent (> 3s), la requête est ignorée silencieusement
/// Si force=true, ignore le cache et vérifie toujours
Future<void> checkAuthMeWithCache({bool force = false}) async {
  // Vérifie si un check est nécessaire (12h écoulées)
  if (!force && !UpdateCheckCache.shouldCheckAuthMe()) {
    return;
  }

  try {
    // Effectue le check avec timeout de 3 secondes
    final profil = await login_api.me().timeout(
      const Duration(seconds: 3),
      onTimeout: () {
        // Timeout : réseau trop lent, on ignore silencieusement
        debugPrint('Timeout lors de la vérification /auth/me (réseau lent) - ignoré');
        return null;
      },
    );

    if (profil != null) {
      // Succès : met à jour le profil et enregistre la date/heure du check
      final prefs = await SharedPreferences.getInstance();
      var profilJson = jsonEncode(profil.toJson());
      await prefs.setString('profil', profilJson);
      Globals.profil = profil;
      await UpdateCheckCache.saveLastAuthMeCheckTime();
      debugPrint('Vérification /auth/me réussie');
    } else {
      // Échec ou timeout : n'enregistre pas la date/heure pour réessayer plus tard
      debugPrint('Échec de la vérification /auth/me');
    }
  } catch (e) {
    // Erreur réseau ou autre : on ignore silencieusement
    debugPrint('Erreur lors de la vérification /auth/me : $e');
  }
}
