import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:movix/Models/Command.dart';
import 'package:movix/Models/Sound.dart';
import 'package:movix/Services/globals.dart';
import 'package:movix/Widgets/PackagesWidget.dart';
import 'package:movix/Widgets/Livraison/index.dart';

class FSLivraisonBodyWidget extends StatefulWidget {
  final Command command;
  final VoidCallback onUpdate;

  const FSLivraisonBodyWidget({
    super.key,
    required this.command,
    required this.onUpdate,
  });

  @override
  State<FSLivraisonBodyWidget> createState() => _FSLivraisonBodyWidgetState();
}

class _FSLivraisonBodyWidgetState extends State<FSLivraisonBodyWidget> {
  bool cipScanned = false;
  final TextEditingController _manCIP = TextEditingController();

  @override
  void dispose() {
    _manCIP.dispose();
    super.dispose();
  }

  Future<ScanResult> validateCode(String code) async {
    if (!cipScanned) {
      if (code == widget.command.pharmacy.cip) {
        setState(() => cipScanned = true);
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

    // Utiliser les imports depuis le widget parent
    // setPackageStateOffline(widget.command, package, 3, widget.onUpdate);

    // return isAllScanned(widget.command)
    //     ? ScanResult.SCAN_FINISH
    //     : ScanResult.SCAN_SUCCESS;
    
    // Pour l'instant, retourner SUCCESS, la logique sera injectée
    widget.onUpdate();
    return ScanResult.SCAN_SUCCESS;
  }

  void _showInputDialog(BuildContext context) {
    InputDialogWidget.show(
      context: context,
      title: "Saisir un code",
      description: cipScanned 
          ? "Entrez le code d'un colis" 
          : "Entrez le code CIP de la pharmacie",
      hintText: cipScanned ? "Code colis" : "Code CIP",
      onConfirm: (code) {
        validateCode(code);
        _manCIP.clear();
      },
      initialValue: _manCIP.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ScannerContainerWidget(
          validateCode: validateCode,
        ),
        CIPStatusButtonWidget(
          cipScanned: cipScanned,
          onPressed: () => _showInputDialog(context),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: ModernCommandCardWidget(
            command: widget.command,
            isSelected: true,
            expandedContent: Column(
              children: [
                CustomListePackages(
                  command: widget.command,
                  isLivraison: true,
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ModernActionButtonWidget(
                    label: "Signaler une anomalie",
                    icon: FontAwesomeIcons.warning,
                    color: Globals.COLOR_MOVIX_RED,
                    onPressed: () async {
                      await context.push('/anomalie', extra: {
                        'command': widget.command,
                        'onUpdate': widget.onUpdate,
                      });
                    },
                    iconSize: 18,
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 120),
      ],
    );
  }

  // Getter pour exposer l'état CIP
  bool get isCipScanned => cipScanned;
}