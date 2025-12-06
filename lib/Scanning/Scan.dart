import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:movix/Models/Sound.dart';
import 'package:movix/Scanning/CameraScanner.dart';
import 'package:movix/Scanning/CameraScannerIOS.dart';
import 'package:movix/Scanning/DefaultScanner.dart';
import 'package:movix/Scanning/TextScanner.dart';
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
  @override
  void initState() {
    super.initState();
  }

  void handleResult(String code) async {
    ScanResult result = await widget.validateCode(code);

    // Vibration conditionnelle si activée
    if (Globals.VIBRATIONS_ENABLED) {
      if (result == ScanResult.SCAN_SUCCESS || result == ScanResult.SCAN_FINISH) {
        HapticFeedback.mediumImpact();
      } else if (result == ScanResult.SCAN_ERROR) {
        HapticFeedback.heavyImpact();
      }
    }

    await playSound(result);
  }

  @override
  Widget build(BuildContext context) {
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
      case ScanMode.Scanneur:
        scannerWidget = IntentScanner(
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
