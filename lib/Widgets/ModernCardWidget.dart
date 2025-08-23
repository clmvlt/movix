import 'package:flutter/material.dart';
import 'package:movix/Services/globals.dart';

class ModernCard extends StatelessWidget {
  final Widget child;
  final bool isSelected;
  final VoidCallback? onTap;
  final Color? borderColor;
  final double borderWidth;
  final EdgeInsetsGeometry? margin;

  const ModernCard({
    super.key,
    required this.child,
    this.isSelected = false,
    this.onTap,
    this.borderColor,
    this.borderWidth = 2,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin ?? const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Container(
            decoration: BoxDecoration(
              color: isSelected 
                  ? Globals.COLOR_SURFACE 
                  : Globals.COLOR_SURFACE.withOpacity(0.7),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: borderColor ?? (isSelected 
                    ? Globals.COLOR_TEXT_GRAY.withOpacity(0.3)
                    : Globals.COLOR_TEXT_SECONDARY.withOpacity(0.1)),
                width: isSelected ? borderWidth : 1,
              ),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

class ModernCardContent extends StatelessWidget {
  final Widget header;
  final Widget? expandedContent;
  final bool isExpanded;
  final Duration animationDuration;

  const ModernCardContent({
    super.key,
    required this.header,
    this.expandedContent,
    this.isExpanded = false,
    this.animationDuration = const Duration(milliseconds: 200),
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          child: header,
        ),
        if (expandedContent != null)
          AnimatedSize(
            duration: animationDuration,
            curve: Curves.easeInOut,
            child: isExpanded
                ? Container(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                    decoration: BoxDecoration(
                      color: Globals.COLOR_SURFACE_SECONDARY.withOpacity(0.5),
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(20),
                        bottomRight: Radius.circular(20),
                      ),
                    ),
                    child: Column(
                      children: [
                        const Divider(height: 1),
                        const SizedBox(height: 16),
                        expandedContent!,
                      ],
                    ),
                  )
                : const SizedBox.shrink(),
          ),
      ],
    );
  }
}