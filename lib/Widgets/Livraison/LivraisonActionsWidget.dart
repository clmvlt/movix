import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:movix/Models/Command.dart';
import 'package:movix/Services/globals.dart';
import 'package:movix/Widgets/Livraison/ModernButtonWidget.dart';
import 'package:movix/Widgets/AnomalieMenu.dart';
import 'package:movix/Managers/LivraisonManager.dart';

class LivraisonActionsWidget extends StatelessWidget {
  final Command command;
  final VoidCallback onUpdate;

  const LivraisonActionsWidget({
    super.key,
    required this.command,
    required this.onUpdate,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (Globals.MAP_APP == "Waze")
          ModernIconButtonWidget(
            icon: FontAwesomeIcons.waze,
            color: Globals.COLOR_MOVIX_YELLOW,
            onPressed: () => openMap(command: command),
          ),
        if (Globals.MAP_APP == "Google Maps")
          ModernIconButtonWidget(
            icon: Icons.fmd_good,
            color: Globals.COLOR_MOVIX_YELLOW,
            onPressed: () => openMap(command: command),
          ),
        if (Globals.MAP_APP == "Waze" || Globals.MAP_APP == "Google Maps")
          const SizedBox(width: 8),
        ModernIconButtonWidget(
          icon: FontAwesomeIcons.mapLocation,
          color: Globals.COLOR_MOVIX_GREEN,
          onPressed: () {
            context.push('/mapbox', extra: {'command': command});
          },
        ),
        const SizedBox(width: 8),
        ModernIconButtonWidget(
          icon: FontAwesomeIcons.xmark,
          color: Globals.COLOR_MOVIX_RED,
          onPressed: () {
            ShowLivraisonAnomalieManu(context, command, onUpdate);
          },
        ),
        const SizedBox(width: 8),
        Expanded(
          child: ModernActionButtonWidget(
            label: "Livrer",
            icon: FontAwesomeIcons.solidFlag,
            color: Globals.COLOR_MOVIX,
            onPressed: () {
              context.push('/tour/fslivraison', extra: {
                'command': command,
                'onUpdate': onUpdate,
              });
            },
            iconSize: 16,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}