import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:movix/API/tour_fetcher.dart';
import 'package:movix/Managers/LivraisonManager.dart';
import 'package:movix/Managers/TourManager.dart';
import 'package:movix/Models/Command.dart';
import 'package:movix/Models/Tour.dart';
import 'package:movix/Services/globals.dart';

Future<bool> validateChargement(Tour tour, Function update,
    {List<String>? errors}) async {
  if (tour.startDate == "") {
    DateTime now = DateTime.now();
    String sqlDate = DateFormat('yyyy-MM-dd HH:mm:ss').format(now);
    setTourData(tour.id, "start_date", sqlDate);
  }

  final List<String> localErrors = [];
  final Map<String, dynamic> result = await validateLoading(tour);

  if (result['status'] == 'success') {
    tour.idStatus = "3";
    update();
    Globals.showSnackbar('Chargement réussi.',
        backgroundColor: Globals.COLOR_MOVIX_GREEN);
    if (errors != null) errors.clear();

    saveToursToPreferences();
    return true;
  } else {
    if (result['errors'] != null && result['errors'] is List) {
      for (var err in result['errors']) {
        String message = 'Erreur';
        if (err['id_command'] != null) {
          message = 'Commande ${err['id_command']}';
          if (err['barcode'] != null) {
            message += ' - Colis ${err['barcode']}';
          }
        }
        if (err['error'] != null) {
          message += ' : ${err['error']}';
        }
        localErrors.add(message);
      }
    } else {
      localErrors.add('Une erreur est survenue lors de la validation.');
    }

    if (errors != null) {
      errors.clear();
      errors.addAll(localErrors);
    }

    saveToursToPreferences();
    return false;
  }
}

bool isAllScanned(Command command) {
  for (var p in command.packages.values) {
    if (p.idStatus != '2' ) return false;
  }
  return true;
}

bool isChargementComplet(Tour tour) {
  return tour.commands.values.every((command) =>
      command.idStatus == "2" ||
      command.idStatus == "6" ||
      command.idStatus == "7");
}

bool isChargementCommandUncomplet(Command command) {
  bool hasScannedPackages =
      command.packages.values.any((p) => p.idStatus == '1');
  bool hasUnscannedPackages =
      command.packages.values.any((p) => p.idStatus != '1');

  return hasScannedPackages && hasUnscannedPackages;
}

Future<void> showDialogs(BuildContext context, Tour tour) async {
  await Future.delayed(Duration.zero);

  if (tour.immat == "") {
    String? immat = await askForImmat(context) ?? "";
    setTourData(tour.id, "immat", immat);
    tour.immat = immat;
  }

  if (tour.startKm == '0' || tour.startKm == '') {
    String? startKm = (await askForKilometers(context)).toString();
    setTourData(tour.id, "startkm", startKm);
    tour.startKm = startKm;
  }
}

// 2 = Chargé, 6 = Chargé incomplet, 7 = Non chargé manquant
int countValidCommands(Tour tour) {
  int count = 0;
  for (var command in tour.commands.values) {
    if (command.idStatus == "2" ||
        command.idStatus == "6" ||
        command.idStatus == "7") {
      count++;
    }
  }
  return count;
}
