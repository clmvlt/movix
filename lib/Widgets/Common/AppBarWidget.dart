import 'package:flutter/material.dart';
import 'package:movix/Services/globals.dart';

class CustomAppBarWidget extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String? subtitle;
  final List<Widget>? actions;
  final Widget? leading;
  final bool automaticallyImplyLeading;

  const CustomAppBarWidget({
    super.key,
    required this.title,
    this.subtitle,
    this.actions,
    this.leading,
    this.automaticallyImplyLeading = true,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      toolbarTextStyle: Globals.appBarTextStyle,
      titleTextStyle: Globals.appBarTextStyle,
      title: subtitle != null ? Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: Globals.COLOR_TEXT_LIGHT,
              fontWeight: FontWeight.w700,
              fontSize: 18,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            subtitle!,
            style: TextStyle(
              color: Globals.COLOR_TEXT_LIGHT.withOpacity(0.8),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ) : Text(
        title,
        style: TextStyle(
          color: Globals.COLOR_TEXT_LIGHT,
          fontWeight: FontWeight.w700,
          fontSize: 18,
        ),
        overflow: TextOverflow.ellipsis,
      ),
      backgroundColor: Globals.COLOR_MOVIX,
      foregroundColor: Globals.COLOR_TEXT_LIGHT,
      elevation: 0,
      leading: leading,
      automaticallyImplyLeading: automaticallyImplyLeading,
      actions: actions,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}