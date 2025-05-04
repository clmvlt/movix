import 'dart:convert';

import 'package:movix/Managers/CommandManager.dart';
import 'package:movix/Models/Tour.dart';
import 'package:movix/Services/globals.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> storeTours(List<Tour> tours) async {
  Globals.tours = {
    for (var tour in tours) tour.id: tour,
  };

  await saveToursToPreferences();
}

Future<void> saveToursToPreferences() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  Map<String, String> toursJsonMap = {
    for (var entry in Globals.tours.entries)
      entry.key: jsonEncode(entry.value.toJson())
  };
  await prefs.setString('tours', jsonEncode(toursJsonMap));
}

Future<void> loadToursFromPreferences() async {
  try {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    String? toursJsonMapString = prefs.getString('tours');

    if (toursJsonMapString != null) {
      Map<String, dynamic> toursJsonMap = jsonDecode(toursJsonMapString);
      Map<String, Tour> loadedTours = {};

      for (var entry in toursJsonMap.entries) {
        String key = entry.key;
        Map<String, dynamic> tourData = jsonDecode(entry.value);
        Tour tour = Tour.fromJson(tourData);

        for (var command in tour.commands.values) {
          updateCommandState(command, () {}, false);
        }
        
        loadedTours[key] = tour;
      }

      Globals.tours = loadedTours;
    }
  } catch (e) {
    print("Error loading tours from preferences: $e");
  }
}
