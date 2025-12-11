import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
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

class _FSLivraisonPageState extends State<FSLivraisonPage> {
  bool CIPScanned = false;

  bool get _isCIPRequired => Globals.profil?.account.isScanCIP ?? false;

  void onUpdate() {
    setState(() {});
    widget.onUpdate();
  }

  @override
  void initState() {
    super.initState();

    // Valider auto le CIP si la commande est forcée
    if (widget.command.isForced) {
      CIPScanned = true;
    }

    // Afficher les commentaires après un court délai
    Future.delayed(const Duration(milliseconds: 100), () async {
      // Commentaire de la pharmacie
      if (mounted && widget.command.pharmacy.commentaire.isNotEmpty) {
        await showInfoPopup(
          context: context,
          title: "Commentaire de la pharmacie",
          content: Text(widget.command.pharmacy.commentaire),
          buttonText: "Fermer",
          icon: Icons.store_outlined,
        );
      }

      // Commentaire de la commande
      if (mounted && widget.command.comment.isNotEmpty) {
        await showInfoPopup(
          context: context,
          title: "Commentaire de la commande",
          content: Text(widget.command.comment),
          buttonText: "Fermer",
          icon: Icons.comment_outlined,
        );
      }

      if (mounted && widget.command.newPharmacy) {
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

  Future<ScanResult> validateCode(String code, {bool isManualInput = false}) async {
    if (!mounted) {
      return ScanResult.SCAN_ERROR;
    }

    if (_isCIPRequired && !CIPScanned) {
      if (code == widget.command.pharmacy.cip) {
        setState(() => CIPScanned = true);
        return ScanResult.SCAN_SUCCESS;
      }

      Globals.showSnackbar(
        'Veuillez scanner le CIP avant les colis.',
        backgroundColor: Globals.COLOR_MOVIX_RED,
        duration: const Duration(seconds: 1),
      );
      return ScanResult.SCAN_ERROR;
    }

    final package = widget.command.packages[code];
    if (package == null) {
      Globals.showSnackbar(
        "Colis introuvable",
        backgroundColor: Globals.COLOR_MOVIX_RED,
        duration: const Duration(seconds: 1),
      );
      return ScanResult.SCAN_ERROR;
    }

    if (package.status.id == 3) {
      Globals.showSnackbar(
        "Déjà scanné",
        backgroundColor: Globals.COLOR_MOVIX_RED,
        duration: const Duration(seconds: 1),
      );
      return ScanResult.SCAN_ERROR;
    }

    setPackageStateOffline(widget.command, package, 3, onUpdate);

    return _isAllScanned(widget.command)
        ? ScanResult.SCAN_FINISH
        : ScanResult.SCAN_SUCCESS;
  }

  @override
  Widget build(BuildContext context) {
    Command command = widget.command;

    return GestureDetector(
      onHorizontalDragEnd: (details) {
        if (details.primaryVelocity != null && details.primaryVelocity! > 300) {
          context.pop();
        }
      },
      child: Scaffold(
        backgroundColor: Globals.COLOR_BACKGROUND,
        appBar: PharmacyAppBarWidget(
          command: command,
          actions: [
            if (kDebugMode)
              IconButton(
                icon: Icon(Icons.qr_code_scanner, color: Globals.COLOR_TEXT_LIGHT),
                onPressed: () => _debugScanAllPackages(),
                tooltip: 'Debug: Scanner tous les colis',
              ),
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
                if (_isCIPRequired) _buildCIPStatusButton(),
                _buildModernCommandCard(command),
                const SizedBox(height: 120),
              ],
            ),
          ),
          BottomValidationButtonWidget(
            label: 'Valider la livraison',
            onPressed: () => confirmValidation(command),
            allPackagesScanned: _isAllScanned(command),
          ),
        ]),
      ),
    );
  }

  Widget _buildCIPStatusButton() {
    return CIPStatusButtonWidget(
      cipScanned: CIPScanned,
      onPressed: () {}, // Saisie manuelle désactivée
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
      cipScanned: _isCIPRequired ? CIPScanned : true,
      onUpdate: onUpdate,
    );
  }

  void _debugScanAllPackages() async {
    if (!kDebugMode) return;
    
    // Scanner d'abord le CIP si nécessaire
    if (_isCIPRequired && !CIPScanned) {
      ScanResult cipResult = await validateCode(widget.command.pharmacy.cip, isManualInput: true);
      if (cipResult != ScanResult.SCAN_SUCCESS) {
        Globals.showSnackbar(
          "Debug: Impossible de scanner le CIP",
          backgroundColor: Globals.COLOR_MOVIX_RED,
        );
        return;
      }
    }

    for (var packageId in widget.command.packages.keys) {
      var package = widget.command.packages[packageId];
      if (package != null) {
        ScanResult result = await validateCode(packageId, isManualInput: true);
        if (result == ScanResult.SCAN_SUCCESS || result == ScanResult.SCAN_FINISH) {
        }
      }
    }
  }

  bool _isAllScanned(Command command) {
    for (var p in command.packages.values) {
      if (p.status.id != 3) return false;
    }
    return true;
  }
}
