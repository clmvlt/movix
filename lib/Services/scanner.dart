
import 'package:shared_preferences/shared_preferences.dart';

import 'globals.dart';

Future<bool> isScannerMode() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool? isScanner = prefs.getBool('isScanner');

  return isScanner ?? false;
}

Future<void> setScannerMode(bool isScanner) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setBool('isScanner', isScanner);
  Globals.isScannerMode = isScanner;
}