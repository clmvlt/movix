import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:movix/Managers/ChargementManager.dart';
import 'package:movix/Managers/CommandManager.dart';
import 'package:movix/Managers/PackageManager.dart';
import 'package:movix/Models/Command.dart';
import 'package:movix/Models/Package.dart';
import 'package:movix/Models/PackageSearcher.dart';
import 'package:movix/Models/Sound.dart';
import 'package:movix/Models/Tour.dart';
import 'package:movix/Services/globals.dart';
import 'package:movix/Widgets/Chargement/index.dart';

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

class _FSChargementPageState extends State<FSChargementPage>
    with TickerProviderStateMixin {
  String inputLog = "";
  late List<String> listIds = [];
  int currentIndex = 0;
  late Command command;
  late AnimationController _animationController;

  Widget _getChargementConfirmDialog(BuildContext context) {
    return Dialog(
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
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
              child: Column(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: Globals.COLOR_MOVIX_YELLOW.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(32),
                    ),
                    child: Icon(
                      Icons.warning_outlined,
                      color: Globals.COLOR_MOVIX_YELLOW,
                      size: 32,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Confirmation',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: Globals.COLOR_TEXT_DARK,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Tous les colis non scannés seront marqués comme absents. Voulez-vous continuer ?',
                    style: TextStyle(
                      fontSize: 16,
                      color: Globals.COLOR_TEXT_DARK.withOpacity(0.8),
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
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
                        onTap: () => Navigator.of(context).pop({'confirmed': false}),
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(20),
                        ),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: Text(
                            'Non',
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
                          Navigator.of(context).pop({'confirmed': true, 'comment': ''});
                        },
                        borderRadius: const BorderRadius.only(
                          bottomRight: Radius.circular(20),
                        ),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: Text(
                            'Oui',
                            style: TextStyle(
                              color: Globals.COLOR_MOVIX,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
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
    );
  }

  void onUpdate() {
    setState(() {});
    widget.onUpdate();
  }

  Future<ScanResult> validateCode(String code) async {
    Package? package =
        widget.packageSearcher.getPackageByBarcode(widget.command, code);
    if (package == null) {
      Globals.showSnackbar("Colis introuvable",
          backgroundColor: Globals.COLOR_MOVIX_RED,
          duration: const Duration(seconds: 1));
      return ScanResult.SCAN_ERROR;
    }

    Command? command = widget.tour.commands[package.commandId];
    if (command == null || package.status.id == 2) {
      if (package.status.id == 2) {
        Globals.showSnackbar("Déjà scanné",
            backgroundColor: Globals.COLOR_MOVIX_RED,
            duration: const Duration(seconds: 1));
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

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (BuildContext context) => _getChargementConfirmDialog(context),
    );

    if (result != null && result['confirmed'] == true) {
      for (var package in this.command.packages.values) {
        if (package.status.id == 1) {
          setPackageState(this.command, package, 5, onUpdate);
        }
      }
      // Update command status after all packages are marked as absent
      updateCommandState(this.command, onUpdate, false);

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
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  Widget _buildModernCommandCard() {
    return ModernCommandCardWidget(
      command: command,
      isSelected: true,
      isFullScreenMode: true,
      onTap: () {},
      onUpdate: onUpdate,
      animationController: _animationController,
    );
  }

  void _debugScanAllPackages() async {
    if (!kDebugMode) return;
    
    for (var packageId in command.packages.keys) {
      var package = command.packages[packageId];
      if (package != null) {
        ScanResult result = await validateCode(package.barcode);
        if (result == ScanResult.SCAN_SUCCESS || result == ScanResult.SCAN_FINISH) {
        }
      }
    }
  }




  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async {
          if (isChargementCommandUncomplet(command)) {
            final result = await showDialog<Map<String, dynamic>>(
              context: context,
              builder: (BuildContext context) => _getChargementConfirmDialog(context),
            );

            if (result != null && result['confirmed'] == true) {
              for (var package in command.packages.values) {
                if (package.status.id == 1) {
                  setPackageState(command, package, 5, onUpdate);
                }
              }
              // Update command status after all packages are marked as absent
              updateCommandState(command, onUpdate, false);
            }

            return result != null && result['confirmed'] == true;
          }
          return true;
        },
        child: Scaffold(
        backgroundColor: Globals.COLOR_BACKGROUND,
        appBar: AppBar(
          toolbarTextStyle: Globals.appBarTextStyle,
          titleTextStyle: Globals.appBarTextStyle,
          title: Text(
            widget.tour.name,
            style: TextStyle(
              color: Globals.COLOR_TEXT_LIGHT,
              fontWeight: FontWeight.w700,
              fontSize: 18,
            ),
          ),
          backgroundColor: Globals.COLOR_MOVIX,
          foregroundColor: Globals.COLOR_TEXT_LIGHT,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios, color: Globals.COLOR_TEXT_LIGHT),
            onPressed: () async {
              if (isChargementCommandUncomplet(command)) {
                final result = await showDialog<Map<String, dynamic>>(
                  context: context,
                  builder: (BuildContext context) => _getChargementConfirmDialog(context),
                );

                if (result != null && result['confirmed'] == true) {
                  for (var package in command.packages.values) {
                    if (package.status.id == 1) {
                      setPackageState(command, package, 5, onUpdate);
                    }
                  }
                  // Update command status after all packages are marked as absent
                  updateCommandState(command, onUpdate, false);
                  context.pop();
                }
              } else {
                context.pop();
              }
            },
          ),
          actions: [
            if (kDebugMode)
              IconButton(
                icon: Icon(Icons.qr_code_scanner, color: Globals.COLOR_TEXT_LIGHT),
                onPressed: () => _debugScanAllPackages(),
                tooltip: 'Debug: Scanner tous les colis',
              ),
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
                  ScannerSectionWidget(
                    validateCode: validateCode,
                  ),
                  _buildModernCommandCard(),
                  const SizedBox(height: 120),
                ],
              ),
            ),
            NavigationBottomBarWidget(
              tour: widget.tour,
              packageSearcher: widget.packageSearcher,
              currentIndex: currentIndex,
              totalCommands: widget.tour.commands.length,
              onNext: () => navigateToCommand(currentIndex + 1),
              onPrevious: () => navigateToCommand(currentIndex - 1),
            ),
          ],
        ),
      ),
    );
  }
}
