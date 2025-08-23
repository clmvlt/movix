import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:movix/API/tour_fetcher.dart';
import 'package:movix/Managers/LivraisonManager.dart';
import 'package:movix/Managers/TourManager.dart';
import 'package:movix/Models/Command.dart';
import 'package:movix/Models/Tour.dart';
import 'package:movix/Services/globals.dart';

Future<Map<String, dynamic>> validateChargement(Tour tour, VoidCallback update) async {
  final Map<String, dynamic> result = await validateLoading(tour);

  if (result['success'] == true) {
    tour.status.id = 3;
    update();

    DateTime now = DateTime.now();
    String sqlDate = DateFormat('yyyy-MM-dd HH:mm:ss').format(now);
    await setTourData(tour.id, {"startDate": sqlDate});

    await saveToursToHive();

    Globals.showSnackbar('Chargement réussi.',
        backgroundColor: Globals.COLOR_MOVIX_GREEN);

    return {'success': true, 'errors': ''};
  } else {
    await saveToursToHive();
    return {
      'success': false,
      'errors': result['errors'] ?? "xx"
    };
  }
}


bool isAllScanned(Command command) {
  // Si la commande n'a aucun package, elle est considérée comme validée automatiquement
  if (command.packages.isEmpty) {
    return true;
  }
  
  for (var p in command.packages.values) {
    if (p.status.id != 2) return false;
  }
  return true;
}

bool isChargementComplet(Tour tour) {
  return tour.commands.values.every((command) =>
      command.status.id == 2 ||
      command.status.id == 6 ||
      command.status.id == 7);
}

bool isChargementCommandUncomplet(Command command) {
  bool hasScannedPackages =
      command.packages.values.any((p) => p.status.id == 1);
  bool hasUnscannedPackages =
      command.packages.values.any((p) => p.status.id != 1);

  return hasScannedPackages && hasUnscannedPackages;
}

Future<void> showDialogs(BuildContext context, Tour tour) async {
  await Future<void>.delayed(Duration.zero);

  if (tour.immat == "") {
    String? immat = await askForImmat(context);
    if (immat == null) {
      // User closed the immat popup with "Fermer" button - don't continue
      return;
    }
    if (immat.isNotEmpty) {
      setTourData(tour.id, {"immat": immat});
      tour.immat = immat;
      saveToursToHive();
    }
  }

  if (tour.startKm == 0) {
    int? startKm = await askForKilometers(context) ?? 0;
    setTourData(tour.id, {"startKm": startKm});
    tour.startKm = startKm;
    saveToursToHive();
  }
}

// 2 = Chargé, 6 = Chargé incomplet, 7 = Non chargé manquant
int countValidCommands(Tour tour) {
  int count = 0;
  for (var command in tour.commands.values) {
    if (command.status.id == 2 ||
        command.status.id == 6 ||
        command.status.id == 7) {
      count++;
    }
  }
  return count;
}
