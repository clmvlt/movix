import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:movix/API/base.dart';
import 'package:movix/Models/Spooler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SpoolerManager {
  static final SpoolerManager _instance = SpoolerManager._internal();

  factory SpoolerManager() {
    return _instance;
  }

  SpoolerManager._internal();

  final Queue<Spooler> queue = Queue();
  bool isProcessing = false;
  static const String storageKey = "spooler_queue";
  String lastError = "";

  void initialize() {
    loadQueue();
  }

  int getTasksCount() {
    return queue.length;
  }

  Future<void> addTasks(List<Spooler> tasks) async {
    for (final task in tasks) {
      queue.add(task);
    }
    await saveQueue();
    await processQueue();
  }

  Future<void> addTask(Spooler task) async {
    queue.add(task);
    await saveQueue();
    await processQueue();
  }

  Future<bool> processQueue() async {
    if (isProcessing) return false;
    isProcessing = true;

    while (queue.isNotEmpty) {
      Spooler task = queue.first;
      bool success = await sendRequest(task);
      if (success) {
        queue.removeFirst();
        await saveQueue();
      } else {
        isProcessing = false;
        return false;
      }
    }

    isProcessing = false;
    return true;
  }

  Future<bool> sendRequest(Spooler task) async {
    try {
      final response = await http.post(
        Uri.parse(task.url),
        headers: task.headers,
        body: jsonEncode(task.body),
      );

      if (ApiBase.isSuccess(response.statusCode)) {
        lastError = "";
        return true;
      } else {
        lastError = response.body;
      }
    } catch (e) {
      lastError = e.toString();
    }
    return false;
  }

  Future<void> sendNextTask() async {
    if (queue.isNotEmpty) {
      Spooler task = queue.first;
      bool success = await sendRequest(task);
      if (success) {
        queue.removeFirst();
        await saveQueue();
      }
    }
  }

  Future<void> saveQueue() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> encodedTasks =
        queue.map((task) => jsonEncode(task.toJson())).toList();
    await prefs.setStringList(storageKey, encodedTasks);
  }

  Future<void> loadQueue() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? encodedTasks = prefs.getStringList(storageKey);
    if (encodedTasks != null) {
      queue.clear();
      queue.addAll(
          encodedTasks.map((task) => Spooler.fromJson(jsonDecode(task))));
    }
  }

  Future<bool> processSingleTask(Spooler task) async {
    bool success = await sendRequest(task);
    if (success) {
      queue.remove(task);
      await saveQueue();
    }
    return success;
  }
}
