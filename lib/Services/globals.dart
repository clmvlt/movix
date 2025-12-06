import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:movix/Models/Profil.dart';
import 'package:movix/Models/Tour.dart';
import 'package:movix/Services/scanner.dart';
import 'package:movix/Services/sound.dart';

class Globals {
  static const List<String> _BETA_ACCOUNT_IDS = [
    "6bce8203-058c-43d4-8c92-fc5cad90acc9",
    "09aec7e6-586a-41bb-b6df-52b986a908a6",
  ];

  static String get API_URL {
    if (kDebugMode) {
      return "http://192.168.1.120:8081";
    }
    if (_BETA_ACCOUNT_IDS.contains(profil?.account.id)) {
      return "https://api.beta.movix.fr";
    }
    return "https://api.movix.fr";
  }

  static bool DARK_MODE = true;
  static final ValueNotifier<bool> darkModeNotifier = ValueNotifier<bool>(DARK_MODE);

  static Color get COLOR_MOVIX => darkModeNotifier.value
    ? const Color(0xff123456)
    : const Color(0xff123456);

  // Couleur qui est MOVIX en clair et gris/blanc en dark
  static Color get COLOR_ADAPTIVE_ACCENT => darkModeNotifier.value
    ? const Color.fromARGB(255, 180, 180, 180)
    : const Color(0xff123456);

  static Color get COLOR_MOVIX_RED => darkModeNotifier.value
    ? const Color.fromARGB(255, 214, 45, 45)
    : const Color.fromARGB(255, 155, 9, 9);

  static Color get COLOR_MOVIX_GREEN => darkModeNotifier.value
    ? const Color.fromARGB(255, 7, 134, 28)
    : const Color.fromARGB(255, 7, 134, 28);

  static Color get COLOR_MOVIX_YELLOW => darkModeNotifier.value
    ? const Color.fromARGB(255, 228, 178, 71)
    : const Color.fromARGB(255, 233, 175, 0);
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
    : const Color.fromARGB(255, 120, 120, 120);

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
  static bool VIBRATIONS_ENABLED = false;
  static Profil? profil;
  static Map<String, Tour> tours = {};
  static bool showEnded = false;

  static final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  static DateTime? _lastSnackbarTime;

  static void showSnackbar(
    String message, {
    Duration duration = const Duration(seconds: 3),
    Color? backgroundColor,
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

    // Couleur de fond adaptée au mode sombre/clair
    final bgColor = backgroundColor ?? (darkModeNotifier.value
        ? const Color.fromARGB(255, 50, 50, 50)
        : const Color.fromARGB(255, 40, 40, 40));

    scaffoldMessengerKey.currentState!
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          duration: duration,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          padding: EdgeInsets.zero,
          dismissDirection: DismissDirection.down,
          content: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                if (icon != null) ...[
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: COLOR_TEXT_LIGHT.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      icon,
                      color: COLOR_TEXT_LIGHT,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  child: Text(
                    message,
                    style: TextStyle(
                      color: COLOR_TEXT_LIGHT,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: () {
                      scaffoldMessengerKey.currentState?.hideCurrentSnackBar();
                    },
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      child: Icon(
                        Icons.close,
                        color: COLOR_TEXT_LIGHT.withOpacity(0.7),
                        size: 18,
                      ),
                    ),
                  ),
                ),
              ],
            ),
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
