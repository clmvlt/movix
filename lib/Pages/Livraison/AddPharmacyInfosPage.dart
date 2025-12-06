import 'package:flutter/material.dart';
import 'package:movix/Managers/LivraisonManager.dart' show sendPharmacyInformations;
import 'package:movix/Models/Command.dart';
import 'package:movix/Services/globals.dart';
import 'package:movix/Widgets/CustomButton.dart';
import 'package:movix/Widgets/PhotoPickerWidget.dart';
import 'package:movix/Widgets/Livraison/ModernCardWidget.dart';
import 'package:movix/Widgets/Livraison/FormFieldWidget.dart';

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
    return ModernCardWidget(
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ModernCardHeader(
            icon: Icons.info_outlined,
            iconColor: Globals.COLOR_ADAPTIVE_ACCENT,
            title: "Informations complémentaires",
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
          ModernTextFieldWidget(
            controller: _commentController,
            labelText: "Commentaire",
            hintText: "Ajouter un commentaire détaillé...",
            maxLines: 4,
          ),
          const SizedBox(height: 20),
          ModernCheckboxWidget(
            value: _invalidGeocodage,
            onChanged: (val) => setState(() => _invalidGeocodage = val!),
            title: "Position GPS incorrecte",
            subtitle: "Cocher si le point GPS de la pharmacie ne correspond pas à sa localisation réelle",
          ),
        ],
      ),
    );
  }

  Widget _buildModernPhotosCard() {
    return ModernCardWidget(
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ModernCardHeader(
            icon: Icons.photo_camera_outlined,
            iconColor: Globals.COLOR_MOVIX_GREEN,
            title: "Photos (${_photosBase64.length})",
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
    );
  }
}
