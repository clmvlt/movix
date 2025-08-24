import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:movix/Managers/ChargementManager.dart';
import 'package:movix/Managers/PackageManager.dart';
import 'package:movix/Models/Command.dart';
import 'package:movix/Models/Package.dart';
import 'package:movix/Models/PackageSearcher.dart';
import 'package:movix/Models/Sound.dart';
import 'package:movix/Models/Tour.dart';
import 'package:movix/Services/affichage.dart';
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
