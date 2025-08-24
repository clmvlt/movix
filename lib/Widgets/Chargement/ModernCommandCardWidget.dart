import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:movix/Models/Command.dart';
import 'package:movix/Models/PackageSearcher.dart';
import 'package:movix/Models/Tour.dart';
import 'package:movix/Services/globals.dart';
import 'package:movix/Widgets/AnomalieMenu.dart';
import 'package:movix/Widgets/CommandWidget.dart';
import 'package:movix/Widgets/PackagesWidget.dart';
import 'ModernActionButtonWidget.dart';

class ModernCommandCardWidget extends StatelessWidget {
  final Command command;
  final bool isSelected;
  final bool isFullScreenMode;
  final Tour? tour;
  final PackageSearcher? packageSearcher;
  final VoidCallback onTap;
  final VoidCallback onUpdate;
  final AnimationController animationController;

  const ModernCommandCardWidget({
    super.key,
    required this.command,
    required this.isSelected,
    required this.onTap,
    required this.onUpdate,
    required this.animationController,
    this.isFullScreenMode = false,
    this.tour,
    this.packageSearcher,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animationController,
      builder: (context, child) {
        return Container(
          margin: EdgeInsets.symmetric(
            horizontal: isFullScreenMode ? 8 : 0,
            vertical: isFullScreenMode ? 8 : 12,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(20),
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: isFullScreenMode ? null : onTap,
              child: Container(
                decoration: BoxDecoration(
                  color: isSelected || isFullScreenMode
                      ? Globals.COLOR_SURFACE
                      : Globals.COLOR_SURFACE.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected || isFullScreenMode
                        ? Globals.COLOR_TEXT_GRAY.withOpacity(0.3)
                        : Globals.COLOR_TEXT_SECONDARY.withOpacity(0.1),
                    width: isSelected || isFullScreenMode ? 2 : 1,
                  ),
                  boxShadow: isSelected || isFullScreenMode ? [
                    BoxShadow(
                      color: Globals.COLOR_MOVIX.withOpacity(0.15),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ] : [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
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
                                    customCardHeader(command, false, isFullScreenMode),
                                    const SizedBox(height: 6),
                                    customCity(command),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    AnimatedSize(
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeInOut,
                      child: isSelected || isFullScreenMode
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
                                  CustomListePackages(
                                    command: command,
                                    isLivraison: false,
                                  ),
                                  const SizedBox(height: 20),
                                  _buildActionButtons(context),
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
      },
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    if (isFullScreenMode) {
      return ModernActionButtonWidget(
        label: "Non chargé",
        size: 12,
        icon: FontAwesomeIcons.xmark,
        color: Globals.COLOR_MOVIX_RED,
        onPressed: () {
          ShowChargementAnomalieManu(
            context,
            command,
            onUpdate,
          );
        },
        fullWidth: true,
      );
    }

    return Row(
      children: [
        Expanded(
          child: ModernActionButtonWidget(
            label: "Non chargé",
            size: 12,
            icon: FontAwesomeIcons.xmark,
            color: Globals.COLOR_MOVIX_RED,
            onPressed: () {
              ShowChargementAnomalieManu(
                context,
                command,
                onUpdate,
              );
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ModernActionButtonWidget(
            label: "Scanner",
            icon: Icons.qr_code_scanner,
            color: Globals.COLOR_MOVIX,
            onPressed: () {
              if (tour != null && packageSearcher != null) {
                context.push(
                  "/tour/fschargement",
                  extra: {
                    "onUpdate": onUpdate,
                    'tour': tour,
                    'packageSearcher': packageSearcher,
                    "command": command
                  },
                );
              }
            },
          ),
        ),
      ],
    );
  }
}