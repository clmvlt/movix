import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:movix/Managers/PackageManager.dart';
import 'package:movix/Models/PackageSearcher.dart';
import 'package:movix/Models/Sound.dart';
import 'package:movix/Models/Tour.dart';
import 'package:movix/Managers/ChargementManager.dart';
import 'package:movix/Widgets/CustomButton.dart';
import 'package:movix/Models/Command.dart';
import 'package:movix/Models/Package.dart';
import 'package:movix/Services/affichage.dart';
import 'package:movix/Services/globals.dart';

import 'package:movix/Widgets/AnomalieMenu.dart';
import 'package:movix/Widgets/ScannerWidget.dart';

class FSChargementPage extends StatefulWidget {
  final Tour tour;
  final Command command;
  final PackageSearcher packageSearcher;
  final VoidCallback onUpdate;

  const FSChargementPage({
    super.key,
    required this.tour,
    required this.command,
    required this.packageSearcher,
    required this.onUpdate,
  });

  @override
  _FSChargementPageState createState() => _FSChargementPageState();
}

class _FSChargementPageState extends State<FSChargementPage> {
  String inputLog = "";
  late List<String> listIds = [];
  int currentIndex = 0;
  late Command command;

  void onUpdate() {
    setState(() {});
    widget.onUpdate();
  }

  void validerTousLesColis(Command command) {
    if (!kDebugMode) return;
    for (var package in command.packages.values) {
      setPackageState(command, package, '2', onUpdate);
    }
  }

  Future<ScanResult> validateCode(String code) async {
    Package? package =
        widget.packageSearcher.getPackageByBarcode(widget.command, code);
    if (package == null) {
      Globals.showSnackbar("Colis introuvable",
          backgroundColor: Globals.COLOR_MOVIX_RED);
      return ScanResult.SCAN_ERROR;
    }

    Command? command = widget.tour.commands[package.idCommand];
    if (command == null || package.idStatus == '2') {
      if (package.idStatus == '2') {
        Globals.showSnackbar("Déjà scanné",
            backgroundColor: Globals.COLOR_MOVIX_RED);
      }
      return ScanResult.SCAN_ERROR;
    }

    if (package.idCommand != this.command.id) {
      ScanResult result = await selectCommand(command);
      if (result == ScanResult.SCAN_SWITCH) {
        setPackageState(command, package, "2", onUpdate);
      }

      if (isAllScanned(command)) {
        return ScanResult.SCAN_FINISH;
      }

      return result;
    }

    setPackageState(command, package, "2", onUpdate);

    return isAllScanned(command)
        ? ScanResult.SCAN_FINISH
        : Globals.isScannerMode
            ? ScanResult.NOTHING
            : ScanResult.SCAN_SUCCESS;
  }

  Future<ScanResult> selectCommand(Command command) async {
    if (!isChargementCommandUncomplet(this.command)) {
      currentIndex = listIds.indexOf(command.id);
      setState(() => this.command = command);
      return ScanResult.SCAN_SWITCH;
    }

    bool? confirmation = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) => getColisConfirm(context),
    );

    if (confirmation == true) {
      for (var package in this.command.packages.values) {
        if (package.idStatus == "1") {
          setPackageState(this.command, package, "5", onUpdate);
        }
      }

      setState(() {
        currentIndex = listIds.indexOf(command.id);
        this.command = command;
      });

      return ScanResult.SCAN_SWITCH;
    }

    return ScanResult.NOTHING;
  }

  void navigateToCommand(int index) async {
    if (index >= 0 && index < widget.tour.commands.length) {
      Command nextCommand = widget.tour.commands[listIds[index]]!;
      selectCommand(nextCommand);
    }
  }

  @override
  void initState() {
    super.initState();
    command = widget.command;

    listIds = widget.tour.commands.keys.toList();
    currentIndex = listIds.indexOf(command.id);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (isChargementCommandUncomplet(command)) {
          bool? shouldLeave = await showDialog<bool>(
            context: context,
            builder: (BuildContext context) => getColisConfirm(context),
          );

          if (shouldLeave ?? false) {
            for (var package in command.packages.values) {
              if (package.idStatus == "1") {
                setPackageState(command, package, "5", onUpdate);
              }
            }
          }

          return shouldLeave ?? false;
        }
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          toolbarTextStyle: Globals.appBarTextStyle,
          titleTextStyle: Globals.appBarTextStyle,
          title: Text(
              '${widget.tour.commands.length - currentIndex}/${widget.tour.commands.length}'),
          backgroundColor: Globals.COLOR_MOVIX,
          foregroundColor: Colors.white,
        ),
        body: Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Stack(
                      children: [
                        
                        Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          color: Colors.white,
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    GetChargementIconCommandStatus(command, 18),
                                    const SizedBox(width: 6),
                                    Expanded(
                                        child: Text(
                                      command.pharmacyName,
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 2,
                                    )),
                                    if (command.pNew) ...[
                                      const SizedBox(width: 5),
                                      newBadge(),
                                    ],
                                  ],
                                ),
                                const SizedBox(height: 4),
                                // STATUS ICON
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        "${command.pharmacyAddress1} ${command.pharmacyAddress2} ${command.pharmacyAddress3}"
                                            .trim(),
                                        style: const TextStyle(
                                            fontSize: 12,
                                            color: Colors.black54),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  command.pharmacyCity,
                                  style: const TextStyle(
                                      fontSize: 12, color: Colors.black54),
                                ),
                                const SizedBox(height: 12),
                                // PACKAGES LIST
                                command.packages.isNotEmpty
                                    ? ListView.builder(
                                        shrinkWrap: true,
                                        itemCount: command.packages.length,
                                        itemBuilder: (context, index) {
                                          final package = command
                                              .packages.values
                                              .elementAt(index);
                                          final zoneName =
                                              package.zoneName.isEmpty
                                                  ? '00'
                                                  : package.zoneName;
                                          final freshEmote =
                                              package.fresh == 't' ? '❄️' : '';
                                          final barcodeText =
                                              '${package.barcode} ${getColisEmote(package.type)}$freshEmote';

                                          return Padding(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 4.0),
                                            child: Row(
                                              children: [
                                                getIconPackageStatus(
                                                    package, 16),
                                                const SizedBox(width: 8),
                                                Expanded(
                                                  child: Text(
                                                    barcodeText,
                                                    style: const TextStyle(
                                                        fontSize: 12),
                                                  ),
                                                ),
                                                Text(
                                                  zoneName,
                                                  style: const TextStyle(
                                                      fontSize: 12,
                                                      color: Colors.black54),
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                      )
                                    : const Text(
                                        'Aucun package disponible',
                                        style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.black54),
                                      ),

                                const Divider(height: 24),
                                Row(
                                  children: [
                                    Align(
                                      alignment: Alignment.centerLeft,
                                      child: customToolButton(
                                        color: Globals.COLOR_MOVIX_RED,
                                        onPressed: () {
                                          ShowChargementAnomalieManu(
                                              context, command, onUpdate);
                                        },
                                        iconData: FontAwesomeIcons.xmark,
                                        text: "Non chargé",
                                      ),
                                    ),
                                    if (kDebugMode)
                                      Align(
                                        alignment: Alignment.centerLeft,
                                        child: customToolButton(
                                          color: Globals.COLOR_MOVIX_YELLOW,
                                          onPressed: () {
                                            validerTousLesColis(command);
                                          },
                                          iconData: FontAwesomeIcons.xmark,
                                          text: "DEBUG VALIDE",
                                        ),
                                      ),
                                  ],
                                )
                              ],
                            ),
                          ),
                        ),
                        Positioned(
                          top: 0,
                          right: 0,
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Text("${PackageSearcher.countPackageStatusInCommand(command)['2']}/${command.packages.length}",
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: ScannerWidget(validateCode: validateCode),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, size: 50),
                    onPressed: currentIndex < widget.tour.commands.length - 1
                        ? () => navigateToCommand(currentIndex + 1)
                        : null,
                  ),
                  IconButton(
                    icon: const Icon(Icons.arrow_forward, size: 50),
                    onPressed: currentIndex > 0
                        ? () => navigateToCommand(currentIndex - 1)
                        : null,
                  ),
                ],
              ),
            ),
            if (isChargementComplet(widget.tour))
              customButton(
                label: "Valider le chargement",
                onPressed: () {
                  context.go('/tour/validateChargement', extra: {
                    'packageSearcher': widget.packageSearcher,
                    'tour': widget.tour
                  });
                },
              ),
          ],
        ),
      ),
    );
  }
}
