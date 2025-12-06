import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:movix/Services/globals.dart';

class PhotoPickerWidget extends StatefulWidget {
  final List<String> base64Images;
  final void Function(List<String>) onImagesChanged;
  final bool isRequired;
  final String emptyMessage;

  const PhotoPickerWidget({
    super.key,
    required this.base64Images,
    required this.onImagesChanged,
    this.isRequired = false,
    this.emptyMessage = "Aucune photo sélectionnée",
  });

  @override
  _PhotoPickerWidgetState createState() => _PhotoPickerWidgetState();
}

class _PhotoPickerWidgetState extends State<PhotoPickerWidget> {
  final ImagePicker _picker = ImagePicker();
  bool btnLocked = false;

  Future<void> _pickImage() async {
    setState(() {
      btnLocked = true;
    });
    
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.rear,
        imageQuality: 85,
        maxWidth: 1280,
        maxHeight: 720,
      );
      
      if (pickedFile != null) {
        final bytes = await pickedFile.readAsBytes();
        final newImages = List<String>.from(widget.base64Images);
        newImages.add(base64Encode(bytes));
        widget.onImagesChanged(newImages);
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
    final newImages = List<String>.from(widget.base64Images);
    newImages.removeAt(index);
    widget.onImagesChanged(newImages);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: widget.base64Images.isEmpty
              ? Center(
                  child: Text(
                    widget.emptyMessage,
                    style: TextStyle(color: Globals.COLOR_TEXT_DARK),
                  ),
                )
              : GridView.builder(
                  padding: const EdgeInsets.all(12.0),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: widget.base64Images.length,
                  itemBuilder: (context, index) {
                    return Stack(
                      children: [
                        Positioned.fill(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.memory(
                              base64Decode(widget.base64Images[index]),
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
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Globals.COLOR_MOVIX_RED,
                              ),
                              child: Icon(
                                Icons.close,
                                color: Globals.COLOR_TEXT_LIGHT,
                                size: 18,
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
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
              color: btnLocked ? Globals.COLOR_TEXT_GRAY : Globals.COLOR_ADAPTIVE_ACCENT,
            ),
            tooltip: "Prendre une photo",
          ),
        ),
      ],
    );
  }
} 