import 'package:flutter/material.dart';
import 'package:movix/Managers/LivraisonManager.dart';
import 'package:movix/Models/Command.dart';
import 'package:movix/Services/globals.dart';
import 'package:movix/Widgets/CustomButton.dart';
import 'package:movix/Widgets/PhotoPickerWidget.dart';

class AddInfosPharmacyPage extends StatefulWidget {
  final Command command;

  const AddInfosPharmacyPage({super.key, required this.command});

  @override
  State<AddInfosPharmacyPage> createState() => _AddInfosPharmacyPageState();
}

class _AddInfosPharmacyPageState extends State<AddInfosPharmacyPage> {
  final TextEditingController _commentController = TextEditingController();
  bool _invalidGeocodage = false;
  List<String> _photosBase64 = [];

  void _onImagesChanged(List<String> images) {
    setState(() {
      _photosBase64 = images;
    });
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
      backgroundColor: Globals.COLOR_BACKGROUND,
      appBar: AppBar(
        toolbarTextStyle: Globals.appBarTextStyle,
        titleTextStyle: Globals.appBarTextStyle,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.command.pharmacy.name,
              style: TextStyle(
                color: Globals.COLOR_TEXT_LIGHT,
                fontWeight: FontWeight.w700,
                fontSize: 18,
              ),
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              'Ajouter des informations',
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
      ),
      body: Scaffold(
        backgroundColor: Globals.COLOR_BACKGROUND,
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                _buildModernCommentAndOptionsCard(),
                const SizedBox(height: 20),
                _buildModernPhotosCard(),
              ],
            ),
          ),
        ),
        bottomNavigationBar: customButton(
          bottomPadding: 32,
          onPressed: _submitInfos,
          label: "Envoyer",
        ),
      ),
    );
  }

  Widget _buildModernCommentAndOptionsCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Globals.COLOR_SURFACE,
            Globals.COLOR_SURFACE.withOpacity(0.95),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Globals.COLOR_TEXT_GRAY.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Globals.COLOR_MOVIX.withOpacity(0.15),
                        Globals.COLOR_MOVIX.withOpacity(0.08),
                      ],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.info_outlined,
                    color: Globals.COLOR_MOVIX,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    "Informations complémentaires",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Globals.COLOR_TEXT_DARK,
                      letterSpacing: -0.5,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              "Commentaire",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Globals.COLOR_TEXT_DARK,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _commentController,
              maxLines: 4,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color: Globals.COLOR_TEXT_GRAY.withOpacity(0.3),
                    width: 1.5,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color: Globals.COLOR_TEXT_GRAY.withOpacity(0.3),
                    width: 1.5,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color: Globals.COLOR_MOVIX,
                    width: 2,
                  ),
                ),
                hintText: "Ajouter un commentaire détaillé...",
                hintStyle: TextStyle(
                  color: Globals.COLOR_TEXT_GRAY.withOpacity(0.7),
                ),
                filled: true,
                fillColor: Globals.COLOR_SURFACE_SECONDARY.withOpacity(0.3),
                contentPadding: const EdgeInsets.all(16),
              ),
              style: TextStyle(
                color: Globals.COLOR_TEXT_DARK,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 20),
            Container(
              decoration: BoxDecoration(
                color: Globals.COLOR_SURFACE_SECONDARY.withOpacity(0.3),
                borderRadius: BorderRadius.circular(16),
              ),
              child: CheckboxListTile(
                value: _invalidGeocodage,
                onChanged: (val) => setState(() => _invalidGeocodage = val!),
                title: Text(
                  "Position GPS incorrecte",
                  style: TextStyle(
                    color: Globals.COLOR_TEXT_DARK,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: Text(
                  "Cocher si le point GPS de la pharmacie ne correspond pas à sa localisation réelle",
                  style: TextStyle(
                    color: Globals.COLOR_TEXT_GRAY,
                    fontSize: 12,
                  ),
                ),
                activeColor: Globals.COLOR_MOVIX,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModernPhotosCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Globals.COLOR_SURFACE,
            Globals.COLOR_SURFACE.withOpacity(0.95),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Globals.COLOR_TEXT_GRAY.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Globals.COLOR_MOVIX_GREEN.withOpacity(0.15),
                        Globals.COLOR_MOVIX_GREEN.withOpacity(0.08),
                      ],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.photo_camera_outlined,
                    color: Globals.COLOR_MOVIX_GREEN,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    "Photos (${_photosBase64.length})",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Globals.COLOR_TEXT_DARK,
                      letterSpacing: -0.5,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              height: 200,
              decoration: BoxDecoration(
                color: Globals.COLOR_SURFACE_SECONDARY.withOpacity(0.3),
                borderRadius: BorderRadius.circular(16),
              ),
              child: PhotoPickerWidget(
                base64Images: _photosBase64,
                onImagesChanged: _onImagesChanged,
                isRequired: false,
                emptyMessage: "Aucune photo prise",
              ),
            ),
          ],
        ),
      ),
    );
  }
}
