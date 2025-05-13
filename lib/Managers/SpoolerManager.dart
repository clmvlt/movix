import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'package:hive/hive.dart';
import 'package:movix/API/base.dart';
import 'package:movix/Models/Spooler.dart';
import 'package:http/http.dart' as http;

class SpoolerManager {
  static final SpoolerManager _instance = SpoolerManager._internal();

  factory SpoolerManager() {
    return _instance;
  }

  SpoolerManager._internal();

  final Queue<Spooler> queue = Queue();
  bool isProcessing = false;
  String lastError = "";
  static const int batchSize = 10;

  late Box<Spooler> spoolerBox;

  Future<void> initialize() async {
    spoolerBox = await Hive.openBox<Spooler>('spoolerBox');
    await loadQueue();
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
      final batch = queue.take(batchSize).toList();
      for (final task in batch) {
        bool success = await sendRequest(task);
        if (success) {
          queue.remove(task);
        } else {
          isProcessing = false;
          await saveQueue();
          return false;
        }
      }
      await saveQueue();
      await Future.delayed(Duration(milliseconds: 100));
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
    await spoolerBox.clear();
    for (int i = 0; i < queue.length; i++) {
      await spoolerBox.put(i, queue.elementAt(i));
    }
  }

  Future<void> loadQueue() async {
    queue.clear();
    for (int i = 0; i < spoolerBox.length; i++) {
      final task = spoolerBox.get(i);
      if (task != null) {
        queue.add(task);
      }
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
