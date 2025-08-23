import 'dart:async';
import 'dart:collection';
import 'dart:convert';

import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:movix/API/base.dart';
import 'package:movix/Models/Spooler.dart';

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

  late Box<String> spoolerBox;

  Future<void> initialize() async {
    spoolerBox = await Hive.openBox<String>('spoolerBox');
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
      await Future<void>.delayed(const Duration(milliseconds: 100));
    }

    isProcessing = false;
    return true;
  }

  Future<bool> sendRequest(Spooler task) async {
    try {
      http.Response? response;
      if (task.formType == 'post') {
        response = await http.post(
          Uri.parse(task.url),
          headers: {
            ...task.headers,
            'Content-Type': 'application/json',
          },
          body: jsonEncode(task.body),
        );
      } else if (task.formType == 'put') {
        response = await http.put(
          Uri.parse(task.url),
          headers: {
            ...task.headers,
            'Content-Type': 'application/json',
          },
          body: jsonEncode(task.body),
        );
      }

      if (response != null && ApiBase.isSuccess(response.statusCode)) {
        lastError = "";
        return true;
      } else if (response != null) {
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
      await spoolerBox.put(i, queue.elementAt(i).toString());
    }
  }

  Future<void> loadQueue() async {
    queue.clear();
    for (int i = 0; i < spoolerBox.length; i++) {
      final task = spoolerBox.get(i);
      if (task != null) {
        queue.add(Spooler.fromJson(jsonDecode(task) as Map<String, dynamic>));
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
