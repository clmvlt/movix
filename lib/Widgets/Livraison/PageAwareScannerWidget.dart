import 'package:flutter/material.dart';
import 'package:movix/Models/Sound.dart';
import 'package:movix/Scanning/Scan.dart';
import 'package:movix/Services/scanner.dart';

class PageAwareScannerWidget extends StatefulWidget {
  final Future<ScanResult> Function(String) validateCode;
  final bool isPageActive;

  const PageAwareScannerWidget({
    super.key,
    required this.validateCode,
    this.isPageActive = true,
  });

  @override
  State<PageAwareScannerWidget> createState() => _PageAwareScannerWidgetState();
}

class _PageAwareScannerWidgetState extends State<PageAwareScannerWidget> 
    with WidgetsBindingObserver {

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    // Scanner lifecycle management
    final scanMode = await getScanMode();
    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      if (scanMode == ScanMode.Camera) {
        // Camera is paused automatically
      }
    } else if (state == AppLifecycleState.resumed) {
      if (scanMode == ScanMode.Camera) {
        // Camera is resumed automatically
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScannerWidget(
      validateCode: widget.validateCode,
      isActive: widget.isPageActive,
    );
  }
}