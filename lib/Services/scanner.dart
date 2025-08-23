import 'package:shared_preferences/shared_preferences.dart';

import 'globals.dart';

Future<ScanMode> getScanMode() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  ScanMode scanMode = stringToScanMode(prefs.getString('scan_mode') ?? "");
  
  return scanMode;
}

Future<void> setScanMode(String value) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  ScanMode scanMode = stringToScanMode(value);
  prefs.setString('scan_mode', scanMode.name);
  Globals.SCAN_MODE = scanMode;
}

enum ScanMode {
  Camera,
  Text,
  Scanneur
}

ScanMode stringToScanMode(String value) {
  return ScanMode.values.firstWhere(
    (e) => e.name == value,
    orElse: () => ScanMode.Camera,
  );
}