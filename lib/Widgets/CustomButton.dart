import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:movix/Services/globals.dart';

Widget customButton({
  String label = '',
  VoidCallback? onPressed,
  Color color = Globals.COLOR_MOVIX,
  double fontSize = 18,
  double verticalPadding = 16.0,
  double horizontalPadding = 12.0,
  double borderRadius = 15.0,
  double bottomPadding = 16.0,
  double topPadding = 0,
}) {

  return Padding(
    padding: EdgeInsets.symmetric(horizontal: horizontalPadding).copyWith(bottom: bottomPadding, top: topPadding),
    child: SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.symmetric(vertical: verticalPadding),
          textStyle: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.w600,
          ),
          backgroundColor: color,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          elevation: 5,
          shadowColor: Colors.black.withOpacity(0.1),
          splashFactory: InkRipple.splashFactory,
        ),
        child: Text(label),
      ),
    ),
  );
}

Widget customToolButton({
  String text = '',
  String? iconAssetPath,
  IconData? iconData,
  VoidCallback? onPressed,
  Color color = Globals.COLOR_MOVIX,
  double height = 50,
  double borderRadius = 15.0,
}) {
  return SizedBox(
    height: height,
    child: ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        backgroundColor: color,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        elevation: 5,
        shadowColor: Colors.black.withOpacity(0.1),
        splashFactory: InkRipple.splashFactory,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            text,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
              color: Colors.white,
            ),
          ),
          if (iconAssetPath != null || iconData != null) ...[
            const SizedBox(width: 10),
            iconAssetPath != null
                ? SvgPicture.asset(
                    iconAssetPath,
                    height: height * 0.4,
                    width: height * 0.4,
                    colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                  )
                : Icon(
                    iconData,
                    size: height * 0.4,
                    color: Colors.white,
                  ),
          ],
        ],
      ),
    ),
  );
}

Widget customRoundIconButton({
  String? iconAssetPath,
  IconData? iconData,
  VoidCallback? onPressed,
  Color color = Globals.COLOR_MOVIX,
  double size = 50,
}) {
  return SizedBox(
    height: size,
    width: size,
    child: ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        shape: const CircleBorder(),
        padding: EdgeInsets.all(size * 0.2),
        elevation: 5,
        shadowColor: Colors.black.withOpacity(0.1),
        splashFactory: InkRipple.splashFactory,
      ),
      child: iconAssetPath != null
          ? SvgPicture.asset(
              iconAssetPath,
              height: size * 0.45,
              width: size * 0.45,
              colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
            )
          : Icon(
              iconData,
              size: size * 0.45,
              color: Colors.white,
            ),
    ),
  );
}
