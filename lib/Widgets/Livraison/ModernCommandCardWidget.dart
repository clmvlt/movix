import 'package:flutter/material.dart';
import 'package:movix/Models/Command.dart';
import 'package:movix/Services/globals.dart';
import 'package:movix/Widgets/CommandWidget.dart';

class ModernCommandCardWidget extends StatelessWidget {
  final Command command;
  final bool isSelected;
  final Widget? expandedContent;
  final VoidCallback? onTap;
  final bool showCommandDetails;

  const ModernCommandCardWidget({
    super.key,
    required this.command,
    this.isSelected = false,
    this.expandedContent,
    this.onTap,
    this.showCommandDetails = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
                color: isSelected 
                    ? Globals.COLOR_TEXT_GRAY.withOpacity(0.3)
                    : Globals.COLOR_TEXT_SECONDARY.withOpacity(0.1),
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (showCommandDetails) ...[
                                  customCardHeader(command, true, true),
                                  const SizedBox(height: 6),
                                  customCity(command),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (expandedContent != null)
                  AnimatedSize(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeInOut,
                    child: isSelected
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
            ),
          ),
        ),
      ),
    );
  }
}