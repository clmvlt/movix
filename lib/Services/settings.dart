import 'package:movix/Services/globals.dart';
import 'package:movix/Services/map_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<MapApp> getMapApp() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? storageKey = prefs.getString('map_app');

  if (storageKey == null) {
    return MapService.getDefaultApp();
  }
  return MapAppExtension.fromStorageKey(storageKey);
}

Future<void> setMapApp(MapApp app) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setString('map_app', app.storageKey);
  Globals.MAP_APP = app;
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

Future<bool> getAutoLaunchGps() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getBool('auto_launch_gps') ?? false;
}

Future<void> setAutoLaunchGps(bool value) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setBool('auto_launch_gps', value);
  Globals.AUTO_LAUNCH_GPS = value;
}

Future<bool> getSoundEnabled() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getBool('sound_enabled') ?? true;
}

Future<void> setSoundEnabled(bool value) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setBool('sound_enabled', value);
  Globals.SOUND_ENABLED = value;
}

Future<bool> getCameraTorchEnabled() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getBool('camera_torch_enabled') ?? false;
}

Future<void> setCameraTorchEnabled(bool value) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setBool('camera_torch_enabled', value);
  Globals.CAMERA_TORCH_ENABLED = value;
}

Future<bool> getCameraExtended() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getBool('camera_extended') ?? false;
}

Future<void> setCameraExtended(bool value) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setBool('camera_extended', value);
  Globals.CAMERA_EXTENDED = value;
}

Future<DateTime> getManageToursSelectedDate() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? dateStr = prefs.getString('manage_tours_selected_date');
  if (dateStr != null) {
    return DateTime.parse(dateStr);
  }
  return DateTime.now();
}

Future<void> setManageToursSelectedDate(DateTime date) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setString('manage_tours_selected_date', date.toIso8601String());
}