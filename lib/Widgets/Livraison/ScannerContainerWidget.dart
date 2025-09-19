import 'package:flutter/material.dart';
import 'package:movix/Models/Sound.dart';
import 'package:movix/Scanning/Scan.dart';

class ScannerContainerWidget extends StatelessWidget {
  final Future<ScanResult> Function(String) validateCode;
  final EdgeInsetsGeometry? margin;
  final bool isActive;

  const ScannerContainerWidget({
    super.key,
    required this.validateCode,
    this.margin,
    this.isActive = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin ?? const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
      ),
      child: ScannerWidget(
        validateCode: validateCode,
        isActive: isActive,
      ),
    );
  }
}