import 'package:flutter/material.dart';
import 'package:movix/Services/globals.dart';

enum BadgeSize { small, medium, large }

class BadgeStyle {
  static const Map<BadgeSize, double> sizes = {
    BadgeSize.small: 24.0,
    BadgeSize.medium: 32.0,
    BadgeSize.large: 40.0,
  };

  static const Map<BadgeSize, double> fontSizes = {
    BadgeSize.small: 10.0,
    BadgeSize.medium: 12.0,
    BadgeSize.large: 14.0,
  };

  static const Map<BadgeSize, EdgeInsets> paddings = {
    BadgeSize.small: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
    BadgeSize.medium: EdgeInsets.symmetric(horizontal: 10, vertical: 3),
    BadgeSize.large: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
  };
}

Widget newBadge({BadgeSize size = BadgeSize.medium}) {
  final double badgeSize = BadgeStyle.sizes[size]!;
  return Container(
    height: badgeSize,
    padding: BadgeStyle.paddings[size],
    decoration: BoxDecoration(
      color: Globals.COLOR_MOVIX_RED,
      borderRadius: BorderRadius.circular(badgeSize / 2),
    ),
    child: Center(
      child: Text(
        'NEW',
        style: TextStyle(
          color: Globals.COLOR_TEXT_LIGHT,
          fontSize: BadgeStyle.fontSizes[size],
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
  );
}

Widget packagesNumberBadge(int number, {BadgeSize size = BadgeSize.medium}) {
  final double badgeSize = BadgeStyle.sizes[size]!;
  return Container(
    height: badgeSize,
    padding: BadgeStyle.paddings[size],
    decoration: BoxDecoration(
      color: Globals.COLOR_MOVIX,
      borderRadius: BorderRadius.circular(badgeSize / 2),
    ),
    child: Center(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "$number",
            style: TextStyle(
              fontSize: BadgeStyle.fontSizes[size],
              fontWeight: FontWeight.w600,
              color: Globals.COLOR_TEXT_LIGHT,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            "📦",
            style: TextStyle(
              fontSize: BadgeStyle.fontSizes[size],
            ),
          ),
        ],
      ),
    ),
  );
}
