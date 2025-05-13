import 'dart:convert';
import 'package:hive/hive.dart';
import 'package:movix/Models/Tour.dart';
import 'package:movix/Managers/CommandManager.dart';
import 'package:movix/Services/globals.dart';

const String _toursBoxName = 'toursBox';

Future<void> storeTours(List<Tour> tours) async {
  Globals.tours = {for (var tour in tours) tour.id: tour};
  await saveToursToHive();
}

Future<void> saveToursToHive() async {
  final box = await Hive.openBox<String>(_toursBoxName);
  await box.clear();
  for (var entry in Globals.tours.entries) {
    await box.put(entry.key, jsonEncode(entry.value.toJson()));
  }
}

Future<void> loadToursFromHive() async {
  try {
    final box = await Hive.openBox<String>(_toursBoxName);
    Map<String, Tour> loadedTours = {};

    for (var key in box.keys) {
      String? jsonStr = box.get(key);
      if (jsonStr != null) {
        Map<String, dynamic> tourData = jsonDecode(jsonStr);
        Tour tour = Tour.fromJson(tourData);
        for (var command in tour.commands.values) {
          updateCommandState(command, () {}, false);
        }
        loadedTours[key] = tour;
      }
    }

    Globals.tours = loadedTours;
  } catch (e) {
    print("Error loading tours from Hive: $e");
  }
}
