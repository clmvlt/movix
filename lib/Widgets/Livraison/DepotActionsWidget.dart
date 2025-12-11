import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:movix/Managers/LivraisonManager.dart';
import 'package:movix/Models/Tour.dart';
import 'package:movix/Services/globals.dart';
import 'package:movix/Services/map_service.dart';
import 'package:movix/Widgets/Livraison/ModernButtonWidget.dart';

class DepotActionsWidget extends StatefulWidget {
  final Tour tour;
  final VoidCallback onUpdate;

  const DepotActionsWidget({
    super.key,
    required this.tour,
    required this.onUpdate,
  });

  @override
  State<DepotActionsWidget> createState() => _DepotActionsWidgetState();
}

class _DepotActionsWidgetState extends State<DepotActionsWidget> {
  bool validationLoading = false;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ModernActionButtonWidget(
            label: _getMapButtonLabel(),
            icon: _getMapButtonIcon(),
            color: Globals.COLOR_MOVIX_YELLOW,
            onPressed: () => MapService.instance.openNavigation(
              latitude: Globals.profil?.account.latitude,
              longitude: Globals.profil?.account.longitude,
            ),
            iconSize: 16,
            fontSize: 12,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 2,
          child: validationLoading
              ? Container(
                  padding: const EdgeInsets.all(16),
                  child: const Center(child: CircularProgressIndicator()),
                )
              : ModernActionButtonWidget(
                  label: "Valider",
                  icon: FontAwesomeIcons.flagCheckered,
                  color: Globals.COLOR_MOVIX,
                  onPressed: () async {
                    if (_isTourComplet(widget.tour)) {
                      setState(() {
                        validationLoading = true;
                      });
                      await ValidLivraisonTour(context, widget.tour, widget.onUpdate);
                      setState(() {
                        validationLoading = false;
                      });
                    } else {
                      Globals.showSnackbar(
                        'Merci de renseigner toutes les positions.',
                        backgroundColor: Globals.COLOR_MOVIX_RED,
                      );
                    }
                  },
                  iconSize: 16,
                  fontSize: 12,
                ),
        ),
      ],
    );
  }

  bool _isTourComplet(Tour tour) {
    for (var command in tour.commands.values) {
      var s = command.status.id;
      if (s != 3 && s != 4 && s != 5 && s != 6 && s != 7 && s != 8 && s != 9) {
        return false;
      }
    }
    return true;
  }

  String _getMapButtonLabel() {
    switch (Globals.MAP_APP) {
      case MapApp.waze:
        return "Waze";
      case MapApp.appleMaps:
        return "Plans";
      case MapApp.googleMaps:
        return "Maps";
    }
  }

  IconData _getMapButtonIcon() {
    switch (Globals.MAP_APP) {
      case MapApp.waze:
        return FontAwesomeIcons.waze;
      case MapApp.appleMaps:
        return Icons.map;
      case MapApp.googleMaps:
        return Icons.fmd_good;
    }
  }
}