import 'package:flutter/material.dart';
import 'package:movix/Services/globals.dart';

class FormSectionWidget extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData icon;
  final Color iconColor;
  final Widget content;

  const FormSectionWidget({
    super.key,
    required this.title,
    this.subtitle,
    this.icon = Icons.assignment_outlined,
    this.iconColor = const Color(0xFF2196F3), // Globals.COLOR_MOVIX par défaut
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Globals.COLOR_SURFACE,
            Globals.COLOR_SURFACE.withOpacity(0.95),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Globals.COLOR_TEXT_GRAY.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
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
                    size: 20,
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
                          fontSize: 16,
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
              ],
            ),
            const SizedBox(height: 16),
            content,
          ],
        ),
      ),
    );
  }
}