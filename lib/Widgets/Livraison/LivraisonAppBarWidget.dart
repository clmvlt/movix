import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:movix/Models/Tour.dart';
import 'package:movix/Services/globals.dart';
import 'package:movix/Widgets/Livraison/LivraisonPopupMenuWidget.dart';
import 'package:movix/Managers/LivraisonManager.dart';

class LivraisonAppBarWidget extends StatelessWidget implements PreferredSizeWidget {
  final Tour tour;
  final VoidCallback onShowEndedChanged;

  const LivraisonAppBarWidget({
    super.key,
    required this.tour,
    required this.onShowEndedChanged,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      toolbarTextStyle: Globals.appBarTextStyle,
      titleTextStyle: Globals.appBarTextStyle,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            tour.name,
            style: TextStyle(
              color: Globals.COLOR_TEXT_LIGHT,
              fontWeight: FontWeight.w700,
              fontSize: 18,
            ),
          ),
          Text(
            'Livraison en cours',
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
      leading: IconButton(
        icon: Icon(Icons.arrow_back_ios, color: Globals.COLOR_TEXT_LIGHT),
        onPressed: () {
          context.go('/tours');
        },
      ),
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 8),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            '${countValidCommands(tour)}/${countTotalCommands(tour)}',
            style: TextStyle(
              color: Globals.COLOR_TEXT_LIGHT,
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
          ),
        ),
        LivraisonPopupMenuWidget(
          onShowEndedChanged: onShowEndedChanged,
        ),
      ],
    );
  }
}