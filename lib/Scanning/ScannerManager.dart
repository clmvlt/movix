import 'package:flutter/material.dart';
import 'package:movix/Models/Sound.dart';

/// Gestionnaire global pour le scanner.
/// Gère une pile de callbacks validateCode pour savoir quelle page doit recevoir les scans.
class ScannerManager extends ChangeNotifier {
  static final ScannerManager _instance = ScannerManager._internal();
  factory ScannerManager() => _instance;
  ScannerManager._internal();

  /// Pile des callbacks de validation (le dernier est celui de la page au premier plan)
  final List<_ScannerCallback> _callbackStack = [];

  /// Vérifie si un callback spécifique est celui du premier plan
  bool isTopCallback(Future<ScanResult> Function(String) callback) {
    if (_callbackStack.isEmpty) return false;
    return _callbackStack.last.callback == callback;
  }

  /// Enregistre un nouveau callback (quand une page avec scanner s'affiche)
  void pushCallback(Future<ScanResult> Function(String) callback) {
    _callbackStack.add(_ScannerCallback(callback));
    debugPrint('ScannerManager: pushCallback (stack size: ${_callbackStack.length})');
    notifyListeners();
  }

  /// Retire le callback (quand une page avec scanner se ferme)
  void popCallback(Future<ScanResult> Function(String) callback) {
    _callbackStack.removeWhere((c) => c.callback == callback);
    debugPrint('ScannerManager: popCallback (stack size: ${_callbackStack.length})');
    notifyListeners();
  }

  /// Retourne le callback actif (celui de la page au premier plan)
  Future<ScanResult> Function(String)? get currentCallback {
    return _callbackStack.isNotEmpty ? _callbackStack.last.callback : null;
  }

  /// Vérifie si un scan peut être traité
  bool get canScan => _callbackStack.isNotEmpty;

  /// Traite un code scanné avec le callback actif
  Future<ScanResult> handleScan(String code) async {
    final callback = currentCallback;
    if (callback == null) {
      debugPrint('ScannerManager: Aucun callback actif, scan ignoré');
      return ScanResult.SCAN_ERROR;
    }
    return await callback(code);
  }
}

class _ScannerCallback {
  final Future<ScanResult> Function(String) callback;
  _ScannerCallback(this.callback);
}

/// Instance globale
final scannerManager = ScannerManager();
