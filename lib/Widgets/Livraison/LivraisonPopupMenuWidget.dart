import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:movix/Services/globals.dart';

class LivraisonPopupMenuWidget extends StatelessWidget {
  final VoidCallback onShowEndedChanged;

  const LivraisonPopupMenuWidget({
    super.key,
    required this.onShowEndedChanged,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          Icons.more_vert, 
          color: Globals.COLOR_TEXT_LIGHT,
          size: 20,
        ),
      ),
      color: Colors.transparent,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      offset: const Offset(0, 8),
      onSelected: (value) {
        if (value == 'spooler') {
          context.push('/spooler');
        }
      },
      itemBuilder: (BuildContext context) {
        return [
          PopupMenuItem<String>(
            padding: EdgeInsets.zero,
            child: Container(
              decoration: BoxDecoration(
                color: Globals.COLOR_SURFACE,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildToggleEndedMenuItem(),
                  Container(
                    height: 1,
                    color: Globals.COLOR_TEXT_DARK.withOpacity(0.1),
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                  _buildSpoolerMenuItem(context),
                ],
              ),
            ),
          ),
        ];
      },
    );
  }

  Widget _buildToggleEndedMenuItem() {
    return StatefulBuilder(
      builder: (context, setState) {
        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              setState(() {
                Globals.showEnded = !Globals.showEnded;
              });
              onShowEndedChanged();
            },
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Globals.COLOR_MOVIX.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Globals.showEnded
                          ? Icons.visibility_off
                          : Icons.visibility,
                      color: Globals.COLOR_MOVIX,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          Globals.showEnded ? 'Masquer les terminés' : 'Afficher les terminés',
                          style: TextStyle(
                            color: Globals.COLOR_TEXT_DARK,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          Globals.showEnded 
                            ? 'Afficher seulement les actifs' 
                            : 'Voir toutes les commandes',
                          style: TextStyle(
                            color: Globals.COLOR_TEXT_DARK.withOpacity(0.6),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Globals.showEnded 
                        ? Globals.COLOR_MOVIX_GREEN.withOpacity(0.2)
                        : Globals.COLOR_TEXT_DARK.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Icon(
                      Globals.showEnded
                          ? Icons.check
                          : Icons.check_box_outline_blank,
                      color: Globals.showEnded 
                        ? Globals.COLOR_MOVIX_GREEN
                        : Globals.COLOR_TEXT_DARK.withOpacity(0.5),
                      size: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSpoolerMenuItem(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          Navigator.pop(context);
          context.push('/spooler');
        },
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Globals.COLOR_MOVIX_YELLOW.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  FontAwesomeIcons.clockRotateLeft,
                  color: Globals.COLOR_MOVIX_YELLOW,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Voir le spooler',
                      style: TextStyle(
                        color: Globals.COLOR_TEXT_DARK,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Gérer les tâches en attente',
                      style: TextStyle(
                        color: Globals.COLOR_TEXT_DARK.withOpacity(0.6),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: Globals.COLOR_TEXT_DARK.withOpacity(0.3),
                size: 14,
              ),
            ],
          ),
        ),
      ),
    );
  }
}