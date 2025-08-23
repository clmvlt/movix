import 'dart:io';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:movix/Managers/ChargementManager.dart';
import 'package:movix/Managers/PackageManager.dart';
import 'package:movix/Models/Command.dart';
import 'package:movix/Models/Package.dart';
import 'package:movix/Models/PackageSearcher.dart';
import 'package:movix/Models/Sound.dart';
import 'package:movix/Models/Tour.dart';
import 'package:movix/Scanning/Scan.dart';
import 'package:movix/Services/affichage.dart';
import 'package:movix/Services/globals.dart';
import 'package:movix/Widgets/AnomalieMenu.dart';
import 'package:movix/Widgets/CommandWidget.dart';
import 'package:movix/Widgets/PackagesWidget.dart';

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

  Future<ScanResult> validateCode(String code) async {
    Package? package =
        widget.packageSearcher.getPackageByBarcode(widget.command, code);
    if (package == null) {
      Globals.showSnackbar("Colis introuvable",
          backgroundColor: Globals.COLOR_MOVIX_RED);
      return ScanResult.SCAN_ERROR;
    }

    Command? command = widget.tour.commands[package.commandId];
    if (command == null || package.status.id == 2) {
      if (package.status.id == 2) {
        Globals.showSnackbar("Déjà scanné",
            backgroundColor: Globals.COLOR_MOVIX_RED);
      }
      return ScanResult.SCAN_ERROR;
    }

    if (package.commandId != this.command.id) {
      ScanResult result = await selectCommand(command);
      if (result == ScanResult.SCAN_SWITCH) {
        setPackageState(command, package, 2, onUpdate);
      }

      if (isAllScanned(command)) {
        return ScanResult.SCAN_FINISH;
      }

      return result;
    }

    setPackageState(command, package, 2, onUpdate);

    return isAllScanned(command)
        ? ScanResult.SCAN_FINISH
        : ScanResult.SCAN_SUCCESS;
  }

  Future<ScanResult> selectCommand(Command command) async {
    if (!isChargementCommandUncomplet(this.command)) {
      setState(() {
        currentIndex = listIds.indexOf(command.id);
        this.command = command;
      });
      return ScanResult.SCAN_SWITCH;
    }

    bool? confirmation = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) => getColisConfirm(context),
    );

    if (confirmation == true) {
      for (var package in this.command.packages.values) {
        if (package.status.id == 1) {
          setPackageState(this.command, package, 5, onUpdate);
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

  Widget _buildModernCommandCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          decoration: BoxDecoration(
            color: Globals.COLOR_SURFACE,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Globals.COLOR_TEXT_GRAY.withOpacity(0.3),
              width: 2,
            ),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              customCardHeader(command, false, true),
                              const SizedBox(height: 6),
                              customCity(command),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                decoration: BoxDecoration(
                  color: Globals.COLOR_SURFACE_SECONDARY.withOpacity(0.5),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                ),
                child: Column(
                  children: [
                    const Divider(height: 1),
                    const SizedBox(height: 16),
                    CustomListePackages(
                      command: command,
                      isLivraison: false,
                    ),
                    const SizedBox(height: 20),
                    _buildModernActionButton(
                      label: "Non chargé",
                      size: 12,
                      icon: FontAwesomeIcons.xmark,
                      color: Globals.COLOR_MOVIX_RED,
                      onPressed: () {
                        ShowChargementAnomalieManu(
                          context, command, onUpdate);
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModernActionButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
    double size = 12
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
      ),
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 18),
        label: Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: size,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
      ),
    );
  }

  Widget _buildModernNavigationButton({
    required IconData icon,
    required VoidCallback? onPressed,
    required bool isEnabled,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onPressed,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isEnabled 
                  ? Globals.COLOR_MOVIX
                  : Globals.COLOR_TEXT_SECONDARY.withOpacity(0.3),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              icon,
              color: isEnabled 
                  ? Colors.white
                  : Globals.COLOR_TEXT_SECONDARY,
              size: 24,
            ),
          ),
        ),
      ),
    );
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
              if (package.status.id == 1) {
                setPackageState(command, package, 5, onUpdate);
              }
            }
          }

          return shouldLeave ?? false;
        }
        return true;
      },
      child: Scaffold(
        backgroundColor: Globals.COLOR_BACKGROUND,
        appBar: AppBar(
          toolbarTextStyle: Globals.appBarTextStyle,
          titleTextStyle: Globals.appBarTextStyle,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.tour.name,
                style: TextStyle(
                  color: Globals.COLOR_TEXT_LIGHT,
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                ),
              ),
              Text(
                'Scanner les colis',
                style: TextStyle(
                  color: Globals.COLOR_TEXT_LIGHT.withOpacity(0.8),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          backgroundColor: Globals.COLOR_MOVIX,
          foregroundColor: Globals.COLOR_TEXT_LIGHT,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios, color: Globals.COLOR_TEXT_LIGHT),
            onPressed: () {
              context.pop();
            },
          ),
          actions: [
            Container(
              margin: const EdgeInsets.only(right: 16),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                '${widget.tour.commands.length - currentIndex}/${widget.tour.commands.length}',
                style: TextStyle(
                  color: Globals.COLOR_TEXT_LIGHT,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
        body: Stack(
          fit: StackFit.expand,
          children: [
            SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: ScannerWidget(
                      validateCode: validateCode
                    ),
                  ),
                  _buildModernCommandCard(),
                  const SizedBox(height: 120),
                ],
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: Platform.isIOS ? 16 : 0,
              child: Container(
                margin: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _buildModernNavigationButton(
                      icon: Icons.arrow_back_ios,
                      onPressed: currentIndex < widget.tour.commands.length - 1
                          ? () => navigateToCommand(currentIndex + 1)
                          : null,
                      isEnabled: currentIndex < widget.tour.commands.length - 1,
                    ),
                    Expanded(
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        child: isChargementComplet(widget.tour)
                            ? Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: ElevatedButton(
                                  onPressed: () {
                                    context.go('/tour/validateChargement', extra: {
                                      'packageSearcher': widget.packageSearcher,
                                      'tour': widget.tour
                                    });
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Globals.COLOR_MOVIX,
                                    foregroundColor: Colors.white,
                                    minimumSize: const Size(double.infinity, 58),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    elevation: 0,
                                  ),
                                  child: const Text(
                                    'Valider chargement',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: -0.3,
                                    ),
                                  ),
                                ),
                              )
                            : const SizedBox.shrink(),
                      ),
                    ),
                    _buildModernNavigationButton(
                      icon: Icons.arrow_forward_ios,
                      onPressed: currentIndex > 0
                          ? () => navigateToCommand(currentIndex - 1)
                          : null,
                      isEnabled: currentIndex > 0,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
