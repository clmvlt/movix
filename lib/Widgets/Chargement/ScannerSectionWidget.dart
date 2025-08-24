import 'package:flutter/material.dart';
import 'package:movix/Models/Sound.dart';
import 'package:movix/Scanning/Scan.dart';

class ScannerSectionWidget extends StatelessWidget {
  final Future<ScanResult> Function(String) validateCode;

  const ScannerSectionWidget({
    super.key,
    required this.validateCode,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
      ),
      child: ScannerWidget(
        validateCode: validateCode,
      ),
    );
  }
}