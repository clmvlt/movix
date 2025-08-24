import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:movix/Models/Command.dart';
import 'package:movix/Services/globals.dart';

class PharmacyInfoActionWidget extends StatelessWidget {
  final Command command;

  const PharmacyInfoActionWidget({
    super.key,
    required this.command,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 16),
      child: IconButton(
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.info_outline,
            color: Globals.COLOR_TEXT_LIGHT,
            size: 20,
          ),
        ),
        onPressed: () {
          context.push('/pharmacy', extra: {"command": command});
        },
      ),
    );
  }
}