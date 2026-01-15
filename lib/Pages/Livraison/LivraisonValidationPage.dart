import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:movix/Managers/LivraisonManager.dart';
import 'package:movix/Models/Command.dart';
import 'package:movix/Services/globals.dart';
import 'package:movix/Services/map_service.dart';
import 'package:movix/Widgets/CustomButton.dart';
import 'package:movix/Widgets/PhotoPickerWidget.dart';

class LivraisonValidationPage extends StatefulWidget {
  final List<Command> commands;
  final VoidCallback onUpdate;
  final int popCount;

  const LivraisonValidationPage({
    super.key,
    required this.commands,
    required this.onUpdate,
    this.popCount = 2,
  });

  @override
  _LivraisonValidationPageState createState() =>
      _LivraisonValidationPageState();
}

class _LivraisonValidationPageState extends State<LivraisonValidationPage> {
  List<String> base64Images = [];

  /// Première commande (utilisée pour les infos communes)
  Command get _firstCommand => widget.commands.first;

  /// Nombre de commandes dans le groupe
  bool get _isGroup => widget.commands.length > 1;

  void onUpdate() {
    setState(() {});
    widget.onUpdate;
  }

  void _onImagesChanged(List<String> newImages) {
    setState(() {
      base64Images = newImages;
    });
  }

  /// Trouve et lance le GPS vers la prochaine livraison non livrée
  void _launchGpsForNextDelivery() {
    final tour = Globals.tours[_firstCommand.tourId];
    if (tour == null) return;

    // Récupérer les commandes triées par tourOrder
    final commands = tour.commands.values.toList()
      ..sort((a, b) => a.tourOrder.compareTo(b.tourOrder));

    // IDs des commandes du groupe actuel à ignorer
    final currentCommandIds = widget.commands.map((c) => c.id).toSet();

    // Trouver la prochaine commande non livrée (status != 3, 4, 5, 7, 8, 9)
    Command? nextCommand;
    for (final cmd in commands) {
      // Ignorer les commandes du groupe actuel et les commandes déjà livrées/annulées
      if (currentCommandIds.contains(cmd.id)) continue;
      final statusId = cmd.status.id;
      // Status 3=livré, 4=livré partiel, 5=anomalie, 7=annulé, 8=refusé, 9=absent
      if (statusId != 3 && statusId != 4 && statusId != 5 &&
          statusId != 7 && statusId != 8 && statusId != 9) {
        nextCommand = cmd;
        break;
      }
    }

    // Lancer le GPS si une prochaine commande existe
    if (nextCommand != null) {
      MapService.instance.openNavigation(
        latitude: nextCommand.pharmacy.latitude,
        longitude: nextCommand.pharmacy.longitude,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Globals.COLOR_BACKGROUND,
      appBar: AppBar(
        toolbarTextStyle: Globals.appBarTextStyle,
        titleTextStyle: Globals.appBarTextStyle,
        title: Text(
          "Validation de livraison",
          style: TextStyle(
            color: Globals.COLOR_TEXT_LIGHT,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
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
                        _isGroup
                            ? "Livraison terminée (${widget.commands.length} commandes)"
                            : "Livraison terminée",
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
                    // Valider toutes les commandes du groupe avec les mêmes photos
                    ValidLivraisonCommands(
                        widget.commands, base64Images, widget.onUpdate);

                    // Lancement automatique du GPS vers la prochaine livraison
                    if (Globals.AUTO_LAUNCH_GPS) {
                      _launchGpsForNextDelivery();
                    }

                    // Retour à LivraisonPage (pop selon le nombre de pages à dépiler)
                    for (int i = 0; i < widget.popCount; i++) {
                      context.pop();
                    }
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
