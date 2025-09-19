import 'package:flutter/material.dart';
import 'package:movix/Services/globals.dart';
import 'package:movix/Scanning/Scan.dart';
import 'package:movix/Models/Sound.dart';

class ScannerSectionWidget extends StatelessWidget {
  final bool isPageActive;
  final Future<ScanResult> Function(String) validateCode;

  const ScannerSectionWidget({
    super.key,
    required this.isPageActive,
    required this.validateCode,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
      ),
      child: isPageActive
          ? ScannerWidget(validateCode: validateCode, isActive: isPageActive)
          : Container(
              height: 120,
              decoration: BoxDecoration(
                color: Globals.COLOR_SURFACE,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Globals.COLOR_TEXT_DARK.withOpacity(0.1),
                  width: 1,
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      color: Globals.COLOR_MOVIX,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Initialisation du scanner...',
                      style: TextStyle(
                        color: Globals.COLOR_TEXT_DARK,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}