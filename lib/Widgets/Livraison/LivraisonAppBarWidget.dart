import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:movix/Models/Tour.dart';
import 'package:movix/Services/globals.dart';
import 'package:movix/Widgets/Livraison/LivraisonPopupMenuWidget.dart';

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
      title: Text(
        tour.name,
        style: TextStyle(
          color: Globals.COLOR_TEXT_LIGHT,
          fontWeight: FontWeight.w700,
          fontSize: 18,
        ),
      ),
      backgroundColor: Globals.COLOR_MOVIX,
      foregroundColor: Globals.COLOR_TEXT_LIGHT,
      elevation: 0,
      leading: IconButton(
        icon: Icon(Icons.arrow_back_ios, color: Globals.COLOR_TEXT_LIGHT),
        onPressed: () {
          context.pop();
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
            '${_countValidCommands(tour)}/${_countTotalCommands(tour)}',
            style: TextStyle(
              color: Globals.COLOR_TEXT_LIGHT,
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(right: 12),
          child: LivraisonPopupMenuWidget(
            onShowEndedChanged: onShowEndedChanged,
            tour: tour,
          ),
        ),
      ],
    );
  }

  int _countValidCommands(Tour tour) {
    int count = 0;
    for (var command in tour.commands.values) {
      var s = command.status.id;
      if (s == 3 || s == 4 || s == 5 || s == 8 || s == 9) {
        count++;
      }
    }
    return count;
  }

  int _countTotalCommands(Tour tour) {
    int count = 0;
    for (var command in tour.commands.values) {
      if (command.status.id != 7) {
        count++;
      }
    }
    return count;
  }
}