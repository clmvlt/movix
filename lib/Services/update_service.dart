import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:movix/API/update_fetcher.dart';
import 'package:movix/Pages/Others/UpdatePage.dart';
import 'package:movix/Services/globals.dart';
import 'package:movix/Services/update_check_cache.dart';
import 'package:open_filex/open_filex.dart';
import 'package:package_info_plus/package_info_plus.dart';

Future<String?> getDownloadableVersion() async {
  final update = await getLatestUpdate();
  return update?.version;
}

Future<String?> getChangeLog() async {
  final update = await getLatestUpdate();
  return update?.filePath;
}

Future<bool> canUpdate() async {
  final packageInfo = await PackageInfo.fromPlatform();
  final currentVersion = packageInfo.version;
  final serverVersion = await getDownloadableVersion();

  // Enregistre la date/heure du check
  await UpdateCheckCache.saveLastCheckTime();

  return serverVersion != null && serverVersion != currentVersion;
}

Future<bool> checkForUpdates({
  void Function(double)? onProgress,
  CancelToken? cancelToken,
  required String savePath,
}) async {
  if (await canUpdate()) {
    final update = await getLatestUpdate();
    if (update == null) throw Exception("Erreur serveur");
    
    final filePath = await downloadUpdate(update.id, (progress, bytesReceived) {
      if (onProgress != null) onProgress(progress);
    });
    
    if (filePath != null) {
      await OpenFilex.open(filePath);
      return true;
    }
  }
  return false;
}

/// Vérifie les mises à jour avec gestion du cache (12h)
/// Si force=true, ignore le cache et vérifie toujours
Future<void> checkAndShowUpdateDialog(BuildContext context, {bool force = false}) async {
  if (!Platform.isAndroid) return;

  // Vérifie si un check est nécessaire (12h écoulées)
  if (!force && !UpdateCheckCache.shouldCheckForUpdate()) {
    return;
  }

  // Effectue le check
  if (await canUpdate()) {
    final currentVersion = await getAppVersion();
    final downloadableVersion = await getDownloadableVersion();

    if (downloadableVersion != null && context.mounted) {
      await showDialog<void>(
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
                  MaterialPageRoute<void>(builder: (context) => const UpdatePage()),
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

/// Ancienne fonction - maintenue pour compatibilité
@Deprecated('Utiliser checkAndShowUpdateDialog à la place')
Future<void> showUpdateDialog(BuildContext context) async {
  await checkAndShowUpdateDialog(context, force: true);
}

Future<String> getAppVersion() async {
  final packageInfo = await PackageInfo.fromPlatform();
  return packageInfo.version;
}
