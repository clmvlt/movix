import 'package:hive_flutter/hive_flutter.dart';

/// Service de gestion du cache des vérifications (MAJ et /auth/me)
/// Stocke la date/heure du dernier check pour éviter les vérifications trop fréquentes
class UpdateCheckCache {
  static const String _boxName = 'updateCheckCache';
  static const String _lastUpdateCheckKey = 'lastUpdateCheckDateTime';
  static const String _lastAuthMeCheckKey = 'lastAuthMeCheckDateTime';
  static const Duration _cacheDuration = Duration(hours: 12);

  static Box<String>? _box;

  /// Initialise la box Hive pour le cache
  static Future<void> init() async {
    _box = await Hive.openBox<String>(_boxName);
  }

  // ==================== GESTION MISE À JOUR ====================

  /// Enregistre la date/heure actuelle comme dernier check de MAJ
  static Future<void> saveLastCheckTime() async {
    if (_box == null) await init();
    final now = DateTime.now().toIso8601String();
    await _box!.put(_lastUpdateCheckKey, now);
  }

  /// Récupère la date/heure du dernier check de MAJ
  static DateTime? getLastCheckTime() {
    if (_box == null) return null;
    final dateTimeString = _box!.get(_lastUpdateCheckKey);
    if (dateTimeString == null) return null;

    try {
      return DateTime.parse(dateTimeString);
    } catch (e) {
      return null;
    }
  }

  /// Vérifie si un nouveau check de MAJ est nécessaire (+ de 12h depuis le dernier)
  static bool shouldCheckForUpdate() {
    final lastCheck = getLastCheckTime();

    // Si aucun check précédent, on doit vérifier
    if (lastCheck == null) return true;

    // Vérifie si plus de 12h se sont écoulées
    final now = DateTime.now();
    final difference = now.difference(lastCheck);

    return difference >= _cacheDuration;
  }

  /// Récupère le temps restant avant le prochain check de MAJ autorisé
  static Duration? getTimeUntilNextCheck() {
    final lastCheck = getLastCheckTime();
    if (lastCheck == null) return null;

    final now = DateTime.now();
    final timeSinceLastCheck = now.difference(lastCheck);
    final timeRemaining = _cacheDuration - timeSinceLastCheck;

    return timeRemaining.isNegative ? Duration.zero : timeRemaining;
  }

  // ==================== GESTION /auth/me ====================

  /// Enregistre la date/heure actuelle comme dernier check de /auth/me
  static Future<void> saveLastAuthMeCheckTime() async {
    if (_box == null) await init();
    final now = DateTime.now().toIso8601String();
    await _box!.put(_lastAuthMeCheckKey, now);
  }

  /// Récupère la date/heure du dernier check de /auth/me
  static DateTime? getLastAuthMeCheckTime() {
    if (_box == null) return null;
    final dateTimeString = _box!.get(_lastAuthMeCheckKey);
    if (dateTimeString == null) return null;

    try {
      return DateTime.parse(dateTimeString);
    } catch (e) {
      return null;
    }
  }

  /// Vérifie si un nouveau check de /auth/me est nécessaire (+ de 12h depuis le dernier)
  static bool shouldCheckAuthMe() {
    final lastCheck = getLastAuthMeCheckTime();

    // Si aucun check précédent, on doit vérifier
    if (lastCheck == null) return true;

    // Vérifie si plus de 12h se sont écoulées
    final now = DateTime.now();
    final difference = now.difference(lastCheck);

    return difference >= _cacheDuration;
  }

  // ==================== UTILITAIRES ====================

  /// Efface tout le cache (MAJ + /auth/me)
  static Future<void> clearCache() async {
    if (_box == null) await init();
    await _box!.delete(_lastUpdateCheckKey);
    await _box!.delete(_lastAuthMeCheckKey);
  }

  /// Ferme la box Hive
  static Future<void> close() async {
    await _box?.close();
    _box = null;
  }
}
