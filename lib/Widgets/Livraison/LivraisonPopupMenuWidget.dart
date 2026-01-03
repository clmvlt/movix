import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:movix/Models/Tour.dart';
import 'package:movix/Services/globals.dart';

class LivraisonPopupMenuWidget extends StatefulWidget {
  final VoidCallback onShowEndedChanged;
  final Tour tour;

  const LivraisonPopupMenuWidget({
    super.key,
    required this.onShowEndedChanged,
    required this.tour,
  });

  @override
  State<LivraisonPopupMenuWidget> createState() => _LivraisonPopupMenuWidgetState();
}

class _LivraisonPopupMenuWidgetState extends State<LivraisonPopupMenuWidget> {
  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      offset: const Offset(0, 50),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Globals.COLOR_SURFACE,
      elevation: 8,
      onSelected: (value) {
        switch (value) {
          case 'toggle_ended':
            setState(() {
              Globals.showEnded = !Globals.showEnded;
            });
            widget.onShowEndedChanged();
            break;
          case 'reorder':
            context.push('/tour/reorder', extra: {
              'tour': widget.tour,
              'onOrderChanged': widget.onShowEndedChanged,
            });
            break;
          case 'spooler':
            context.push('/spooler');
            break;
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem<String>(
          value: 'toggle_ended',
          padding: EdgeInsets.zero,
          child: _buildToggleEndedMenuItem(),
        ),
        const PopupMenuDivider(height: 1),
        PopupMenuItem<String>(
          value: 'reorder',
          padding: EdgeInsets.zero,
          child: _buildReorderMenuItem(),
        ),
        const PopupMenuDivider(height: 1),
        PopupMenuItem<String>(
          value: 'spooler',
          padding: EdgeInsets.zero,
          child: _buildSpoolerMenuItem(),
        ),
      ],
      child: Container(
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
    );
  }

  Widget _buildToggleEndedMenuItem() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Globals.COLOR_ADAPTIVE_ACCENT.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Globals.showEnded ? Icons.visibility_off : Icons.visibility,
              color: Globals.COLOR_ADAPTIVE_ACCENT,
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
              Globals.showEnded ? Icons.check : Icons.check_box_outline_blank,
              color: Globals.showEnded
                  ? Globals.COLOR_MOVIX_GREEN
                  : Globals.COLOR_TEXT_DARK.withOpacity(0.5),
              size: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReorderMenuItem() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Globals.COLOR_ADAPTIVE_ACCENT.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.reorder,
              color: Globals.COLOR_ADAPTIVE_ACCENT,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Réorganiser la tournée',
                  style: TextStyle(
                    color: Globals.COLOR_TEXT_DARK,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Modifier l\'ordre des commandes',
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
    );
  }

  Widget _buildSpoolerMenuItem() {
    return Container(
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
    );
  }
}
