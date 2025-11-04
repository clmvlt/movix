import 'package:flutter/foundation.dart';
import 'package:movix/API/api.dart';
import 'package:movix/Models/Command.dart';
import 'package:movix/Services/globals.dart';

void updateCommandState(Command command, VoidCallback onUpdate, bool online) {
  if (command.packages.isEmpty) {
    if (command.status.id == 1) {
    command.status.id = 2;
    } else {
      command.status.id = 3;
    }
    onUpdate();
    if (online) {
      API.setCommandState(command.id, command.status.id, comment: command.deliveryComment).then((res) {
        if (!res) {
          Globals.showSnackbar(
              "Impossible de mettre à jour le status de la commande ${command.id}.",
              backgroundColor: Globals.COLOR_MOVIX_RED);
        }
      });
    }
    return;
  }

  final packageStatuses = command.packages.values.map((p) => p.status.id);
  int saveId = command.status.id;

  bool allStatusesEqual(int status) =>
      packageStatuses.every((s) => s == status);
  bool anyStatusEqual(int status) => packageStatuses.any((s) => s == status);

  if (allStatusesEqual(3)) {
    command.status.id = 3; // Livré
  } else if (allStatusesEqual(2)) {
    command.status.id = 2; // Chargé
  } else if (allStatusesEqual(1)) {
    command.status.id = 1; // À enlever
  } else if (allStatusesEqual(6)) {
    command.status.id = 4; // non livré car anomalie
  } else if (allStatusesEqual(4)) {
    command.status.id = 4; // NON LIVRÉ
  } else if (allStatusesEqual(5)) {
    command.status.id = 7; // Non chargé - MANQUANT
  } else if (allStatusesEqual(8)) {
    command.status.id = 8; // non livré inaccessible
  } else if (allStatusesEqual(9)) {
    command.status.id = 9; // non livré instructions invalides
  } else if (anyStatusEqual(2) && anyStatusEqual(5)) {
    if (anyStatusEqual(3)) {
    command.status.id = 5; // livré incomplet
    } else {
    command.status.id = 6; // chargé incomplet
    }
  } else if (anyStatusEqual(3) && !allStatusesEqual(3)) {
    command.status.id = 5;
  } else if (anyStatusEqual(6) && !allStatusesEqual(6)) {
    command.status.id = 5; // livré incomplet car anomalie
  }

  onUpdate();
  if (online) {
    API.setCommandState(command.id, command.status.id, comment: command.deliveryComment).then((res) {
      if (!res) {
        command.status.id = saveId;
        onUpdate();
        Globals.showSnackbar(
            "Impossible de mettre à jour le status de la commande ${command.id}.",
            backgroundColor: Globals.COLOR_MOVIX_RED);
      }
    });
  }
}
