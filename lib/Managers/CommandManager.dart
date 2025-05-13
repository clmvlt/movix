import 'package:flutter/foundation.dart';
import 'package:movix/API/api.dart';
import 'package:movix/Models/Command.dart';
import 'package:movix/Services/globals.dart';

void updateCommandState(Command command, VoidCallback onUpdate, bool online) {
  final packageStatuses = command.packages.values.map((p) => p.idStatus);
  String saveId = command.idStatus;

  bool allStatusesEqual(String status) =>
      packageStatuses.every((s) => s == status);
  bool anyStatusEqual(String status) => packageStatuses.any((s) => s == status);

  if (allStatusesEqual('3')) {
    command.idStatus = '3'; // Livré
  } else if (allStatusesEqual('2')) {
    command.idStatus = '2'; // Chargé
  } else if (allStatusesEqual('1')) {
    command.idStatus = '1'; // À enlever
  } else if (allStatusesEqual('6')) {
    command.idStatus = '4'; // non livré car anomalie
  } else if (allStatusesEqual('4')) {
    command.idStatus = '4'; // NON LIVRÉ
  } else if (allStatusesEqual('5')) {
    command.idStatus = '7'; // Non chargé - MANQUANT
  } else if (allStatusesEqual('8')) {
    command.idStatus = '8'; // non livré inaccessible
  } else if (allStatusesEqual('9')) {
    command.idStatus = '9'; // non livré instructions invalides
  } else if (anyStatusEqual('2') && anyStatusEqual('5')) {
    command.idStatus = '6'; // chargé incomplet
  } else if (anyStatusEqual('3') && !allStatusesEqual('3')) {
    command.idStatus = '5'; // livré incomplet
  } else if (anyStatusEqual('6') && !allStatusesEqual('6')) {
    command.idStatus = '5'; // livré incomplet car anomalie
  }

  onUpdate();
  if (online) {
    API.setCommandState(command.id, command.idStatus).then((res) {
      if (!res) {
        command.idStatus = saveId;
        onUpdate();
        Globals.showSnackbar(
            "Impossible de mettre à jour le status de la commande ${command.id}.",
            backgroundColor: Globals.COLOR_MOVIX_RED);
      }
    });
  }
}
