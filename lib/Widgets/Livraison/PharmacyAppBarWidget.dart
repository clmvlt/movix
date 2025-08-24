import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:movix/Models/Command.dart';
import 'package:movix/Services/globals.dart';

class PharmacyAppBarWidget extends StatelessWidget implements PreferredSizeWidget {
  final Command command;
  final String subtitle;
  final List<Widget>? actions;

  const PharmacyAppBarWidget({
    super.key,
    required this.command,
    required this.subtitle,
    this.actions,
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
            command.pharmacy.name,
            style: TextStyle(
              color: Globals.COLOR_TEXT_LIGHT,
              fontWeight: FontWeight.w700,
              fontSize: 18,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            subtitle,
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
        onPressed: () => context.pop(),
      ),
      actions: actions,
    );
  }
}