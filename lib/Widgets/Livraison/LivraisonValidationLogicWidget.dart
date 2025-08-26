import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
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

    if (!_isCommandValid(command)) {
      final result = await showDialog<Map<String, dynamic>>(
        context: context,
        builder: getColisConfirm,
      );

      if (result == null || result['confirmed'] != true) return;

      // Enregistrer le commentaire dans la commande
      final comment = result['comment'] as String?;
      if (comment != null && comment.isNotEmpty) {
        command.deliveryComment = comment;
      }

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

  static bool _isCommandValid(Command command) {
    for (var p in command.packages.values) {
      var s = p.status.id;
      if (s != 3 && s != 4 && s != 5 && s != 6) return false;
    }
    return true;
  }
}