import 'dart:io';

import 'package:dio/dio.dart';
import 'package:movix/API/base.dart';
import 'package:movix/Models/Update.dart';
import 'package:movix/Services/globals.dart';


Future<List<Update>> getAllUpdates() async {
  try {
    final response = await ApiBase.get('/updates');

    if (!ApiBase.isSuccess(response.statusCode)) return [];

    final data = ApiBase.decodeResponse(response);
    final List<Update> updates = [];
    
    if (data is List) {
      for (var updateJson in data) {
        if (updateJson is Map<String, dynamic>) {
          final update = Update.fromJson(updateJson);
          updates.add(update);
        }
      }
    }

    return updates;
  } catch (e) {
    print(e);
    return [];
  }
}

Future<Update?> getLatestUpdate() async {
  try {
    final response = await ApiBase.get('/updates/latest');

    if (!ApiBase.isSuccess(response.statusCode)) return null;

    final data = ApiBase.decodeResponse(response) as Map<String, dynamic>;
    return Update.fromJson(data);
  } catch (e) {
    print(e);
    return null;
  }
}

Future<Update?> getUpdateByVersion(String version) async {
  try {
    final response = await ApiBase.get('/updates/$version');

    if (!ApiBase.isSuccess(response.statusCode)) return null;

    final data = ApiBase.decodeResponse(response) as Map<String, dynamic>;
    return Update.fromJson(data);
  } catch (e) {
    print(e);
    return null;
  }
}

Future<String?> downloadUpdate(String version, void Function(double, int) onProgress, {CancelToken? cancelToken}) async {
  try {
    final dio = Dio();
    final url = '${Globals.API_URL}/updates/download/$version';
    
    final tempDir = await Directory.systemTemp.createTemp();
    final savePath = '${tempDir.path}/update_$version.apk';
    
    await dio.download(
      url,
      savePath,
      options: Options(
        headers: ApiBase.headers(),
        followRedirects: true,
        validateStatus: (status) => status! < 500,
      ),
      cancelToken: cancelToken,
      onReceiveProgress: (received, total) {
        if (total != -1) {
          final progress = received / total;
          onProgress(progress, received);
        }
      },
    );
    
    return savePath;
  } catch (e) {
    print(e);
    return null;
  }
}
