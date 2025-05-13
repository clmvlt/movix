
import 'package:shared_preferences/shared_preferences.dart';

import 'globals.dart';

Future<String> getScanMode() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? scanMode = prefs.getString('scan_mode');

  return scanMode ?? "Camera";
}

Future<void> setScanMode(String scanMode) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setString('scan_mode', scanMode);
  Globals.SCAN_MODE = scanMode;
}