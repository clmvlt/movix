import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:movix/Pages/Others/UpdatePage.dart';
import 'package:movix/Services/globals.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:http/http.dart' as http;
import 'package:dio/dio.dart';
import 'package:open_filex/open_filex.dart';

Future<String?> getDownloadableVersion() async {
  final response = await http.get(Uri.parse('${Globals.API_URL}/version'));
  if (response.statusCode == 200) {
    final serverData = jsonDecode(response.body);
    return serverData['version'];
  } else {
    throw Exception(
        "Erreur lors de la récupération de la version téléchargeable");
  }
}

Future<String?> getChangeLog() async {
  final response = await http.get(Uri.parse('${Globals.API_URL}/version'));
  if (response.statusCode == 200) {
    final serverData = jsonDecode(response.body);
    return serverData['change_log'];
  } else {
    throw Exception("Erreur lors de la récupération du changelog");
  }
}

Future<bool> canUpdate() async {
  final packageInfo = await PackageInfo.fromPlatform();
  final currentVersion = packageInfo.version;
  final serverVersion = await getDownloadableVersion();

  return serverVersion != null && serverVersion != currentVersion;
}

Future<bool> checkForUpdates({
  Function(double)? onProgress,
  CancelToken? cancelToken,
  required String savePath,
}) async {
  if (await canUpdate()) {
    final response = await http.get(Uri.parse('${Globals.API_URL}/version'));
    if (response.statusCode != 200) throw Exception("Erreur serveur");
    final apkUrl = jsonDecode(response.body)['apk_url'];

    await downloadAndInstallApk(apkUrl,
        savePath: savePath, onProgress: onProgress, cancelToken: cancelToken);
    return true;
  }
  return false;
}

Future<void> showUpdateDialog(BuildContext context) async {
      if (!Platform.isAndroid) return;
      
      final currentVersion = await getAppVersion();
      final downloadableVersion = await getDownloadableVersion();

      if (downloadableVersion != null &&
          downloadableVersion != currentVersion) {
        if (context.mounted) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => AlertDialog(
              title: const Text(
                "Mise à jour disponible",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              content: Text(
                "Une nouvelle version de l'application est disponible.\n\n"
                "Version actuelle : $currentVersion\n"
                "Nouvelle version : $downloadableVersion\n\n",
                style: const TextStyle(fontSize: 16),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const UpdatePage()),
                    );
                  },
                  child: const Text(
                    "Mettre à jour",
                    style: TextStyle(fontSize: 16, color: Globals.COLOR_MOVIX),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text(
                    "Plus tard",
                    style: TextStyle(fontSize: 16, color: Globals.COLOR_MOVIX),
                  ),
                ),
              ],
            ),
          );
        }
      }
    }

Future<void> downloadAndInstallApk(
  String apkUrl, {
  required String savePath,
  Function(double)? onProgress,
  CancelToken? cancelToken,
}) async {
  try {
    await Dio().download(
      apkUrl,
      savePath,
      onReceiveProgress: (received, total) {
        if (total > 0 && onProgress != null) {
          onProgress(received / total);
        }
      },
      cancelToken: cancelToken,
      options: Options(
          responseType: ResponseType.bytes,
          followRedirects: false,
          validateStatus: (status) => status! < 500),
    );

    if (await File(savePath).exists()) {
      await OpenFilex.open(savePath);
    } else {
      throw Exception("Fichier APK introuvable après téléchargement");
    }
  } catch (e) {
    if (e is DioException && CancelToken.isCancel(e)) {
      print("Téléchargement annulé : ${e.message}");
    } else {
      rethrow;
    }
  }
}

Future<String> getAppVersion() async {
  final packageInfo = await PackageInfo.fromPlatform();
  return packageInfo.version;
}
