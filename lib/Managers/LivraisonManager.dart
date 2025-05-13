import 'dart:io';

import 'package:android_intent_plus/android_intent.dart';
import 'package:android_intent_plus/flag.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:movix/API/tour_fetcher.dart';
import 'package:movix/Managers/CommandManager.dart';
import 'package:movix/Managers/TourManager.dart';
import 'package:movix/Models/Command.dart';
import 'package:movix/Models/Package.dart';
import 'package:movix/Models/Tour.dart';
import 'package:movix/Managers/SpoolerManager.dart';
import 'package:movix/Services/globals.dart';
import 'package:movix/Models/Spooler.dart';
import 'package:movix/Services/location.dart';
import 'package:url_launcher/url_launcher.dart';

void ValidLivraisonAnomalie(
    List<String> photosBase64,
    String? selectedReasonCode,
    String other,
    String actions,
    Map<String, Package> packages) {
  final task = Spooler(url: "${Globals.API_URL}/anomalies/create", headers: {
    'Authorization': Globals.profil?.token ?? ""
  }, body: {
    'code': selectedReasonCode,
    'other': other,
    'actions': actions,
    'photos': photosBase64,
    'barcodes': packages.values.map((package) => package.barcode).toList()
  });
  final globalSpooler = SpoolerManager();
  globalSpooler.addTask(task);
}

void ValidLivraisonCommand(
    Command command, List<String> base64images, VoidCallback onUpdate) {
  final globalSpooler = SpoolerManager();
  final String token = Globals.profil?.token ?? "";
  const String apiUrl = Globals.API_URL;
  final String timestamp = Globals.getSqlDate();

  final List<Spooler> tasks = [];
  for (final base64image in base64images) {
    tasks.add(Spooler(
      url: "$apiUrl/addCommandPicture/${command.id}",
      headers: {'Authorization': token},
      body: {"base64": base64image},
    ));
  }

  updateCommandState(command, onUpdate, false);

  for (final Package p in command.packages.values) {
    if (p.idStatus == '5') continue;
    if (p.idStatus == '8' || p.idStatus == '9') {
      p.idStatus = '4';
    }
    tasks.add(Spooler(
      url: "$apiUrl/setPackageState/${p.barcode}",
      headers: {'Authorization': token},
      body: {
        "status": p.idStatus,
        "cip": command.cip,
        "created_at": timestamp,
      },
    ));
  }

  final locationService = locator<LocationService>();
  final location = locationService.currentLocation;

  tasks.add(Spooler(
    url: "$apiUrl/setCommandState/${command.id}",
    headers: {'Authorization': token},
    body: {
      "status": command.idStatus,
      "created_at": timestamp,
      "latitude": location?.latitude.toString() ?? "0",
      "longitude": location?.longitude.toString() ?? "0",
    },
  ));

  globalSpooler.addTasks(tasks);
  saveToursToHive();
}

Future<void> ValidLivraisonTour(
    BuildContext context, Tour tour, Function updateState) async {
  final globalSpooler = SpoolerManager();
  await globalSpooler.processQueue();
  if (globalSpooler.getTasksCount() > 0) {
    Globals.showSnackbar(
        'Impossible de valider la tourner car il reste des élements dans le spooler.',
        backgroundColor: Globals.COLOR_MOVIX_RED);
  } else {
    int? endkm = await askForKilometers(context);
    tour.endKm = endkm.toString();
    tour.totalKm = (int.parse(tour.endKm) - int.parse(tour.startKm)).toString();
    DateTime now = DateTime.now();
    String sqlDate = DateFormat('yyyy-MM-dd HH:mm:ss').format(now);
    tour.endDate = sqlDate;
    tour.idStatus = "4";
    saveToursToHive();

    bool res = await setTourData(tour.id, "endkm", tour.endKm);
    if (!res) {
      return Globals.showSnackbar(
          "Impossible de mettre à jour les endkm de la tournée",
          backgroundColor: Globals.COLOR_MOVIX_RED);
    }
    res = await setTourData(tour.id, "end_date", tour.endDate);
    if (!res) {
      return Globals.showSnackbar(
          "Impossible de mettre à jour le end_date de la tournée",
          backgroundColor: Globals.COLOR_MOVIX_RED);
    }
    res = await setTourState(tour.id, tour.idStatus);
    if (!res) {
      return Globals.showSnackbar(
          "Impossible de mettre à jour le status de la tournée",
          backgroundColor: Globals.COLOR_MOVIX_RED);
    }

    Globals.showSnackbar('La tournée a été validé',
        backgroundColor: Globals.COLOR_MOVIX_GREEN);

    updateState();
    context.go('/tours');
  }
}

Future<void> openMap({
  Command? command,
  double? latitude,
  double? longitude,
}) async {
  try {
    final double lat = latitude ?? double.parse(command!.pharmacyLatitude);

    final double lng = longitude ?? double.parse(command!.pharmacyLongitude);

    String app = Globals.MAP_APP;

    if (app == "Waze") {
      final wazeUri = Uri.parse('waze://?ll=$lat,$lng&navigate=yes');
      if (await canLaunchUrl(wazeUri)) {
        await launchUrl(wazeUri);
      } else {
        throw 'Impossible d\'ouvrir Waze.';
      }
    } else if (app == "Google Maps") {
      if (Platform.isAndroid) {
        final intent = AndroidIntent(
          action: 'action_view',
          data: 'google.navigation:q=$lat,$lng&mode=d',
          package: 'com.google.android.apps.maps',
          flags: <int>[Flag.FLAG_ACTIVITY_NEW_TASK],
        );
        await intent.launch();
      } else if (Platform.isIOS) {
        final googleMapsUrl = Uri.parse(
            'comgooglemaps://?daddr=$lat,$lng&directionsmode=driving');
        final appleMapsUrl =
            Uri.parse('http://maps.apple.com/?daddr=$lat,$lng&dirflg=d');

        if (await canLaunchUrl(googleMapsUrl)) {
          await launchUrl(googleMapsUrl);
        } else if (await canLaunchUrl(appleMapsUrl)) {
          await launchUrl(appleMapsUrl);
        } else {
          throw 'Aucune application de navigation disponible.';
        }
      }
    }
  } catch (e) {
    Globals.showSnackbar(e.toString());
  }
}

Future<String?> askForImmat(BuildContext context) async {
  TextEditingController immatController = TextEditingController();

  return showDialog<String>(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return WillPopScope(
        onWillPop: () async => false,
        child: AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
          title: const Text(
            "Immat du véhicule",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          content: TextField(
            controller: immatController,
            maxLength: 7,
            textCapitalization: TextCapitalization.characters,
            decoration: InputDecoration(
              hintText: "Ex : AB123XZ",
              counterText: "",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4),
                borderSide: const BorderSide(
                  color: Globals.COLOR_MOVIX,
                  width: 1.5,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4),
                borderSide: const BorderSide(
                  color: Globals.COLOR_MOVIX,
                  width: 2,
                ),
              ),
            ),
          ),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Globals.COLOR_MOVIX,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              onPressed: () {
                String immat = immatController.text.trim().toUpperCase();
                if (immat.isNotEmpty) {
                  Navigator.pop(context, immat);
                }
              },
              child: const Text(
                "Valider",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      );
    },
  );
}

Future<int?> askForKilometers(BuildContext context) async {
  TextEditingController kmController = TextEditingController();

  return showDialog<int>(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return WillPopScope(
        onWillPop: () async => false,
        child: AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
          title: const Text(
            "Entrer le kilométrage",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          content: TextField(
            controller: kmController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: "Ex : 132000",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4),
                borderSide: const BorderSide(
                  color: Globals.COLOR_MOVIX,
                  width: 1.5,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4),
                borderSide: const BorderSide(
                  color: Globals.COLOR_MOVIX,
                  width: 2,
                ),
              ),
            ),
          ),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Globals.COLOR_MOVIX,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              onPressed: () {
                String kmText = kmController.text.trim();
                int? km = int.tryParse(kmText);
                if (km != null) {
                  Navigator.pop(context, km);
                }
              },
              child: const Text(
                "Valider",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      );
    },
  );
}

bool isCommandValid(Command command) {
  for (var p in command.packages.values) {
    var s = p.idStatus;
    if (s != '3' && s != '4' && s != '5' && s != '6') return false;
  }
  return true;
}

bool isAllScanned(Command command) {
  for (var p in command.packages.values) {
    if (p.idStatus != '3') return false;
  }
  return true;
}

bool isTourComplet(Tour tour) {
  for (var command in tour.commands.values) {
    var s = command.idStatus;
    if (s != '3' && s != '4' && s != '5' && s != '7' && s != '8' && s != '9') {
      return false;
    }
  }
  return true;
}

int countValidCommands(Tour tour) {
  int count = 0;
  for (var command in tour.commands.values) {
    var s = command.idStatus;
    if (s == '3' || s == '4' || s == '5' || s == '8' || s == '9') {
      count++;
    }
  }
  return count;
}

int countTotalCommands(Tour tour) {
  int count = 0;
  for (var command in tour.commands.values) {
    if (command.idStatus != '7') {
      count++;
    }
  }
  return count;
}

void sendPharmacyInformations(String comment, bool invalidGeocodage,
    List<String> bases64, Command command) {
  final globalSpooler = SpoolerManager();
  final String token = Globals.profil?.token ?? "";
  const String apiUrl = Globals.API_URL;

  final task = Spooler(
    url: "$apiUrl/pharmacyinfos/create",
    headers: {'Authorization': token, 'Content-Type': 'application/json'},
    body: {
      "cip": command.cip,
      "commentaire": comment,
      "invalid_geocodage": invalidGeocodage,
      'photos': bases64,
    },
  );

  globalSpooler.addTask(task);
}
