import 'dart:io';
import 'package:flutter/material.dart';
import 'package:movix/Managers/ChargementManager.dart';
import 'package:movix/Models/PackageSearcher.dart';
import 'package:movix/Models/Tour.dart';
import 'ModernNavigationButtonWidget.dart';
import 'ValidationButtonWidget.dart';

class NavigationBottomBarWidget extends StatelessWidget {
  final Tour tour;
  final PackageSearcher packageSearcher;
  final int currentIndex;
  final int totalCommands;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  const NavigationBottomBarWidget({
    super.key,
    required this.tour,
    required this.packageSearcher,
    required this.currentIndex,
    required this.totalCommands,
    required this.onPrevious,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 0,
      right: 0,
      bottom: Platform.isIOS ? 16 : 0,
      child: Container(
        margin: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ModernNavigationButtonWidget(
              icon: Icons.arrow_back_ios,
              onPressed: currentIndex < totalCommands - 1 ? onNext : null,
              isEnabled: currentIndex < totalCommands - 1,
            ),
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                child: ValidationButtonWidget(
                  tour: tour,
                  packageSearcher: packageSearcher,
                  isVisible: isChargementComplet(tour),
                ),
              ),
            ),
            ModernNavigationButtonWidget(
              icon: Icons.arrow_forward_ios,
              onPressed: currentIndex > 0 ? onPrevious : null,
              isEnabled: currentIndex > 0,
            ),
          ],
        ),
      ),
    );
  }
}