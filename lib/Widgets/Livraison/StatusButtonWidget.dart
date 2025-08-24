import 'package:flutter/material.dart';
import 'package:movix/Services/globals.dart';

class StatusButtonWidget extends StatelessWidget {
  final bool isValid;
  final String validText;
  final String invalidText;
  final IconData validIcon;
  final IconData invalidIcon;
  final VoidCallback onPressed;
  final Color? validColor;
  final Color? invalidColor;

  const StatusButtonWidget({
    super.key,
    required this.isValid,
    required this.validText,
    required this.invalidText,
    this.validIcon = Icons.check_circle,
    this.invalidIcon = Icons.warning,
    required this.onPressed,
    this.validColor,
    this.invalidColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
      ),
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(
          isValid ? validIcon : invalidIcon,
          size: 20,
        ),
        label: Text(
          isValid ? validText : invalidText,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: isValid 
              ? (validColor ?? Globals.COLOR_MOVIX_GREEN)
              : (invalidColor ?? Globals.COLOR_MOVIX_RED),
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 58),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
      ),
    );
  }
}

class CIPStatusButtonWidget extends StatusButtonWidget {
  const CIPStatusButtonWidget({
    super.key,
    required bool cipScanned,
    required VoidCallback onPressed,
  }) : super(
    isValid: cipScanned,
    validText: 'CIP Validé',
    invalidText: 'CIP non validé',
    validIcon: Icons.check_circle,
    invalidIcon: Icons.warning,
    onPressed: onPressed,
  );
}