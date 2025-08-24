import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:movix/Managers/LivraisonManager.dart';
import 'package:movix/Managers/PackageManager.dart';
import 'package:movix/Models/Command.dart';
import 'package:movix/Services/globals.dart';
import 'package:movix/Services/affichage.dart';

class LivraisonValidationLogicWidget {
  static Future<void> confirmValidation({
    required BuildContext context,
    required Command command,
    required bool cipScanned,
    required VoidCallback onUpdate,
  }) async {
    if (!cipScanned) {
      Globals.showSnackbar(
        "Veuillez scanner le CIP",
        backgroundColor: Globals.COLOR_MOVIX_RED,
      );
      return;
    }

    if (!isCommandValid(command)) {
      final confirmation = await showDialog<bool>(
        context: context,
        builder: getColisConfirm,
      );

      if (confirmation != true) return;

      for (final package in command.packages.values) {
        if (package.status.id != 3) {
          setPackageStateOffline(command, package, 4, onUpdate);
        }
      }
    }

    if (context.mounted) {
      context.push('/tour/validateLivraison', extra: {
        'command': command,
        'onUpdate': onUpdate,
      });
    }
  }
}