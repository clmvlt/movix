import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:movix/Models/Command.dart';
import 'package:movix/Managers/LivraisonManager.dart';
import 'package:movix/Services/globals.dart';
import 'package:movix/Widgets/CustomButton.dart';

class LivraisonValidationPage extends StatefulWidget {
  final Command command;
  final VoidCallback onUpdate;

  const LivraisonValidationPage(
      {super.key, required this.command, required this.onUpdate});

  @override
  _LivraisonValidationPageState createState() =>
      _LivraisonValidationPageState();
}

class _LivraisonValidationPageState extends State<LivraisonValidationPage> {
  final ImagePicker _picker = ImagePicker();
  List<String> base64Images = [];
  List<File> imageFiles = [];
  bool btnLocked = false;

  void onUpdate() {
    setState(() {});
    widget.onUpdate;
  }

  Future<void> _pickImage() async {
    setState(() {
      btnLocked = true;
    });
    try {
      final XFile? pickedFile =
          await _picker.pickImage(source: ImageSource.camera);
      if (pickedFile != null) {
        final File imageFile = File(pickedFile.path);
        final bytes = await imageFile.readAsBytes();
        setState(() {
          base64Images.add(base64Encode(bytes));
          imageFiles.add(imageFile);
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print("Erreur lors de la prise de photo: $e");
      }
    }
    setState(() {
      btnLocked = false;
    });
  }

  void _removeImage(int index) {
    setState(() {
      base64Images.removeAt(index);
      imageFiles.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarTextStyle: Globals.appBarTextStyle,
        titleTextStyle: Globals.appBarTextStyle,
        title: const Text("Validation de la Livraison"),
        backgroundColor: Globals.COLOR_MOVIX,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Expanded(
            child: imageFiles.isNotEmpty
                ? GridView.builder(
                    padding: const EdgeInsets.all(12.0),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    itemCount: imageFiles.length,
                    itemBuilder: (context, index) {
                      return Stack(
                        children: [
                          Positioned.fill(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.file(
                                imageFiles[index],
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
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Globals.COLOR_MOVIX_RED,
                                ),
                                child: const Icon(
                                  Icons.close,
                                  color: Colors.white,
                                  size: 18,
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  )
                : const Center(child: Text("Aucune photo sélectionnée")),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: IconButton(
              onPressed: () {
                if (!btnLocked) _pickImage();
              },
              icon: Icon(
                Icons.camera_alt,
                size: 50,
                color: btnLocked ? Colors.grey : Globals.COLOR_MOVIX,
              ),
              tooltip: "Prendre une photo",
            ),
          ),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 12.0, vertical: 16.0),
            child: SizedBox(
              width: double.infinity,
              child: customButton(
                onPressed: () {
                  if (base64Images.isNotEmpty) {
                    ValidLivraisonCommand(
                        widget.command, base64Images, widget.onUpdate);
                        context.go('/tour/livraison', extra: {
                          'tour': Globals.tours[widget.command.idTour]
                        });
                  } else {
                    Globals.showSnackbar('Au moins une photo est obligatoire.',
                        backgroundColor: Globals.COLOR_MOVIX_RED);
                  }
                },
                label: "Valider",
              ),
            ),
          ),
        ],
      ),
    );
  }
}
