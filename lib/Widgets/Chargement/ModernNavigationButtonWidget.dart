import 'package:flutter/material.dart';
import 'package:movix/Services/globals.dart';

class ModernNavigationButtonWidget extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final bool isEnabled;

  const ModernNavigationButtonWidget({
    super.key,
    required this.icon,
    required this.onPressed,
    required this.isEnabled,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onPressed,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isEnabled
                  ? Globals.COLOR_MOVIX
                  : Globals.COLOR_TEXT_SECONDARY.withOpacity(0.3),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              icon,
              color: isEnabled
                  ? Colors.white
                  : Globals.COLOR_TEXT_SECONDARY,
              size: 24,
            ),
          ),
        ),
      ),
    );
  }
}