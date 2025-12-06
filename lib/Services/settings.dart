import 'package:movix/Services/globals.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<String> getMapApp() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? appName = prefs.getString('map_app');

  return appName ?? "Google Maps";
}

Future<void> setMapApp(String appName) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setString('map_app', appName);
  Globals.MAP_APP = appName;
}

Future<bool> getDarkMode() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getBool('dark_mode') ?? false;
}

Future<void> setDarkMode(bool value) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setBool('dark_mode', value);
  Globals.DARK_MODE = value;
  Globals.darkModeNotifier.value = value;
}

Future<bool> getVibrationsEnabled() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getBool('vibrations_enabled') ?? false;
}

Future<void> setVibrationsEnabled(bool value) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setBool('vibrations_enabled', value);
  Globals.VIBRATIONS_ENABLED = value;
}