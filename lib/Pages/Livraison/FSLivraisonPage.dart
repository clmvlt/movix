import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:movix/Managers/PackageManager.dart';
import 'package:movix/Models/Command.dart';
import 'package:movix/Models/Sound.dart';
import 'package:movix/Managers/LivraisonManager.dart';
import 'package:movix/Widgets/CustomButton.dart';
import 'package:movix/Widgets/CustomPopup.dart';
import 'package:movix/Widgets/ScannerWidget.dart';
import 'package:movix/Services/affichage.dart';
import 'package:movix/Services/globals.dart';

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
  final TextEditingController _manCIP = TextEditingController();

  void onUpdate() {
    setState(() {});
    widget.onUpdate();
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (widget.command.pNew) {
        bool? res = await showConfirmationPopup(
            context: context,
            title: "Nouvelle pharmacie",
            message:
                "Cette pharmacie n'a jamais commandé, il serait préférable d'ajouter des photos et des instructions.",
            cancelText: "Fermer",
            confirmText: "Ajouter");
        if (res == true) {
          context.push('/pharmacy', extra: {"command": widget.command});
        }
      }
    });
  }

  Future<ScanResult> validateCode(String code) async {
    if (!CIPScanned) {
      if (code == widget.command.cip) {
        setState(() => CIPScanned = true);
        return Globals.isScannerMode
            ? ScanResult.NOTHING
            : ScanResult.SCAN_SUCCESS;
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

    if (package.idStatus == '3') {
      Globals.showSnackbar(
        "Déjà scanné",
        backgroundColor: Globals.COLOR_MOVIX_RED,
      );
      return ScanResult.SCAN_ERROR;
    }

    setPackageStateOffline(widget.command, package, "3", onUpdate);

    return isAllScanned(widget.command)
        ? ScanResult.SCAN_FINISH
        : (Globals.isScannerMode
            ? ScanResult.NOTHING
            : ScanResult.SCAN_SUCCESS);
  }

  @override
  Widget build(BuildContext context) {
    Command command = widget.command;

    return Scaffold(
      appBar: AppBar(
        toolbarTextStyle: Globals.appBarTextStyle,
        titleTextStyle: Globals.appBarTextStyle,
        title: Text(command.pharmacyName),
        backgroundColor: Globals.COLOR_MOVIX,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline, color: Colors.white),
            onPressed: () {
              context.push('/pharmacy', extra: {"command": command});
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    margin:
                        const EdgeInsets.symmetric(vertical: 5, horizontal: 2),
                    elevation: 6,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              GetLivraisonIconCommandStatus(command, 26),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  command.pharmacyName,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ),
                              if (command.pNew) ...[
                                const SizedBox(width: 5),
                                newBadge(),
                              ],
                            ],
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  "${command.pharmacyAddress1} ${command.pharmacyAddress2} ${command.pharmacyAddress3}"
                                      .trim(),
                                  style: const TextStyle(
                                      fontSize: 12, color: Colors.black54),
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
                          command.packages.isNotEmpty
                              ? SizedBox(
                                  height:
                                      command.packages.length > 3 ? 150 : null,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.grey[100],
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    padding: const EdgeInsets.all(8),
                                    child: Scrollbar(
                                      thumbVisibility: true,
                                      child: SingleChildScrollView(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: command.packages.values
                                              .map((package) {
                                            final emote =
                                                getColisEmote(package.type);
                                            final isFresh = package.fresh == 't'
                                                ? '❄️'
                                                : '';
                                            return Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 4.0),
                                              child: Row(
                                                children: [
                                                  GetLivraisonIconPackageStatus(
                                                      package, 15),
                                                  const SizedBox(width: 8),
                                                  Text(
                                                    package.barcode,
                                                    style: const TextStyle(
                                                      fontSize: 11,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      color: Colors.black87,
                                                    ),
                                                  ),
                                                  Text(
                                                    " $emote$isFresh",
                                                    style: const TextStyle(
                                                      fontSize: 10,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      color: Colors.black87,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            );
                                          }).toList(),
                                        ),
                                      ),
                                    ),
                                  ),
                                )
                              : const Center(
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(vertical: 8),
                                    child: Text(
                                      'Aucun package disponible',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontStyle: FontStyle.italic,
                                        color: Colors.black54,
                                      ),
                                    ),
                                  ),
                                ),
                          const SizedBox(height: 12),
                        ],
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () =>
                        _showInputDialog(context), // Rendre la Card cliquable
                    child: Card(
                      margin: const EdgeInsets.symmetric(
                          vertical: 6, horizontal: 0),
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      color: CIPScanned
                          ? Globals.COLOR_MOVIX_GREEN
                          : Globals.COLOR_MOVIX_RED,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                            vertical: 12.0, horizontal: 12.0),
                        child: Text(
                          CIPScanned ? 'CIP Validé' : "CIP non validé",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: ScannerWidget(
              validateCode: validateCode,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0)
                .copyWith(bottom: 8.0),
            child: SizedBox(
              width: double.infinity,
              child: customButton(
                  onPressed: () {
                    confirmValidation(command);
                  },
                  label: "Valider"),
            ),
          )
        ],
      ),
    );
  }

  void _showInputDialog(BuildContext context) {
    TextEditingController manCIPController =
        TextEditingController(text: _manCIP.text);

    showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return WillPopScope(
          onWillPop: () async => false,
          child: AlertDialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
            title: const Text(
              "Saisir un code",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            content: TextField(
              controller: manCIPController,
              decoration: InputDecoration(
                hintText: "Entrez le code",
                counterText: "",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4),
                  borderSide: const BorderSide(
                    color: Globals.COLOR_MOVIX,
                    width: 1.5,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4),
                  borderSide: const BorderSide(
                    color: Globals.COLOR_MOVIX,
                    width: 2,
                  ),
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text(
                  "Annuler",
                  style: TextStyle(color: Colors.black),
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Globals.COLOR_MOVIX,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                onPressed: () {
                  String code = manCIPController.text.trim();
                  if (code.isNotEmpty) {
                    validateCode(code);
                    _manCIP.clear();
                    Navigator.of(context).pop();
                  }
                },
                child: const Text(
                  "Suivant",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void confirmValidation(Command command) async {
    if (!CIPScanned) {
      Globals.showSnackbar("Veuillez scanner le CIP",
          backgroundColor: Colors.red);
      return;
    }

    if (!isCommandValid(command)) {
      final confirmation = await showDialog<bool>(
        context: context,
        builder: getColisConfirm,
      );

      if (confirmation != true) return;

      for (final package in command.packages.values) {
        if (package.idStatus != "3") {
          setPackageStateOffline(command, package, "4", onUpdate);
        }
      }
    }

    context.push('/tour/validateLivraison',
        extra: {'command': command, 'onUpdate': onUpdate});
  }
}
