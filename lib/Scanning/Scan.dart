import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:movix/Models/Sound.dart';
import 'package:movix/Scanning/CameraScanner.dart';
import 'package:movix/Scanning/CameraScannerIOS.dart';
import 'package:movix/Scanning/DefaultScanner.dart';
import 'package:movix/Scanning/ScannerManager.dart';
import 'package:movix/Scanning/TextScanner.dart';
import 'package:movix/Scanning/ZebraScanner.dart';
import 'package:movix/Services/globals.dart';
import 'package:movix/Services/scanner.dart';
import 'package:movix/Services/sound.dart';

class ScannerWidget extends StatefulWidget {
  final Future<ScanResult> Function(String) validateCode;
  final bool isActive;

  const ScannerWidget({
    super.key,
    required this.validateCode,
    this.isActive = true,
  });

  @override
  State<ScannerWidget> createState() => _ScannerWidgetState();
}

class _ScannerWidgetState extends State<ScannerWidget> {
  bool _isTop = false;

  @override
  void initState() {
    super.initState();
    scannerManager.addListener(_onManagerChanged);
    // Enregistrer le callback dans le manager
    scannerManager.pushCallback(widget.validateCode);
    _updateIsTop();
  }

  @override
  void dispose() {
    scannerManager.removeListener(_onManagerChanged);
    // Retirer le callback du manager
    scannerManager.popCallback(widget.validateCode);
    super.dispose();
  }

  @override
  void didUpdateWidget(ScannerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Si le callback change, mettre à jour le manager
    if (oldWidget.validateCode != widget.validateCode) {
      scannerManager.popCallback(oldWidget.validateCode);
      scannerManager.pushCallback(widget.validateCode);
      _updateIsTop();
    }
  }

  void _onManagerChanged() {
    _updateIsTop();
  }

  void _updateIsTop() {
    final isTop = scannerManager.isTopCallback(widget.validateCode);
    if (isTop != _isTop) {
      setState(() {
        _isTop = isTop;
      });
    }
  }

  void handleResult(String code) async {
    // Utiliser le callback actif du manager
    ScanResult result = await scannerManager.handleScan(code);

    // Vibration conditionnelle selon le résultat
    if (Globals.VIBRATIONS_ENABLED) {
      switch (result) {
        case ScanResult.SCAN_SUCCESS:
          // Vibration légère pour succès
          HapticFeedback.mediumImpact();
          break;
        case ScanResult.SCAN_FINISH:
          // Double vibration pour indiquer la fin
          HapticFeedback.heavyImpact();
          await Future<void>.delayed(const Duration(milliseconds: 100));
          HapticFeedback.heavyImpact();
          break;
        case ScanResult.SCAN_ERROR:
          // Triple vibration rapide pour erreur
          HapticFeedback.heavyImpact();
          await Future<void>.delayed(const Duration(milliseconds: 80));
          HapticFeedback.heavyImpact();
          await Future<void>.delayed(const Duration(milliseconds: 80));
          HapticFeedback.heavyImpact();
          break;
        case ScanResult.SCAN_SWITCH:
          // Vibration douce pour changement de contexte
          HapticFeedback.lightImpact();
          break;
        case ScanResult.NOTHING:
          // Pas de vibration
          break;
      }
    }

    await playSound(result);
  }

  @override
  Widget build(BuildContext context) {
    // Si ce n'est pas le scanner au premier plan, ne pas l'afficher
    if (!_isTop) {
      return const SizedBox.shrink();
    }

    Widget? scannerWidget;

    switch (Globals.SCAN_MODE) {
      case ScanMode.Camera:
      if (Platform.isIOS) {
        scannerWidget = CameraScannerIOS(
          onScanResult: handleResult,
        );
      } else {
        scannerWidget = CameraScanner(
          onScanResult: handleResult,
        );
      }
        break;
      case ScanMode.DT50:
        scannerWidget = IntentScanner(
          onScanResult: handleResult,
          isActive: widget.isActive,
        );
        break;
      case ScanMode.Zebra:
        scannerWidget = ZebraScanner(
          onScanResult: handleResult,
          isActive: widget.isActive,
        );
        break;
      case ScanMode.Text:
        scannerWidget = TextScanner(
          onScanResult: handleResult,
        );
        break;
    }

    return scannerWidget;
  }
}
