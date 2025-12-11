import 'package:flutter/material.dart';
import 'package:movix/Managers/PackageManager.dart';
import 'package:movix/Models/Command.dart';
import 'package:movix/Models/Sound.dart';
import 'package:movix/Services/globals.dart';

class CIPScanValidationWidget extends StatelessWidget {
  final Command command;
  final bool cipScanned;
  final VoidCallback onUpdate;
  final void Function(bool) onCipScannedChanged;

  const CIPScanValidationWidget({
    super.key,
    required this.command,
    required this.cipScanned,
    required this.onUpdate,
    required this.onCipScannedChanged,
  });

  Future<ScanResult> validateCode(String code) async {
    if (!cipScanned) {
      if (code == command.pharmacy.cip) {
        onCipScannedChanged(true);
        return ScanResult.SCAN_SUCCESS;
      }

      Globals.showSnackbar(
        'Veuillez scanner le CIP avant les colis.',
        backgroundColor: Globals.COLOR_MOVIX_RED,
        duration: const Duration(seconds: 1),
      );
      return ScanResult.SCAN_ERROR;
    }

    final package = command.packages[code];
    if (package == null) {
      Globals.showSnackbar(
        "Colis introuvable",
        backgroundColor: Globals.COLOR_MOVIX_RED,
        duration: const Duration(seconds: 1),
      );
      return ScanResult.SCAN_ERROR;
    }

    if (package.status.id == 3) {
      Globals.showSnackbar(
        "Déjà scanné",
        backgroundColor: Globals.COLOR_MOVIX_RED,
        duration: const Duration(seconds: 1),
      );
      return ScanResult.SCAN_ERROR;
    }

    setPackageStateOffline(command, package, 3, onUpdate);

    return _isAllScanned(command)
        ? ScanResult.SCAN_FINISH
        : ScanResult.SCAN_SUCCESS;
  }

  bool _isAllScanned(Command command) {
    for (var p in command.packages.values) {
      if (p.status.id != 3) return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Container(); // Widget logique sans UI
  }
}