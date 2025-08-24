import 'package:flutter/material.dart';
import 'package:movix/Services/globals.dart';

class ModernCardWidget extends StatelessWidget {
  final Widget content;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;
  final bool isSelected;
  final VoidCallback? onTap;

  const ModernCardWidget({
    super.key,
    required this.content,
    this.margin,
    this.padding = const EdgeInsets.all(24),
    this.isSelected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin ?? const EdgeInsets.symmetric(horizontal: 0),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(24),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Globals.COLOR_SURFACE,
                  Globals.COLOR_SURFACE.withOpacity(0.95),
                ],
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: isSelected 
                    ? Globals.COLOR_MOVIX.withOpacity(0.5)
                    : Globals.COLOR_TEXT_GRAY.withOpacity(0.3),
                width: isSelected ? 3 : 2,
              ),
            ),
            child: Padding(
              padding: padding!,
              child: content,
            ),
          ),
        ),
      ),
    );
  }
}

class ModernCardHeader extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String? subtitle;
  final Widget? trailing;

  const ModernCardHeader({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.title,
    this.subtitle,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                iconColor.withOpacity(0.15),
                iconColor.withOpacity(0.08),
              ],
            ),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: iconColor,
            size: 24,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Globals.COLOR_TEXT_DARK,
                  letterSpacing: -0.5,
                ),
              ),
              if (subtitle != null)
                Text(
                  subtitle!,
                  style: TextStyle(
                    fontSize: 12,
                    color: Globals.COLOR_TEXT_DARK.withOpacity(0.7),
                    fontWeight: FontWeight.w500,
                  ),
                ),
            ],
          ),
        ),
        if (trailing != null) trailing!,
      ],
    );
  }
}