import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:movix/Managers/LivraisonManager.dart';
import 'package:movix/Managers/PackageManager.dart';
import 'package:movix/Models/Command.dart';
import 'package:movix/Models/Sound.dart';
import 'package:movix/Scanning/Scan.dart';
import 'package:movix/Services/affichage.dart';
import 'package:movix/Services/globals.dart';
import 'package:movix/Widgets/CommandWidget.dart';
import 'package:movix/Widgets/CustomPopup.dart';
import 'package:movix/Widgets/PackagesWidget.dart';

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
        appBar: AppBar(
          toolbarTextStyle: Globals.appBarTextStyle,
          titleTextStyle: Globals.appBarTextStyle,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                command.pharmacy.name,
                style: TextStyle(
                  color: Globals.COLOR_TEXT_LIGHT,
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                'Livraison des colis',
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
              child: IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.info_outline,
                    color: Globals.COLOR_TEXT_LIGHT,
                    size: 20,
                  ),
                ),
                onPressed: () {
                  context.push('/pharmacy', extra: {"command": command});
                },
              ),
            ),
          ],
        ),
        body: Stack(fit: StackFit.expand, children: [
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
                    validateCode: validateCode,
                  ),
                ),
                _buildCIPStatusButton(),
                _buildModernCommandCard(command),
                const SizedBox(height: 120),
              ],
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
              ),
              child: ElevatedButton(
                onPressed: () {
                  confirmValidation(command);
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
                  'Valider la livraison',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.5,
                  ),
                ),
              ),
            ),
          ),
        ]));
  }

  void _showInputDialog(BuildContext context) {
    TextEditingController manCIPController =
        TextEditingController(text: _manCIP.text);
    FocusNode focusNode = FocusNode();

    showDialog<String>(
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
                            Icons.qr_code_scanner_outlined,
                            color: Globals.COLOR_MOVIX,
                            size: 32,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          "Saisir un code",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                            color: Globals.COLOR_TEXT_DARK,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          CIPScanned 
                            ? "Entrez le code d'un colis" 
                            : "Entrez le code CIP de la pharmacie",
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
                            controller: manCIPController,
                            focusNode: focusNode,
                            autofocus: true,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Globals.COLOR_TEXT_DARK,
                              letterSpacing: 1.5,
                            ),
                            decoration: InputDecoration(
                              hintText: CIPScanned ? "Code colis" : "Code CIP",
                              hintStyle: TextStyle(
                                color: Globals.COLOR_TEXT_DARK.withOpacity(0.5),
                                fontWeight: FontWeight.normal,
                                letterSpacing: 0,
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
                              },
                              borderRadius: const BorderRadius.only(
                                bottomLeft: Radius.circular(20),
                              ),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                child: Text(
                                  "Annuler",
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
                                String code = manCIPController.text.trim();
                                if (code.isNotEmpty) {
                                  validateCode(code);
                                  _manCIP.clear();
                                  focusNode.unfocus();
                                  Navigator.of(context).pop();
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

  Widget _buildCIPStatusButton() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
      ),
      child: ElevatedButton.icon(
        onPressed: () => _showInputDialog(context),
        icon: Icon(
          CIPScanned ? Icons.check_circle : Icons.warning,
          size: 20,
        ),
        label: Text(
          CIPScanned ? 'CIP Validé' : 'CIP non validé',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: CIPScanned ? Globals.COLOR_MOVIX_GREEN : Globals.COLOR_MOVIX_RED,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 58),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
      ),
    );
  }

  Widget _buildModernCommandCard(Command command) {
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
                              customCardHeader(command, true, true),
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
                      isLivraison: true,
                    ),
                    const SizedBox(height: 20),
                    _buildModernActionButton(
                      label: "Signaler une anomalie",
                      icon: FontAwesomeIcons.warning,
                      color: Globals.COLOR_MOVIX_RED,
                      onPressed: () async {
                        await context.push('/anomalie', extra: {
                          'command': command,
                          'onUpdate': onUpdate
                        });
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
            fontSize: 12,
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

  void confirmValidation(Command command) async {
    if (!CIPScanned) {
      Globals.showSnackbar("Veuillez scanner le CIP",
          backgroundColor: Globals.COLOR_MOVIX_RED);
      return;
    }

    if (!isCommandValid(command)) {
      final confirmation = await showDialog<bool>(
        context: context,
        builder: getColisConfirm,
      );

      if (confirmation != true) return;

      for (final package in command.packages.values) {
        if (package.status.id != 3) {
          setPackageStateOffline(command, package, 4, onUpdate);
        }
      }
    }

    context.push('/tour/validateLivraison',
        extra: {'command': command, 'onUpdate': onUpdate});
  }
}
