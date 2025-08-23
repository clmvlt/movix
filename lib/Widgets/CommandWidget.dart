import 'package:flutter/material.dart';
import 'package:movix/Models/Command.dart';
import 'package:movix/Services/affichage.dart';
import 'package:movix/Services/globals.dart';
import 'package:movix/Widgets/BadgeWidget.dart';

Widget customCardHeader(Command command, bool isLivraison, bool fullScreen) {
  double badgeWidth = 5;

  if (command.newPharmacy) {
    badgeWidth += 35;
  }
  if (!fullScreen) {
    badgeWidth += 35;
  }

  return Stack(
    children: [
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 24,
            child: isLivraison
                ? GetLivraisonIconCommandStatus(command, 20)
                : GetChargementIconCommandStatus(command, 20),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Padding(
              padding:
                  EdgeInsets.only(right: badgeWidth), // Espace pour les badges
              child: Text(
                command.pharmacy.name,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Globals.COLOR_TEXT_DARK,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: fullScreen ? 10 : 1,
                textAlign: TextAlign.start,
              ),
            ),
          ),
        ],
      ),
      Positioned(
        top: 0,
        right: 0,
        child: Row(
          children: [
            if (command.newPharmacy) ...[
              newBadge(size: BadgeSize.small),
              const SizedBox(width: 2),
            ],
            if (!fullScreen) ...[
              packagesNumberBadge(command.packages.length,
                  size: BadgeSize.small),
            ]
          ],
        ),
      ),
    ],
  );
}

Widget customCity(Command command) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 4.0),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "${command.pharmacy.address1} ${command.pharmacy.address2} ${command.pharmacy.address3}"
                    .trim(),
                style: TextStyle(
                  fontSize: 12,
                  color: Globals.COLOR_TEXT_DARK_SECONDARY,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                "${command.pharmacy.postalCode} ${command.pharmacy.city}",
                style: TextStyle(
                  fontSize: 12,
                  color: Globals.COLOR_TEXT_DARK_SECONDARY,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
