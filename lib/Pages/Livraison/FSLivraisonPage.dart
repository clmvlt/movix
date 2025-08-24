import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:movix/Managers/LivraisonManager.dart';
import 'package:movix/Managers/PackageManager.dart';
import 'package:movix/Models/Command.dart';
import 'package:movix/Models/Sound.dart';
import 'package:movix/Services/globals.dart';
import 'package:movix/Widgets/CustomPopup.dart';
import 'package:movix/Widgets/Livraison/index.dart';

class FSLivraisonPage extends StatefulWidget {
  final Command command;
  final VoidCallback onUpdate;

  const FSLivraisonPage({
    super.key,
    required this.command,
    required this.onUpdate,
  });

  @override
  _FSLivraisonPageState createState() => _FSLivraisonPageState();
}

class _FSLivraisonPageState extends State<FSLivraisonPage> with WidgetsBindingObserver, RouteAware {
  bool CIPScanned = false;
  final TextEditingController _manCIP = TextEditingController();

  void onUpdate() {
    setState(() {});
    widget.onUpdate();
  }


  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (widget.command.newPharmacy) {
        bool? res = await showConfirmationPopup(
            context: context,
            title: "Nouvelle pharmacie",
            message:
                "Cette pharmacie n'a jamais commandé, il serait préférable d'ajouter des photos et des instructions.",
            cancelText: "Fermer",
            confirmText: "Ajouter");
        if (res == true) {
          await context.push('/pharmacy', extra: {"command": widget.command});
        }
      }
    });
  }


  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _manCIP.dispose();
    super.dispose();
  }

  Future<ScanResult> validateCode(String code) async {
    if (!CIPScanned) {
      if (code == widget.command.pharmacy.cip) {
        setState(() => CIPScanned = true);
        return ScanResult.SCAN_SUCCESS;
      }

      Globals.showSnackbar(
        'Veuillez scanner le CIP avant les colis.',
        backgroundColor: Globals.COLOR_MOVIX_RED,
      );
      return ScanResult.SCAN_ERROR;
    }

    final package = widget.command.packages[code];
    if (package == null) {
      Globals.showSnackbar(
        "Colis introuvable",
        backgroundColor: Globals.COLOR_MOVIX_RED,
      );
      return ScanResult.SCAN_ERROR;
    }

    if (package.status.id == 3) {
      Globals.showSnackbar(
        "Déjà scanné",
        backgroundColor: Globals.COLOR_MOVIX_RED,
      );
      return ScanResult.SCAN_ERROR;
    }

    setPackageStateOffline(widget.command, package, 3, onUpdate);

    return isAllScanned(widget.command)
        ? ScanResult.SCAN_FINISH
        : ScanResult.SCAN_SUCCESS;
  }

  @override
  Widget build(BuildContext context) {
    Command command = widget.command;

    return Scaffold(
        backgroundColor: Globals.COLOR_BACKGROUND,
        appBar: PharmacyAppBarWidget(
          command: command,
          subtitle: 'Livraison des colis',
          actions: [
            PharmacyInfoActionWidget(command: command),
          ],
        ),
        body: Stack(fit: StackFit.expand, children: [
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ScannerContainerWidget(
                  validateCode: validateCode,
                ),
                _buildCIPStatusButton(),
                _buildModernCommandCard(command),
                const SizedBox(height: 120),
              ],
            ),
          ),
          BottomValidationButtonWidget(
            label: 'Valider la livraison',
            onPressed: () => confirmValidation(command),
          ),
        ]));
  }

  void _showInputDialog(BuildContext context) {
    ScanInputDialogWidget.show(
      context: context,
      cipScanned: CIPScanned,
      onConfirm: (code) {
        validateCode(code);
        _manCIP.clear();
      },
      initialValue: _manCIP.text,
    );
  }

  Widget _buildCIPStatusButton() {
    return CIPStatusButtonWidget(
      cipScanned: CIPScanned,
      onPressed: () => _showInputDialog(context),
    );
  }

  Widget _buildModernCommandCard(Command command) {
    return FSLivraisonCommandCardWidget(
      command: command,
      onUpdate: onUpdate,
    );
  }


  void confirmValidation(Command command) async {
    await LivraisonValidationLogicWidget.confirmValidation(
      context: context,
      command: command,
      cipScanned: CIPScanned,
      onUpdate: onUpdate,
    );
  }
}
