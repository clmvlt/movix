import 'package:flutter/material.dart';

class ModernActionButtonWidget extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;
  final double fontSize;
  final EdgeInsetsGeometry? padding;
  final double iconSize;

  const ModernActionButtonWidget({
    super.key,
    required this.label,
    required this.icon,
    required this.color,
    required this.onPressed,
    this.fontSize = 12,
    this.padding = const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
    this.iconSize = 16,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
      ),
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: iconSize),
        label: Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: fontSize,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          padding: padding,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
      ),
    );
  }
}

class ModernIconButtonWidget extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;
  final double iconSize;
  final EdgeInsetsGeometry? padding;

  const ModernIconButtonWidget({
    super.key,
    required this.icon,
    required this.color,
    required this.onPressed,
    this.iconSize = 18,
    this.padding = const EdgeInsets.all(16),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          padding: padding,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
          minimumSize: const Size(48, 48),
        ),
        child: Icon(icon, size: iconSize),
      ),
    );
  }
}