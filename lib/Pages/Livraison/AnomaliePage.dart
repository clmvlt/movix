import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:movix/Managers/LivraisonManager.dart';
import 'package:movix/Managers/PackageManager.dart';
import 'package:movix/Models/Command.dart';
import 'package:movix/Models/Package.dart';
import 'package:movix/Models/Sound.dart';
import 'package:movix/Services/affichage.dart';
import 'package:movix/Services/globals.dart';
import 'package:movix/Widgets/CustomButton.dart';
import 'package:movix/Widgets/ScannerWidget.dart';

class AnomaliePage extends StatefulWidget {
  final Command command;
  final VoidCallback onUpdate;

  const AnomaliePage(
      {super.key, required this.command, required this.onUpdate});

  @override
  _AnomaliePage createState() => _AnomaliePage();
}

class _AnomaliePage extends State<AnomaliePage> {
  final List<String> _photosBase64 = [];
  String? _selectedReasonCode;
  final TextEditingController _otherReasonController = TextEditingController();
  final TextEditingController _actionsController = TextEditingController();
  final Map<String, Package> packages = {};

  final Map<String, String> _reasonsMap = {
    'excu_temp': 'Excurtion de température',
    'c_dev': 'Colis dévoyé',
    'c_end': 'Colis endommagé',
    'c_per': 'Colis perdu',
    'other': 'Autre',
  };

  void handleFormSend() {
    if (_photosBase64.isEmpty) {
      Globals.showSnackbar("Veuillez ajouter au moins une photo.",
          backgroundColor: Globals.COLOR_MOVIX_RED);
      return;
    }
    if (_selectedReasonCode == null) {
      Globals.showSnackbar("La raison est obligatoire.",
          backgroundColor: Globals.COLOR_MOVIX_RED);
      return;
    }
    if (_selectedReasonCode == 'Autre' && _otherReasonController.text == '') {
      Globals.showSnackbar("Veuillez préciser la raison.",
          backgroundColor: Globals.COLOR_MOVIX_RED);
      return;
    }
    if (_actionsController.text == '') {
      Globals.showSnackbar("Veuillez préciser l'action prise.",
          backgroundColor: Globals.COLOR_MOVIX_RED);
      return;
    }
    if (packages.isEmpty) {
      Globals.showSnackbar("Veuillez ajouter au moins un colis.",
          backgroundColor: Globals.COLOR_MOVIX_RED);
      return;
    }

    for (final package in packages.values) {
      setPackageStateOffline(widget.command, package, "6", onUpdate);
    }

    ValidLivraisonAnomalie(_photosBase64, _selectedReasonCode,
        _otherReasonController.text, _actionsController.text, packages);

    Globals.showSnackbar("L'anomalie à bien été envoyée.",
        backgroundColor: Globals.COLOR_MOVIX_GREEN);
    Navigator.of(context).pop();
  }

  Future<void> _takePhoto() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      setState(() {
        _photosBase64.add(base64Encode(bytes));
      });
    }
  }

  void _removeImage(int index) {
    setState(() {
      _photosBase64.removeAt(index);
    });
  }

  void onUpdate() {
    widget.onUpdate();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarTextStyle: Globals.appBarTextStyle,
        titleTextStyle: Globals.appBarTextStyle,
        title: const Text("Anomalie"),
        backgroundColor: Globals.COLOR_MOVIX,
        foregroundColor: Colors.white,
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                customButton(
                  label: "Ajouter photo",
                  onPressed: _takePhoto,
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 200,
                  child: _photosBase64.isEmpty
                      ? const Center(child: Text("Aucune photo prise"))
                      : GridView.builder(
                          itemCount: _photosBase64.length,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            mainAxisSpacing: 8,
                            crossAxisSpacing: 8,
                          ),
                          itemBuilder: (context, index) {
                            return Stack(
                              children: [
                                Positioned.fill(
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: Image.memory(
                                      base64Decode(_photosBase64[index]),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                Positioned(
                                  top: 6,
                                  right: 6,
                                  child: GestureDetector(
                                    onTap: () => _removeImage(index),
                                    child: Container(
                                      decoration: const BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Globals.COLOR_MOVIX_RED,
                                      ),
                                      padding: const EdgeInsets.all(4),
                                      child: const Icon(
                                        Icons.close,
                                        size: 18,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: "Motif d'anomalie",
                    border: OutlineInputBorder(),
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  ),
                  value: _selectedReasonCode,
                  isExpanded: true,
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedReasonCode = newValue;
                    });
                  },
                  items: _reasonsMap.entries.map((entry) {
                    return DropdownMenuItem<String>(
                      value: entry.key,
                      child: Text(entry.value),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 12),
                if (_selectedReasonCode == "other")
                  TextField(
                    controller: _otherReasonController,
                    decoration: const InputDecoration(
                      labelText: "Autre (précisez)",
                      border: OutlineInputBorder(),
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    ),
                  ),
                if (_selectedReasonCode == "other") const SizedBox(height: 12),
                TextField(
                  controller: _actionsController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: "Actions prises",
                    border: OutlineInputBorder(),
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.all(12),
                  constraints: BoxConstraints(
                    minHeight: 60,
                    maxHeight: packages.length > 3 ? 160 : double.infinity,
                  ),
                  child: packages.isEmpty
                      ? const Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 8),
                            child: Text(
                              'Scannez pour ajouter un colis.',
                              style: TextStyle(
                                fontSize: 13,
                                fontStyle: FontStyle.italic,
                                color: Colors.black54,
                              ),
                            ),
                          ),
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: packages.values.map((package) {
                            final emote = getColisEmote(package.type);
                            final isFresh = package.fresh == 't' ? '❄️' : '';
                            return Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 4.0),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      "${package.barcode} $emote$isFresh",
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                ),
                const SizedBox(height: 16),
                ScannerWidget(validateCode: validateCode),
                const SizedBox(height: 70),
              ],
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: customButton(
              onPressed: handleFormSend,
              label: "Valider",
            ),
          ),
        ],
      ),
    );
  }

  Future<ScanResult> validateCode(String code) async {
    Package? package = widget.command.packages[code];
    if (package == null) {
      Globals.showSnackbar("Colis introuvable",
          backgroundColor: Globals.COLOR_MOVIX_RED);
      return ScanResult.SCAN_ERROR;
    } else {
      packages[package.barcode] = package;
      onUpdate();
      Globals.showSnackbar("Colis ajouté dans l'anomalie",
          backgroundColor: Globals.COLOR_MOVIX_GREEN);
      return Globals.isScannerMode
          ? ScanResult.NOTHING
          : ScanResult.SCAN_SUCCESS;
    }
  }
}
