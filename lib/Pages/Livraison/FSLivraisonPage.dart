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

class _FSLivraisonPageState extends State<FSLivraisonPage> with WidgetsBindingObserver, RouteAware {
  bool CIPScanned = false;
  final TextEditingController _manCIP = TextEditingController();
  bool _isPageActive = true;

  bool get _isCIPRequired => Globals.profil?.account.isScanCIP ?? false;

  void onUpdate() {
    setState(() {});
    widget.onUpdate();
  }


  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // Attendre un délai pour que la caméra soit initialisée
      await Future<void>.delayed(const Duration(milliseconds: 1500));
      
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
      
      // Afficher le commentaire de la commande s'il existe
      if (mounted && widget.command.comment.isNotEmpty) {
        await showInfoPopup(
          context: context,
          title: "Commentaire de la commande",
          content: Text(widget.command.comment),
          buttonText: "Fermer",
          icon: Icons.comment_outlined,
        );
      }
    });
  }


  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _manCIP.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      setState(() {
        _isPageActive = false;
      });
    } else if (state == AppLifecycleState.resumed) {
      setState(() {
        _isPageActive = true;
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Utiliser un délai pour vérifier si on a une nouvelle route au-dessus
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final route = ModalRoute.of(context);
        final isActive = route?.isCurrent == true;

        if (_isPageActive != isActive) {
          setState(() {
            _isPageActive = isActive;
          });
        }
      }
    });
  }

  Future<ScanResult> validateCode(String code) async {
    // Ne traiter les scans que si la page est active et visible
    if (!_isPageActive || !mounted) {
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

    return _isAllScanned(widget.command)
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
                  isActive: _isPageActive,
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
        ]));
  }

  void _showInputDialog(BuildContext context) {
    ScanInputDialogWidget.show(
      context: context,
      cipScanned: _isCIPRequired ? CIPScanned : true,
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
      cipScanned: _isCIPRequired ? CIPScanned : true,
      onUpdate: onUpdate,
    );
  }

  void _debugScanAllPackages() async {
    if (!kDebugMode) return;
    
    // Scanner d'abord le CIP si nécessaire
    if (_isCIPRequired && !CIPScanned) {
      ScanResult cipResult = await validateCode(widget.command.pharmacy.cip);
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
        ScanResult result = await validateCode(packageId);
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
