import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:movix/Models/Command.dart';
import 'package:movix/Services/globals.dart';
import 'package:movix/Widgets/PackagesWidget.dart';
import 'package:movix/Widgets/Livraison/index.dart';

class FSLivraisonCommandCardWidget extends StatelessWidget {
  final Command command;
  final VoidCallback onUpdate;

  const FSLivraisonCommandCardWidget({
    super.key,
    required this.command,
    required this.onUpdate,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: ModernCommandCardWidget(
        command: command,
        isSelected: true,
        expandedContent: Column(
          children: [
            CustomListePackages(
              command: command,
              isLivraison: true,
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ModernActionButtonWidget(
                label: "Signaler une anomalie",
                icon: FontAwesomeIcons.warning,
                color: Globals.COLOR_MOVIX_RED,
                onPressed: () async {
                  await context.push('/anomalie', extra: {
                    'command': command,
                    'onUpdate': onUpdate,
                  });
                },
                iconSize: 18,
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
              ),
            ),
          ],
        ),
      ),
    );
  }
}