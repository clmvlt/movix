import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:movix/Managers/LivraisonManager.dart';
import 'package:movix/Models/Tour.dart';
import 'package:movix/Services/globals.dart';
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
        if (Globals.MAP_APP == "Waze")
          Expanded(
            child: ModernActionButtonWidget(
              label: "Waze",
              icon: FontAwesomeIcons.waze,
              color: Globals.COLOR_MOVIX_YELLOW,
              onPressed: () => openMap(
                latitude: Globals.profil?.account.latitude,
                longitude: Globals.profil?.account.longitude,
              ),
              iconSize: 16,
              fontSize: 12,
            ),
          ),
        if (Globals.MAP_APP == "Google Maps")
          Expanded(
            child: ModernActionButtonWidget(
              label: "Maps",
              icon: Icons.fmd_good,
              color: Globals.COLOR_MOVIX_YELLOW,
              onPressed: () => openMap(
                latitude: Globals.profil?.account.latitude,
                longitude: Globals.profil?.account.longitude,
              ),
              iconSize: 16,
              fontSize: 12,
            ),
          ),
        if (Globals.MAP_APP == "Waze" || Globals.MAP_APP == "Google Maps")
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
      if (s != 3 && s != 4 && s != 5 && s != 7 && s != 8 && s != 9) {
        return false;
      }
    }
    return true;
  }
}