import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:movix/Models/Profil.dart';
import 'package:movix/Models/Tour.dart';
import 'package:movix/Services/scanner.dart';
import 'package:movix/Services/sound.dart';

class Globals {
  static const String API_URL = "https://api.movix.fr";

  static bool DARK_MODE = true;
  static final ValueNotifier<bool> darkModeNotifier = ValueNotifier<bool>(DARK_MODE);

  static const Color COLOR_MOVIX = Color(0xff123456);
  static const Color COLOR_MOVIX_RED = Color.fromARGB(255, 155, 9, 9);
  static const Color COLOR_MOVIX_GREEN = Color.fromARGB(255, 7, 134, 28);
  static const Color COLOR_MOVIX_YELLOW = Color.fromARGB(255, 233, 175, 0);
  static const Color COLOR_AVTRANS = Color(0xFF282e88);

  static Color get COLOR_BACKGROUND => darkModeNotifier.value 
    ? const Color.fromARGB(255, 18, 18, 18)
    : const Color.fromARGB(255, 232, 233, 236);

  static Color get COLOR_SURFACE => darkModeNotifier.value
    ? const Color.fromARGB(255, 43, 43, 43)
    : const Color.fromARGB(255, 255, 255, 255);

  static Color get COLOR_SURFACE_SECONDARY => darkModeNotifier.value
    ? const Color.fromARGB(255, 36, 36, 36)
    : const Color.fromARGB(255, 236, 236, 236);

  static Color get COLOR_UNSELECTED => darkModeNotifier.value
    ? const Color.fromARGB(255, 32, 32, 32)
    : const Color.fromARGB(255, 226, 226, 226);
  
  static Color get COLOR_TEXT_LIGHT => darkModeNotifier.value
    ? const Color.fromARGB(255, 240, 240, 240)
    : const Color.fromARGB(255, 255, 255, 255);

  static Color get COLOR_TEXT_SECONDARY => darkModeNotifier.value
    ? const Color.fromARGB(255, 180, 180, 180)
    : const Color.fromARGB(255, 212, 212, 212);

  static Color get COLOR_SHADOW => darkModeNotifier.value
    ? const Color.fromARGB(255, 0, 0, 0)
    : const Color.fromARGB(255, 194, 194, 194);

  static Color get COLOR_TEXT_DARK => darkModeNotifier.value
    ? const Color.fromARGB(255, 240, 240, 240)
    : const Color.fromARGB(255, 17, 17, 17);

  static Color get COLOR_TEXT_DARK_SECONDARY => darkModeNotifier.value
    ? const Color.fromARGB(255, 200, 200, 200)
    : const Color.fromARGB(255, 41, 41, 41);

  static Color get COLOR_LIGHT_GRAY => darkModeNotifier.value
    ? const Color.fromARGB(255, 100, 100, 100)
    : const Color.fromARGB(255, 146, 146, 146);

  static Color get COLOR_TEXT_GRAY => darkModeNotifier.value
    ? const Color.fromARGB(255, 150, 150, 150)
    : const Color.fromARGB(255, 100, 100, 100);

  static TextStyle get appBarTextStyle => TextStyle(
    fontFamily: 'Roboto',
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: COLOR_TEXT_LIGHT,
  );

  static SoundPack SOUND_PACK = SoundPack.Basic;
  static String MAP_APP = "Google Maps";
  static ScanMode SCAN_MODE = ScanMode.Camera;
  static Profil? profil;
  static Map<String, Tour> tours = {};
  static bool showEnded = false;

  static final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  static DateTime? _lastSnackbarTime;

  static void showSnackbar(
    String message, {
    Duration duration = const Duration(seconds: 2),
    Color backgroundColor = const Color.fromARGB(255, 17, 17, 17),
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
                Icon(icon, color: Globals.COLOR_TEXT_LIGHT),
                const SizedBox(width: 8),
              ],
              Flexible(child: Text(message,
                  style: TextStyle(color: Globals.COLOR_TEXT_LIGHT))),
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
