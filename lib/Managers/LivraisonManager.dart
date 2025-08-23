import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:movix/API/tour_fetcher.dart';
import 'package:movix/Managers/CommandManager.dart';
import 'package:movix/Managers/SpoolerManager.dart';
import 'package:movix/Managers/TourManager.dart';
import 'package:movix/Models/Command.dart';
import 'package:movix/Models/Package.dart';
import 'package:movix/Models/Spooler.dart';
import 'package:movix/Models/Tour.dart';
import 'package:movix/Services/globals.dart';
import 'package:movix/Services/location.dart';
import 'package:url_launcher/url_launcher.dart';

void ValidLivraisonAnomalie(
    List<String> picturesBase64,
    String? selectedReasonCode,
    String other,
    String actions,
    Map<String, Package> packages,
    Command command) {
  final task = Spooler(
      url: "${Globals.API_URL}/anomalies",
      headers: {'Authorization': Globals.profil?.token ?? ""},
      body: {
        'cip': command.pharmacy.cip,
        'code': selectedReasonCode,
        'other': other,
        'actions': actions,
        'barcodes': packages.values.map((package) => package.barcode).toList(),
        'pictures': picturesBase64
            .asMap()
            .entries
            .map((entry) =>
                {'name': 'photo_${entry.key + 1}.jpg', 'base64': entry.value})
            .toList()
      },
      formType: 'post');
  final globalSpooler = SpoolerManager();
  globalSpooler.addTask(task);
}

void ValidLivraisonCommand(
    Command command, List<String> base64images, VoidCallback onUpdate) async {
  final globalSpooler = SpoolerManager();
  final String token = Globals.profil?.token ?? "";
  const String apiUrl = Globals.API_URL;
  final String timestamp = Globals.getSqlDate();

  final List<Spooler> tasks = [];
  for (final base64image in base64images) {
    tasks.add(Spooler(
      url: "$apiUrl/commands/${command.id}/picture",
      headers: {'Authorization': token},
      body: {
        "name": "photo_xx.jpg",
        "base64": base64image
      },
      formType: 'post',
    ));
  }

  updateCommandState(command, onUpdate, false);

  for (final Package p in command.packages.values) {
    if (p.status.id == 5) continue;
    if (p.status.id == 8 || p.status.id == 9) {
      p.status.id = 4;
    }
    tasks.add(Spooler(
      url: "$apiUrl/packages/state",
      headers: {'Authorization': token},
      body: {
        "packageBarcodes": [p.barcode],
        "statusId": p.status.id,
        "createdAt": timestamp
      },
      formType: 'put',
    ));
  }

  final locationService = locator<LocationService>();
  final location = locationService.currentLocation;

  tasks.add(Spooler(
    url: "$apiUrl/commands/state",
    headers: {'Authorization': token, "Content-Type": "application/json"},
    body: {
      "commandIds": [command.id],
      "statusId": command.status.id,
      "createdAt": timestamp,
      "latitude": location?.latitude ?? 0.0,
      "longitude": location?.longitude ?? 0.0,
    },
    formType: 'put',
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
    tour.endKm = endkm ?? 0;
    DateTime now = DateTime.now();
    String sqlDate = DateFormat('yyyy-MM-dd HH:mm:ss').format(now);
    tour.endDate = sqlDate;
    tour.status.id = 4;
    saveToursToHive();

    bool res = await setTourData(tour.id, {"endKm": tour.endKm});
    if (!res) {
      return Globals.showSnackbar(
          "Impossible de mettre à jour les endkm de la tournée",
          backgroundColor: Globals.COLOR_MOVIX_RED);
    }
    res = await setTourData(tour.id, {"endDate": tour.endDate});
    if (!res) {
      return Globals.showSnackbar(
          "Impossible de mettre à jour le end_date de la tournée",
          backgroundColor: Globals.COLOR_MOVIX_RED);
    }
    res = await setTourState(tour.id, tour.status.id);
    if (!res) {
      return Globals.showSnackbar(
          "Impossible de mettre à jour le status de la tournée",
          backgroundColor: Globals.COLOR_MOVIX_RED);
    }

    Globals.showSnackbar('La tournée a été validé',
        backgroundColor: Globals.COLOR_MOVIX_GREEN);

    updateState();
    GoRouter.of(context).go('/tours');
  }
}

Future<void> openMap({
  Command? command,
  double? latitude,
  double? longitude,
}) async {
  try {
    final double lat = latitude ?? command?.pharmacy.latitude ?? 0;
    final double lng = longitude ?? command?.pharmacy.longitude ?? 0;

    final String selectedApp = Globals.MAP_APP;

    if (lat == 0 || lng == 0) {
      Globals.showSnackbar('Aucune position disponible.',
          backgroundColor: Globals.COLOR_MOVIX_RED);
      return;
    }

    Uri? nativeUri;
    Uri? altNativeUri;
    Uri webUri = Uri.parse(
        'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng&travelmode=driving');

    if (Platform.isAndroid) {
      if (selectedApp == 'Waze') {
        nativeUri = Uri.parse('waze://?ll=$lat,$lng&navigate=yes');
        altNativeUri = Uri.parse('geo:$lat,$lng?q=$lat,$lng');
        webUri = Uri.parse('https://waze.com/ul?ll=$lat,$lng&navigate=yes');
      } else if (selectedApp == 'Google Maps') {
        nativeUri = Uri.parse('google.navigation:q=$lat,$lng&mode=d');
        altNativeUri = Uri.parse('geo:$lat,$lng?q=$lat,$lng');
        webUri = Uri.parse(
            'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng&travelmode=driving');
      } else {
        nativeUri = Uri.parse('geo:$lat,$lng?q=$lat,$lng');
      }
    } else if (Platform.isIOS) {
      if (selectedApp == 'Waze') {
        nativeUri = Uri.parse('waze://?ll=$lat,$lng&navigate=yes');
        webUri = Uri.parse('https://waze.com/ul?ll=$lat,$lng&navigate=yes');
      } else if (selectedApp == 'Google Maps') {
        nativeUri =
            Uri.parse('comgooglemaps://?daddr=$lat,$lng&directionsmode=driving');
        webUri = Uri.parse(
            'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng&travelmode=driving');
      } else {
        nativeUri = Uri.parse('maps://?daddr=$lat,$lng&dirflg=d');
        webUri = Uri.parse('https://maps.apple.com/?daddr=$lat,$lng&dirflg=d');
      }
    } else {
      // Web/Desktop fallback
      nativeUri = null;
      webUri = Uri.parse(
          'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng&travelmode=driving');
    }

    final List<Uri> attempts = [
      if (nativeUri != null) nativeUri,
      if (altNativeUri != null) altNativeUri,
      webUri,
    ];

    for (final uri in attempts) {
      try {
        final bool launched = await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
        if (launched) return;
      } catch (_) {
        // on essaie l'URI suivant
      }
    }

    throw Exception(
        'Aucune application/URL n\'a pu être ouverte. Plateforme: ${Platform.operatingSystem}, App: $selectedApp, Tentatives: ${attempts.map((u) => u.toString()).join(' | ')}');
  } catch (e) {
    Globals.showSnackbar(
      'Erreur lors de l\'ouverture de la carte: ${e.runtimeType}: ${e.toString()}',
      backgroundColor: Globals.COLOR_MOVIX_RED,
    );
  }
}

Future<String?> askForImmat(BuildContext context) async {
  TextEditingController immatController = TextEditingController();
  FocusNode focusNode = FocusNode();
  bool showError = false;

  return showDialog<String>(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          
          return PopScope(
            canPop: false,
            onPopInvokedWithResult: (didPop, result) {
              focusNode.unfocus();
            },
            child: Dialog(
              backgroundColor: Colors.transparent,
              elevation: 0,
              child: Container(
                constraints: const BoxConstraints(maxWidth: 400),
                decoration: BoxDecoration(
                  color: Globals.COLOR_SURFACE,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
                  child: Column(
                    children: [
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: Globals.COLOR_MOVIX.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(32),
                        ),
                        child: Icon(
                          Icons.local_shipping_outlined,
                          color: Globals.COLOR_MOVIX,
                          size: 32,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        "Immatriculation du véhicule",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          color: Globals.COLOR_TEXT_DARK,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Saisissez l'immatriculation de votre véhicule de livraison",
                        style: TextStyle(
                          fontSize: 14,
                          color: Globals.COLOR_TEXT_DARK.withOpacity(0.7),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      Container(
                        decoration: BoxDecoration(
                          color: Globals.COLOR_BACKGROUND,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Globals.COLOR_TEXT_DARK.withOpacity(0.1),
                            width: 1,
                          ),
                        ),
                        child: TextField(
                          controller: immatController,
                          focusNode: focusNode,
                          autofocus: true,
                          maxLength: 7,
                          textCapitalization: TextCapitalization.characters,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Globals.COLOR_TEXT_DARK,
                            letterSpacing: 2,
                          ),
                          decoration: InputDecoration(
                            hintText: "AB123XZ",
                            hintStyle: TextStyle(
                              color: Globals.COLOR_TEXT_DARK.withOpacity(0.5),
                              fontWeight: FontWeight.normal,
                              letterSpacing: 1,
                            ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 20,
                              horizontal: 16,
                            ),
                            counterText: "",
                          ),
                        ),
                      ),
                      if (showError) ...[
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: Globals.COLOR_MOVIX_RED.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: Globals.COLOR_MOVIX_RED.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.error_outline,
                                size: 16,
                                color: Globals.COLOR_MOVIX_RED,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                "Veuillez saisir une immatriculation",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Globals.COLOR_MOVIX_RED,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(
                        color: Globals.COLOR_TEXT_DARK.withOpacity(0.1),
                        width: 1,
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {
                              focusNode.unfocus();
                              Navigator.of(context).pop();
                              GoRouter.of(context).go('/tours');
                            },
                            borderRadius: const BorderRadius.only(
                              bottomLeft: Radius.circular(20),
                            ),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              child: Text(
                                "Fermer",
                                style: TextStyle(
                                  color: Globals.COLOR_TEXT_DARK.withOpacity(0.8),
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Container(
                        width: 1,
                        height: 56,
                        color: Globals.COLOR_TEXT_DARK.withOpacity(0.1),
                      ),
                      Expanded(
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {
                              String immat = immatController.text.trim().toUpperCase();
                              if (immat.isNotEmpty) {
                                focusNode.unfocus();
                                Navigator.pop(context, immat);
                              } else {
                                setState(() {
                                  showError = true;
                                });
                              }
                            },
                            borderRadius: const BorderRadius.only(
                              bottomRight: Radius.circular(20),
                            ),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              child: Text(
                                "Valider",
                                style: TextStyle(
                                  color: Globals.COLOR_TEXT_DARK,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      );
    },
  );
}

Future<int?> askForKilometers(BuildContext context) async {
  TextEditingController kmController = TextEditingController();
  FocusNode focusNode = FocusNode();

  return showDialog<int>(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) {
          focusNode.unfocus();
        },
        child: Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Container(
            constraints: const BoxConstraints(maxWidth: 400),
            decoration: BoxDecoration(
              color: Globals.COLOR_SURFACE,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
                  child: Column(
                    children: [
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: Globals.COLOR_MOVIX.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(32),
                        ),
                        child: Icon(
                          Icons.speed_outlined,
                          color: Globals.COLOR_MOVIX,
                          size: 32,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        "Kilométrage du véhicule",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          color: Globals.COLOR_TEXT_DARK,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Saisissez le kilométrage actuel de votre véhicule",
                        style: TextStyle(
                          fontSize: 14,
                          color: Globals.COLOR_TEXT_DARK.withOpacity(0.7),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      Container(
                        decoration: BoxDecoration(
                          color: Globals.COLOR_BACKGROUND,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Globals.COLOR_TEXT_DARK.withOpacity(0.1),
                            width: 1,
                          ),
                        ),
                        child: TextField(
                          controller: kmController,
                          focusNode: focusNode,
                          autofocus: true,
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Globals.COLOR_TEXT_DARK,
                            letterSpacing: 1,
                          ),
                          decoration: InputDecoration(
                            hintText: "132000",
                            hintStyle: TextStyle(
                              color: Globals.COLOR_TEXT_DARK.withOpacity(0.5),
                              fontWeight: FontWeight.normal,
                              letterSpacing: 0.5,
                            ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 20,
                              horizontal: 16,
                            ),
                            suffixText: "km",
                            suffixStyle: TextStyle(
                              color: Globals.COLOR_TEXT_DARK.withOpacity(0.6),
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(
                        color: Globals.COLOR_TEXT_DARK.withOpacity(0.1),
                        width: 1,
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {
                              focusNode.unfocus();
                              Navigator.of(context).pop();
                              GoRouter.of(context).go('/tours');
                            },
                            borderRadius: const BorderRadius.only(
                              bottomLeft: Radius.circular(20),
                            ),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              child: Text(
                                "Fermer",
                                style: TextStyle(
                                  color: Globals.COLOR_TEXT_DARK.withOpacity(0.8),
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Container(
                        width: 1,
                        height: 56,
                        color: Globals.COLOR_TEXT_DARK.withOpacity(0.1),
                      ),
                      Expanded(
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {
                              String kmText = kmController.text.trim();
                              int? km = int.tryParse(kmText);
                              if (km != null) {
                                focusNode.unfocus();
                                Navigator.pop(context, km);
                              }
                            },
                            borderRadius: const BorderRadius.only(
                              bottomRight: Radius.circular(20),
                            ),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              child: Text(
                                "Valider",
                                style: TextStyle(
                                  color: Globals.COLOR_TEXT_DARK,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

bool isCommandValid(Command command) {
  for (var p in command.packages.values) {
    var s = p.status.id;
    if (s != 3 && s != 4 && s != 5 && s != 6) return false;
  }
  return true;
}

bool isAllScanned(Command command) {
  for (var p in command.packages.values) {
    if (p.status.id != 3) return false;
  }
  return true;
}

bool isTourComplet(Tour tour) {
  for (var command in tour.commands.values) {
    var s = command.status.id;
    if (s != 3 && s != 4 && s != 5 && s != 7 && s != 8 && s != 9) {
      return false;
    }
  }
  return true;
}

int countValidCommands(Tour tour) {
  int count = 0;
  for (var command in tour.commands.values) {
    var s = command.status.id;
    if (s == 3 || s == 4 || s == 5 || s == 8 || s == 9) {
      count++;
    }
  }
  return count;
}

int countTotalCommands(Tour tour) {
  int count = 0;
  for (var command in tour.commands.values) {
    if (command.status.id != 7) {
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
    url: "$apiUrl/pharmacy-infos",
    headers: {'Authorization': token},
    body: {
      "cip": command.pharmacy.cip,
      "commentaire": comment,
      "invalidGeocodage": invalidGeocodage,
      'pictures': bases64
            .asMap()
            .entries
            .map((entry) =>
                {'name': 'photo_${entry.key + 1}.jpg', 'base64': entry.value})
            .toList()
    },
    formType: 'post',
  );

  globalSpooler.addTask(task);
}
