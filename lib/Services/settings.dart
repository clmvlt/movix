import 'package:shared_preferences/shared_preferences.dart';
import 'package:movix/Services/globals.dart';

Future<String> getSoundPATH() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? soundPath = prefs.getString('sound_path');

  return soundPath ?? "basic";
}

Future<void> setSoundPATH(String soundPath) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setString('sound_path', soundPath);
  Globals.SOUND_PATH = soundPath;
}

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