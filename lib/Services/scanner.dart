import 'package:shared_preferences/shared_preferences.dart';

import 'package:movix/Models/ScanMode.dart';
import 'package:movix/Services/globals.dart';

export 'package:movix/Models/ScanMode.dart';

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