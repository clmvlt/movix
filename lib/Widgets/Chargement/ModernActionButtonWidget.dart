import 'package:flutter/material.dart';

class ModernActionButtonWidget extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;
  final double size;
  final bool fullWidth;

  const ModernActionButtonWidget({
    super.key,
    required this.label,
    required this.icon,
    required this.color,
    required this.onPressed,
    this.size = 14,
    this.fullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: fullWidth ? double.infinity : null,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
      ),
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 18),
        label: Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: size,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(
            vertical: 16,
            horizontal: fullWidth ? 24 : 20,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
      ),
    );
  }
}