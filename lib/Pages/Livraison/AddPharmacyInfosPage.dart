import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:movix/Managers/LivraisonManager.dart';
import 'package:movix/Models/Command.dart';
import 'package:movix/Services/globals.dart';
import 'package:movix/Widgets/CustomButton.dart';

class AddInfosPharmacyPage extends StatefulWidget {
  final Command command;

  const AddInfosPharmacyPage({super.key, required this.command});

  @override
  State<AddInfosPharmacyPage> createState() => _AddInfosPharmacyPageState();
}

class _AddInfosPharmacyPageState extends State<AddInfosPharmacyPage> {
  final TextEditingController _commentController = TextEditingController();
  bool _invalidGeocodage = false;
  final List<String> _photosBase64 = [];

  void _removeImage(int index) {
    setState(() {
      _photosBase64.removeAt(index);
    });
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

  void _submitInfos() {
    sendPharmacyInformations(_commentController.text.trim(), _invalidGeocodage,
        _photosBase64, widget.command);
    Globals.showSnackbar("Informations envoyée avec succès", backgroundColor: Globals.COLOR_MOVIX_GREEN);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Ajouter Infos Pharmacie"),
        titleTextStyle: Globals.appBarTextStyle,
        toolbarTextStyle: Globals.appBarTextStyle,
        backgroundColor: Globals.COLOR_MOVIX,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Commentaire"),
            const SizedBox(height: 6),
            TextField(
              controller: _commentController,
              maxLines: 3,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                hintText: "Ajouter un commentaire...",
              ),
            ),
            const SizedBox(height: 12),
            CheckboxListTile(
              value: _invalidGeocodage,
              onChanged: (val) => setState(() => _invalidGeocodage = val!),
              title: const Text("Géocodage invalide"),
            ),
            const SizedBox(height: 12),
            customButton(label: "Ajouter photo", onPressed: _takePhoto),
            const SizedBox(height: 8),
            Expanded(
              child: _photosBase64.isEmpty
                  ? const Center(
                      child: Text("Aucune photo prise"),
                    )
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
                                borderRadius: BorderRadius.circular(8),
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
            SizedBox(
                width: double.infinity,
                child: customButton(onPressed: _submitInfos, label: "Envoyer")),
          ],
        ),
      ),
    );
  }
}
