import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:movix/Managers/PackageManager.dart';
import 'package:movix/Models/Command.dart';
import 'package:movix/Models/Package.dart';
import 'package:movix/Models/Sound.dart';
import 'package:movix/Services/globals.dart';
import 'package:movix/Widgets/CustomPopup.dart';
import 'package:movix/Widgets/Livraison/index.dart';

class FSLivraisonPage extends StatefulWidget {
  final List<Command> commands;
  final VoidCallback onUpdate;

  const FSLivraisonPage({
    super.key,
    required this.commands,
    required this.onUpdate,
  });

  @override
  _FSLivraisonPageState createState() => _FSLivraisonPageState();
}

class _FSLivraisonPageState extends State<FSLivraisonPage> {
  bool CIPScanned = false;

  bool get _isCIPRequired => Globals.profil?.account.isScanCIP ?? false;

  /// Première commande (utilisée pour les infos pharmacie communes)
  Command get _firstCommand => widget.commands.first;

  /// Nombre de commandes dans le groupe
  bool get _isGroup => widget.commands.length > 1;

  void onUpdate() {
    setState(() {});
    widget.onUpdate();
  }

  @override
  void initState() {
    super.initState();

    // Valider auto le CIP si toutes les commandes sont forcées
    if (widget.commands.every((c) => c.isForced)) {
      CIPScanned = true;
    }

    // Afficher les commentaires après un court délai
    Future.delayed(const Duration(milliseconds: 100), () async {
      // Commentaire de la pharmacie (une seule fois car même pharmacie)
      if (mounted && _firstCommand.pharmacy.commentaire.isNotEmpty) {
        await showInfoPopup(
          context: context,
          title: "Commentaire de la pharmacie",
          content: Text(_firstCommand.pharmacy.commentaire),
          buttonText: "Fermer",
          icon: Icons.store_outlined,
        );
      }

      // Commentaires des commandes
      for (final command in widget.commands) {
        if (mounted && command.comment.isNotEmpty) {
          await showInfoPopup(
            context: context,
            title: _isGroup
                ? "Commentaire commande"
                : "Commentaire de la commande",
            content: Text(command.comment),
            buttonText: "Fermer",
            icon: Icons.comment_outlined,
          );
        }
      }

      if (mounted && _firstCommand.newPharmacy) {
        bool? res = await showConfirmationPopup(
            context: context,
            title: "Nouvelle pharmacie",
            message:
                "Cette pharmacie n'a jamais commandé, il serait préférable d'ajouter des photos et des instructions.",
            cancelText: "Fermer",
            confirmText: "Ajouter");
        if (res == true) {
          await context.push('/pharmacy', extra: {"command": _firstCommand});
        }
      }
    });
  }

  /// Trouve un colis par son barcode dans toutes les commandes
  (Command, Package)? _findPackage(String barcode) {
    for (final command in widget.commands) {
      final package = command.packages[barcode];
      if (package != null) {
        return (command, package);
      }
    }
    return null;
  }

  /// Vérifie si un colis existe dans une autre commande du même tour
  bool _findPackageInOtherCommands(String barcode) {
    final tour = Globals.tours[_firstCommand.tourId];
    if (tour == null) return false;

    for (final command in tour.commands.values) {
      // Ignorer les commandes déjà sélectionnées
      if (widget.commands.any((c) => c.id == command.id)) continue;

      if (command.packages.containsKey(barcode)) {
        return true;
      }
    }
    return false;
  }

  Future<ScanResult> validateCode(String code, {bool isManualInput = false}) async {
    if (!mounted) {
      return ScanResult.SCAN_ERROR;
    }

    // Vérification du CIP (identique pour toutes les commandes du groupe)
    if (_isCIPRequired && !CIPScanned) {
      if (code == _firstCommand.pharmacy.cip) {
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

    // Chercher le colis dans toutes les commandes
    final result = _findPackage(code);
    if (result == null) {
      // Vérifier si le colis appartient à une autre commande du tour
      if (_findPackageInOtherCommands(code)) {
        await showInfoPopup(
          context: context,
          title: "Attention",
          content: const Text("Ce colis appartient à une autre commande"),
          buttonText: "OK",
          icon: Icons.warning_amber_outlined,
        );
      } else {
        Globals.showSnackbar(
          "Colis introuvable",
          backgroundColor: Globals.COLOR_MOVIX_RED,
          duration: const Duration(seconds: 1),
        );
      }
      return ScanResult.SCAN_ERROR;
    }

    final (command, package) = result;

    if (package.status.id == 3) {
      Globals.showSnackbar(
        "Déjà scanné",
        backgroundColor: Globals.COLOR_MOVIX_RED,
        duration: const Duration(seconds: 1),
      );
      return ScanResult.SCAN_ERROR;
    }

    setPackageStateOffline(command, package, 3, onUpdate);

    return _isAllScanned()
        ? ScanResult.SCAN_FINISH
        : ScanResult.SCAN_SUCCESS;
  }

  /// Vérifie si tous les colis de toutes les commandes sont scannés
  bool _isAllScanned() {
    for (final command in widget.commands) {
      for (var p in command.packages.values) {
        if (p.status.id != 3) return false;
      }
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Globals.COLOR_BACKGROUND,
        appBar: PharmacyAppBarWidget(
          command: _firstCommand,
          actions: [
            if (kDebugMode)
              IconButton(
                icon: Icon(Icons.qr_code_scanner, color: Globals.COLOR_TEXT_LIGHT),
                onPressed: () => _debugScanAllPackages(),
                tooltip: 'Debug: Scanner tous les colis',
              ),
            PharmacyInfoActionWidget(command: _firstCommand),
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
                // Afficher toutes les commandes du groupe
                ...widget.commands.map((command) => _buildModernCommandCard(command)),
                const SizedBox(height: 120),
              ],
            ),
          ),
          BottomValidationButtonWidget(
            label: 'Valider la livraison',
            onPressed: () => confirmValidation(),
            allPackagesScanned: _isAllScanned(),
          ),
        ]),
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

  void confirmValidation() async {
    await LivraisonValidationLogicWidget.confirmValidation(
      context: context,
      commands: widget.commands,
      cipScanned: _isCIPRequired ? CIPScanned : true,
      onUpdate: onUpdate,
    );
  }

  void _debugScanAllPackages() async {
    if (!kDebugMode) return;

    // Scanner d'abord le CIP si nécessaire
    if (_isCIPRequired && !CIPScanned) {
      ScanResult cipResult = await validateCode(_firstCommand.pharmacy.cip, isManualInput: true);
      if (cipResult != ScanResult.SCAN_SUCCESS) {
        Globals.showSnackbar(
          "Debug: Impossible de scanner le CIP",
          backgroundColor: Globals.COLOR_MOVIX_RED,
        );
        return;
      }
    }

    // Scanner tous les colis de toutes les commandes
    for (final command in widget.commands) {
      for (var packageId in command.packages.keys) {
        var package = command.packages[packageId];
        if (package != null) {
          ScanResult result = await validateCode(packageId, isManualInput: true);
          if (result == ScanResult.SCAN_SUCCESS || result == ScanResult.SCAN_FINISH) {
            // Continue
          }
        }
      }
    }
  }
}
