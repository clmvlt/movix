import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:movix/Managers/LivraisonManager.dart';
import 'package:movix/Models/Command.dart';
import 'package:movix/Services/globals.dart';
import 'package:movix/Widgets/CustomButton.dart';
import 'package:movix/Widgets/PhotoPickerWidget.dart';

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
  List<String> base64Images = [];

  void onUpdate() {
    setState(() {});
    widget.onUpdate;
  }

  void _onImagesChanged(List<String> newImages) {
    setState(() {
      base64Images = newImages;
    });
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
              "Validation de livraison",
              style: TextStyle(
                color: Globals.COLOR_TEXT_LIGHT,
                fontWeight: FontWeight.w700,
                fontSize: 18,
              ),
            ),
            Text(
              widget.command.pharmacy.name,
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
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              FontAwesomeIcons.camera,
              size: 18,
              color: Globals.COLOR_TEXT_LIGHT,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Globals.COLOR_SURFACE,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Globals.COLOR_MOVIX_GREEN.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    FontAwesomeIcons.circleCheck,
                    color: Globals.COLOR_MOVIX_GREEN,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Livraison terminée",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Globals.COLOR_TEXT_DARK,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Ajoutez une photo pour confirmer",
                        style: TextStyle(
                          fontSize: 14,
                          color: Globals.COLOR_TEXT_DARK.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Globals.COLOR_SURFACE,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: PhotoPickerWidget(
                  base64Images: base64Images,
                  onImagesChanged: _onImagesChanged,
                  isRequired: true,
                ),
              ),
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
                          'tour': Globals.tours[widget.command.tourId]
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
