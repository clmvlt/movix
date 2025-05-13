import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:movix/Models/Profil.dart';
import 'package:movix/Models/Tour.dart';

class Globals {
  static const String API_URL = "https://api.movix.fr";
  static const Color COLOR_MOVIX = Color(0xff194fbb);
  static const Color COLOR_MOVIX_RED = Color.fromARGB(255, 177, 11, 11);
  static const Color COLOR_MOVIX_GREEN = Color.fromARGB(255, 8, 146, 31);
  static const Color COLOR_MOVIX_YELLOW = Color(0xFFF5B800);
  static const TextStyle appBarTextStyle = TextStyle(
    fontFamily: 'Roboto',
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );

  static String SOUND_PATH = "basic";
  static String MAP_APP = "Google Maps";
  static String SCAN_MODE = 'Camera';
  static Profil? profil;
  static Map<String, Tour> tours = {};
  static bool showEnded = false;
  static bool get isScannerMode => Globals.SCAN_MODE == 'DT50';

  static final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  static DateTime? _lastSnackbarTime;

  static void showSnackbar(
    String message, {
    Duration duration = const Duration(seconds: 2),
    Color backgroundColor = Colors.black,
    IconData? icon,
  }) {
    if (!(scaffoldMessengerKey.currentState?.mounted ?? false)) return;

    final now = DateTime.now();

    if (_lastSnackbarTime != null &&
        now.difference(_lastSnackbarTime!) <
            const Duration(milliseconds: 500)) {
      return;
    }

    _lastSnackbarTime = now;

    scaffoldMessengerKey.currentState!
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          backgroundColor: backgroundColor,
          duration: duration,
          content: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, color: Colors.white),
                const SizedBox(width: 8),
              ],
              Flexible(child: Text(message)),
            ],
          ),
        ),
      );
  }

  static String getSqlDate() {
    DateTime now = DateTime.now();
    String sqlDate = DateFormat('yyyy-MM-dd HH:mm:ss').format(now);
    return sqlDate;
  }
}
