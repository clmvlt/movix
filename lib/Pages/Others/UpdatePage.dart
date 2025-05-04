import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:movix/Services/globals.dart';
import 'package:movix/Services/update_service.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';

class UpdatePage extends StatefulWidget {
  const UpdatePage({super.key});

  @override
  _UpdatePageState createState() => _UpdatePageState();
}

class _UpdatePageState extends State<UpdatePage> {
  String appVersion = "Version inconnue";
  double progress = 0.0;
  bool isUpdating = false;
  bool updateAvailable = false;
  String serverChangeLog = "";
  String? serverVersion;
  CancelToken? cancelToken;

  @override
  void initState() {
    super.initState();
    if (Platform.isAndroid) _getAppVersion();
  }

  Future<void> _getAppVersion() async {
    final packageInfo = await PackageInfo.fromPlatform();
    final downloadableVersion = await getDownloadableVersion();
    final changeLog = await getChangeLog();

    setState(() {
      appVersion = packageInfo.version;
      serverVersion = downloadableVersion;
      serverChangeLog = changeLog ?? "";
      updateAvailable = serverVersion != null && serverVersion != appVersion;
    });
  }

  Future<void> _checkForUpdates() async {
    if (!await _requestPermissions()) return;

    setState(() {
      isUpdating = true;
      progress = 0.0;
      cancelToken = CancelToken();
    });

    try {
      final dir = await getExternalStorageDirectory();
      if (dir == null) throw Exception("Accès au stockage impossible.");

      final apkPath = "${dir.path}/movix_update.apk";

      final updated = await checkForUpdates(
        onProgress: (value) {
          setState(() => progress = value);
        },
        cancelToken: cancelToken,
        savePath: apkPath,
      );

      if (updated) {
        _showMessage("Téléchargement terminé. L'APK va s'ouvrir.",
            Icons.check_circle, Globals.COLOR_MOVIX_GREEN);
      } else {
        _showMessage(
            "Votre application est à jour.", Icons.info, Globals.COLOR_MOVIX);
      }
    } catch (e) {
      if (e is DioException && CancelToken.isCancel(e)) {
        _showMessage("Téléchargement annulé.", Icons.cancel, Colors.orange);
      } else {
        _showMessage("Erreur: $e", Icons.error, Globals.COLOR_MOVIX_RED);
      }
    } finally {
      setState(() {
        isUpdating = false;
        cancelToken = null;
      });
    }
  }

  Future<bool> _requestPermissions() async {
    if (!Platform.isAndroid) return false;

    final androidInfo = await DeviceInfoPlugin().androidInfo;
    final sdkInt = androidInfo.version.sdkInt;

    if (sdkInt >= 33) {
      final images = await Permission.photos.request();
      final videos = await Permission.videos.request();
      final audio = await Permission.audio.request();

      return images.isGranted || videos.isGranted || audio.isGranted;
    } else {
      final storage = await Permission.storage.request();
      return storage.isGranted;
    }
  }

  void _cancelDownload() {
    cancelToken?.cancel("Téléchargement annulé par l'utilisateur.");
    setState(() {
      isUpdating = false;
      progress = 0.0;
    });
  }

  void _showMessage(String message, IconData icon, Color color) {
    Globals.showSnackbar(message, backgroundColor: color, icon: icon);
  }

  Future<void> _launchTestFlight() async {
    final testFlightLink = Uri.parse('itms-beta://');
    if (await canLaunchUrl(testFlightLink)) {
      await launchUrl(testFlightLink, mode: LaunchMode.externalApplication);
    } else {
      final fallback =
          Uri.parse('https://apps.apple.com/app/testflight/id899247664');
      if (await canLaunchUrl(fallback)) {
        await launchUrl(fallback, mode: LaunchMode.externalApplication);
      } else {
        _showMessage("Impossible d'ouvrir TestFlight.", Icons.error,
            Globals.COLOR_MOVIX_RED);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F7),
      appBar: AppBar(
        toolbarTextStyle: Globals.appBarTextStyle,
        titleTextStyle: Globals.appBarTextStyle,
        backgroundColor: Globals.COLOR_MOVIX,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text("Mise à jour"),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child:
              Platform.isAndroid ? _buildAndroidContent() : _buildIOSContent(),
        ),
      ),
    );
  }

  Widget _buildAndroidContent() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            elevation: 3,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Version actuelle : $appVersion",
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 10),
                  Text(
                    updateAvailable
                        ? "Nouvelle version disponible : $serverVersion"
                        : "Votre application est à jour",
                    style: TextStyle(
                      fontSize: 16,
                      color: updateAvailable
                          ? Colors.orange
                          : Globals.COLOR_MOVIX_GREEN,
                    ),
                  ),
                  if (serverChangeLog.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    const Text("Nouveautés :",
                        style:
                            TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text(serverChangeLog,
                        style:
                            const TextStyle(fontSize: 15, color: Colors.black87)),
                  ]
                ],
              ),
            ),
          ),
          const SizedBox(height: 30),
          ElevatedButton.icon(
            onPressed: isUpdating ? null : _checkForUpdates,
            icon: const Icon(Icons.system_update),
            label: Text(isUpdating
                ? "Mise à jour en cours..."
                : updateAvailable
                    ? "Télécharger la mise à jour"
                    : "Vérifier les mises à jour"),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              backgroundColor: const Color(0xFF242957),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 20),
          if (isUpdating) ...[
            LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.grey[300],
                color: const Color(0xFF242957)),
            const SizedBox(height: 10),
            Center(
              child: Text("${(progress * 100).toStringAsFixed(0)}% téléchargé",
                  style: const TextStyle(fontSize: 16)),
            ),
            const SizedBox(height: 10),
            Center(
              child: ElevatedButton(
                onPressed: _cancelDownload,
                child: const Text("Annuler"),
                style: ElevatedButton.styleFrom(
                    backgroundColor: Globals.COLOR_MOVIX_RED,
                    foregroundColor: Colors.white),
              ),
            )
          ],
        ],
      ),
    );
  }

  Widget _buildIOSContent() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Icon(Icons.info_outline, size: 80, color: Colors.blueAccent),
        const SizedBox(height: 20),
        const Text("Les mises à jour se font via TestFlight.",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
        const SizedBox(height: 20),
        ElevatedButton.icon(
          onPressed: _launchTestFlight,
          icon: const Icon(Icons.open_in_new),
          label: const Text("Ouvrir TestFlight"),
          style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              backgroundColor: const Color(0xFF242957),
              foregroundColor: Colors.white,
              shape:
                  RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
        ),
      ],
    );
  }
}