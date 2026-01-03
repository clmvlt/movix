import 'dart:async';
import 'dart:io';

import 'package:android_intent_plus/android_intent.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:movix/API/update_fetcher.dart';
import 'package:movix/Models/Update.dart';
import 'package:movix/Services/date_service.dart';
import 'package:movix/Services/globals.dart';
import 'package:movix/Services/update_service.dart';
import 'package:open_filex/open_filex.dart';
import 'package:package_info_plus/package_info_plus.dart';
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
  String? serverVersion;
  List<Update> updates = [];
  CancelToken? cancelToken;
  String? downloadingVersion;
  int downloadedBytes = 0;
  int downloadSpeed = 0;
  DateTime? lastUpdateTime;
  int lastDownloadedBytes = 0;
  Timer? speedTimer;
  String formattedSpeed = "0 Mo/s";
  bool showAllVersions = false;

  @override
  void initState() {
    super.initState();
    if (Platform.isAndroid) {
      _getAppVersion();
      _loadUpdates();
    } else if (Platform.isIOS) {
      _getAppVersion();
    }
  }

  @override
  void dispose() {
    speedTimer?.cancel();
    super.dispose();
  }

  Future<void> _getAppVersion() async {
    final packageInfo = await PackageInfo.fromPlatform();
    final downloadableVersion = await getDownloadableVersion();

    setState(() {
      appVersion = packageInfo.version;
      serverVersion = downloadableVersion;
      updateAvailable = serverVersion != null && serverVersion != appVersion;
    });
  }

  Future<void> _loadUpdates() async {
    final allUpdates = await getAllUpdates();
    setState(() {
      updates = allUpdates;
    });
  }

  String _formatSpeed(int bytesPerSecond) {
    if (bytesPerSecond < 1024) {
      return "$bytesPerSecond o/s";
    } else if (bytesPerSecond < 1024 * 1024) {
      return "${(bytesPerSecond / 1024).toStringAsFixed(1)} Ko/s";
    } else {
      return "${(bytesPerSecond / (1024 * 1024)).toStringAsFixed(1)} Mo/s";
    }
  }

  void _updateDownloadSpeed() {
    final now = DateTime.now();
    if (lastUpdateTime != null) {
      final timeDiff = now.difference(lastUpdateTime!).inMilliseconds;
      if (timeDiff > 0) {
        final bytesDiff = downloadedBytes - lastDownloadedBytes;
        downloadSpeed = (bytesDiff * 1000 ~/ timeDiff);
        formattedSpeed = _formatSpeed(downloadSpeed);
        lastDownloadedBytes = downloadedBytes;
        lastUpdateTime = now;
      }
    }
  }

  Future<bool> _checkUnknownSources() async {
    if (!Platform.isAndroid) return true;
    
    final androidInfo = await DeviceInfoPlugin().androidInfo;
    final sdkInt = androidInfo.version.sdkInt;
    
    if (sdkInt >= 26) {
      final status = await Permission.requestInstallPackages.status;
      return status.isGranted;
    }
    return true;
  }

  Future<void> _openUnknownSourcesSettings() async {
    if (!Platform.isAndroid) return;
    
    final androidInfo = await DeviceInfoPlugin().androidInfo;
    final sdkInt = androidInfo.version.sdkInt;
    final packageInfo = await PackageInfo.fromPlatform();
    
    if (sdkInt >= 26) {
      final intent = AndroidIntent(
        action: 'android.settings.MANAGE_UNKNOWN_APP_SOURCES',
        data: 'package:${packageInfo.packageName}',
      );
      await intent.launch();
    } else {
      const intent = AndroidIntent(
        action: 'android.settings.SECURITY_SETTINGS',
      );
      await intent.launch();
    }
  }

  Future<void> _downloadUpdate(Update update) async {
    if (!await _requestPermissions()) return;

    if (!await _checkUnknownSources()) {
      showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("Autorisation requise", style: TextStyle(color: Globals.COLOR_TEXT_DARK)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Pour installer les mises à jour, vous devez autoriser l'installation d'applications depuis des sources inconnues.",
                style: TextStyle(color: Globals.COLOR_TEXT_DARK),
              ),
              const SizedBox(height: 16),
              Text(
                "Comment faire :",
                style: TextStyle(fontWeight: FontWeight.bold, color: Globals.COLOR_TEXT_DARK),
              ),
              const SizedBox(height: 8),
              Text(
                "1. Appuyez sur 'Paramètres' ci-dessous\n"
                "2. Activez 'Autoriser l'installation d'applications'\n"
                "3. Revenez à l'application et réessayez",
                style: TextStyle(color: Globals.COLOR_TEXT_DARK),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Annuler", style: TextStyle(color: Globals.COLOR_MOVIX_RED)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _openUnknownSourcesSettings();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Globals.COLOR_MOVIX,
                foregroundColor: Globals.COLOR_TEXT_LIGHT,
              ),
              child: const Text("Paramètres"),
            ),
          ],
        ),
      );
      return;
    }

    if (cancelToken != null) {
      cancelToken!.cancel("Nouveau téléchargement démarré");
      cancelToken = null;
    }

    setState(() {
      isUpdating = true;
      progress = 0.0;
      downloadingVersion = update.version;
      cancelToken = CancelToken();
      downloadedBytes = 0;
      downloadSpeed = 0;
      formattedSpeed = "0 Mo/s";
      lastUpdateTime = DateTime.now();
      lastDownloadedBytes = 0;
    });

    speedTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if (isUpdating) {
        _updateDownloadSpeed();
        setState(() {});
      } else {
        timer.cancel();
      }
    });

    try {
      final dir = await getExternalStorageDirectory();
      if (dir == null) throw Exception("Accès au stockage impossible.");

      final filePath = await downloadUpdate(update.id, (double value, int bytesReceived) {
        setState(() {
          progress = value;
          downloadedBytes = bytesReceived;
        });
      }, cancelToken: cancelToken);

      if (filePath != null && cancelToken != null) {
        await OpenFilex.open(filePath);
        _showMessage("Téléchargement terminé. L'APK va s'ouvrir.",
            Icons.check_circle, Globals.COLOR_MOVIX_GREEN);
      }
    } catch (e) {
      if (e is DioException && CancelToken.isCancel(e)) {
        _showMessage("Téléchargement annulé.", Icons.cancel, Globals.COLOR_MOVIX_YELLOW);
      } else {
        _showMessage("Erreur: $e", Icons.error, Globals.COLOR_MOVIX_RED);
      }
    } finally {
      speedTimer?.cancel();
      setState(() {
        isUpdating = false;
        downloadingVersion = null;
        cancelToken = null;
        downloadSpeed = 0;
        formattedSpeed = "0 Mo/s";
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
    if (cancelToken != null) {
      cancelToken!.cancel("Téléchargement annulé par l'utilisateur.");
      cancelToken = null;
    }
    speedTimer?.cancel();
    setState(() {
      isUpdating = false;
      progress = 0.0;
      downloadingVersion = null;
      downloadSpeed = 0;
      formattedSpeed = "0 Mo/s";
      downloadedBytes = 0;
      lastDownloadedBytes = 0;
    });
  }

  void _showMessage(String message, IconData icon, Color color) {
    Globals.showSnackbar(message, backgroundColor: color, icon: icon);
  }

  bool _isTestFlightInstalled() {
    if (!Platform.isIOS) return false;
    // Sur iOS, on détecte si l'app est en mode TestFlight via le profil de provisionnement
    // Note: Une vraie détection nécessiterait du code natif, mais on peut utiliser
    // la présence du receipt pour détecter TestFlight
    return const bool.fromEnvironment('dart.vm.product') == false;
  }

  Future<void> _launchTestFlight() async {
    final testFlightLink = Uri.parse('itms-beta://');
    if (await canLaunchUrl(testFlightLink)) {
      await launchUrl(testFlightLink, mode: LaunchMode.externalApplication);
    } else {
      final fallback = Uri.parse('https://apps.apple.com/app/testflight/id899247664');
      if (await canLaunchUrl(fallback)) {
        await launchUrl(fallback, mode: LaunchMode.externalApplication);
      } else {
        _showMessage("Impossible d'ouvrir TestFlight.", Icons.error, Globals.COLOR_MOVIX_RED);
      }
    }
  }

  Future<void> _launchAppStore() async {
    // Remplacez l'ID par votre ID d'application App Store
    final appStoreLink = Uri.parse('https://apps.apple.com/app/idVOTRE_APP_ID');
    if (await canLaunchUrl(appStoreLink)) {
      await launchUrl(appStoreLink, mode: LaunchMode.externalApplication);
    } else {
      _showMessage("Impossible d'ouvrir l'App Store.", Icons.error, Globals.COLOR_MOVIX_RED);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Globals.COLOR_BACKGROUND,
        appBar: AppBar(
        toolbarTextStyle: Globals.appBarTextStyle,
        titleTextStyle: Globals.appBarTextStyle,
        backgroundColor: Globals.COLOR_MOVIX,
        foregroundColor: Globals.COLOR_TEXT_LIGHT,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text("Mise à jour"),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Platform.isAndroid ? _buildAndroidContent() : _buildIOSContent(),
        ),
      ),
    );
  }

  Widget _buildAndroidContent() {
    final displayedUpdates = showAllVersions ? updates : updates.take(5).toList();
    
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Version actuelle
          Card(
            elevation: 0,
            color: Globals.COLOR_SURFACE,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Version actuelle : $appVersion",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Globals.COLOR_TEXT_DARK)),
                  const SizedBox(height: 10),
                  Text(
                    updateAvailable
                        ? "Nouvelle version disponible : $serverVersion"
                        : "Votre application est à jour",
                    style: TextStyle(
                      fontSize: 16,
                      color: updateAvailable
                          ? Globals.COLOR_MOVIX_YELLOW
                          : Globals.COLOR_MOVIX_GREEN,
                    ),
                  ),
                  if (updateAvailable) ...[
                    const SizedBox(height: 15),
                    ElevatedButton.icon(
                      onPressed: isUpdating ? null : () => _downloadUpdate(updates.first),
                      icon: Icon(Icons.download, color: Globals.COLOR_TEXT_LIGHT),
                      label: Text(
                        "Télécharger la mise à jour",
                        style: TextStyle(color: Globals.COLOR_TEXT_LIGHT),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Globals.COLOR_MOVIX,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          
          // Barre de téléchargement (toujours au-dessus de la liste)
          Card(
            elevation: 0,
            color: Globals.COLOR_SURFACE,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isUpdating ? "Téléchargement en cours..." : "État du téléchargement",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Globals.COLOR_TEXT_DARK)
                  ),
                  const SizedBox(height: 15),
                  LinearProgressIndicator(
                      value: progress,
                      backgroundColor: Globals.COLOR_TEXT_GRAY,
                      color: Globals.COLOR_MOVIX),
                  const SizedBox(height: 10),
                  if (isUpdating) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("${(progress * 100).toStringAsFixed(0)}% téléchargé",
                            style: TextStyle(color: Globals.COLOR_TEXT_DARK)),
                        Text(
                          "${(downloadedBytes / (1024 * 1024)).toStringAsFixed(1)} Mo / $formattedSpeed",
                          style: TextStyle(color: Globals.COLOR_TEXT_DARK_SECONDARY),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    Center(
                      child: ElevatedButton(
                        onPressed: _cancelDownload,
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Globals.COLOR_MOVIX_RED,
                            foregroundColor: Globals.COLOR_TEXT_LIGHT),
                        child: Text("Annuler", style: TextStyle(color: Globals.COLOR_TEXT_LIGHT)),
                      ),
                    )
                  ] else ...[
                    Text(
                      "Aucun téléchargement en cours",
                      style: TextStyle(color: Globals.COLOR_TEXT_DARK_SECONDARY),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          
          // Liste des versions
          if (updates.isNotEmpty) ...[
            Text("Versions disponibles :",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Globals.COLOR_TEXT_DARK)),
            const SizedBox(height: 10),
            ...displayedUpdates.map((update) => Card(
              elevation: 0,
              color: Globals.COLOR_SURFACE,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                title: Text("Version ${update.version}",
                    style: TextStyle(fontWeight: FontWeight.w600, color: Globals.COLOR_TEXT_DARK)),
                subtitle: Text("Publiée le ${DateService.formatDateTime(update.createdAt)}",
                    style: TextStyle(color: Globals.COLOR_TEXT_DARK_SECONDARY)),
                trailing: downloadingVersion == update.version
                    ? SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Globals.COLOR_ADAPTIVE_ACCENT),
                        ),
                      )
                    : IconButton(
                        icon: Icon(Icons.download, color: Globals.COLOR_ADAPTIVE_ACCENT),
                        onPressed: isUpdating ? null : () => _downloadUpdate(update),
                      ),
              ),
            )),
            
            // Bouton "Afficher plus" ou "Afficher moins"
            if (updates.length > 5) ...[
              const SizedBox(height: 15),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      showAllVersions = !showAllVersions;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Globals.COLOR_MOVIX,
                    foregroundColor: Globals.COLOR_TEXT_LIGHT,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    showAllVersions ? "Afficher moins" : "Afficher plus (${updates.length - 5} autres)",
                    style: TextStyle(color: Globals.COLOR_TEXT_LIGHT),
                  ),
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildIOSContent() {
    final isTestFlight = _isTestFlightInstalled();

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Carte avec la version actuelle
        Card(
          elevation: 0,
          color: Globals.COLOR_SURFACE,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Version actuelle : $appVersion",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Globals.COLOR_TEXT_DARK)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 30),
        Icon(Icons.info_outline, size: 80, color: Globals.COLOR_MOVIX),
        const SizedBox(height: 20),
        Text(
          isTestFlight
            ? "Les mises à jour se font via TestFlight."
            : "Les mises à jour se font via l'App Store.",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Globals.COLOR_TEXT_DARK)
        ),
        const SizedBox(height: 20),
        ElevatedButton.icon(
          onPressed: isTestFlight ? _launchTestFlight : _launchAppStore,
          icon: Icon(Icons.open_in_new, color: Globals.COLOR_TEXT_LIGHT),
          label: Text(
            isTestFlight ? "Ouvrir TestFlight" : "Ouvrir l'App Store",
            style: TextStyle(color: Globals.COLOR_TEXT_LIGHT)
          ),
          style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              backgroundColor: Globals.COLOR_MOVIX,
              foregroundColor: Globals.COLOR_TEXT_LIGHT,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
        ),
      ],
    );
  }
}