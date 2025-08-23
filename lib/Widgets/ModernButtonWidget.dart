import 'package:flutter/material.dart';

class ModernActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;
  final double fontSize;
  final double iconSize;
  final EdgeInsetsGeometry? padding;
  final double? width;

  const ModernActionButton({
    super.key,
    required this.label,
    required this.icon,
    required this.color,
    required this.onPressed,
    this.fontSize = 14,
    this.iconSize = 18,
    this.padding,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
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
          padding: padding ?? const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
      ),
    );
  }
}

class ModernIconButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;
  final double iconSize;
  final double buttonSize;

  const ModernIconButton({
    super.key,
    required this.icon,
    required this.color,
    required this.onPressed,
    this.iconSize = 18,
    this.buttonSize = 48,
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
          padding: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
          minimumSize: Size(buttonSize, buttonSize),
        ),
        child: Icon(icon, size: iconSize),
      ),
    );
  }
}