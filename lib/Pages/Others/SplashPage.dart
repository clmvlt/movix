import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_map_tile_caching/flutter_map_tile_caching.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:movix/Managers/SpoolerManager.dart';
import 'package:movix/Managers/TourManager.dart';
import 'package:movix/Services/globals.dart';
import 'package:movix/Services/location.dart';
import 'package:movix/Services/login.dart';
import 'package:movix/Services/scanner.dart';
import 'package:movix/Services/settings.dart';
import 'package:movix/Services/sound.dart';
import 'package:movix/Services/update_service.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:movix/Pages/Others/UpdatePage.dart';
import 'package:package_info_plus/package_info_plus.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  String _loadingText = "Initialisation...";

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _checkAndShowUpdateDialog() async {
    if (!Platform.isAndroid) return;

    final currentVersion = await getAppVersion();
    final downloadableVersion = await getDownloadableVersion();

    if (downloadableVersion != null && downloadableVersion != currentVersion) {
      if (mounted) {
        await showDialog<void>(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            backgroundColor: Globals.COLOR_SURFACE,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Row(
              children: [
                Icon(Icons.system_update, color: Globals.COLOR_MOVIX, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    "Mise à jour disponible",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Globals.COLOR_TEXT_DARK,
                    ),
                  ),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Globals.COLOR_MOVIX.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            "Version actuelle : ",
                            style: TextStyle(
                              fontSize: 14,
                              color: Globals.COLOR_TEXT_DARK_SECONDARY,
                            ),
                          ),
                          Text(
                            currentVersion,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Globals.COLOR_TEXT_DARK,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            "Nouvelle version : ",
                            style: TextStyle(
                              fontSize: 14,
                              color: Globals.COLOR_TEXT_DARK_SECONDARY,
                            ),
                          ),
                          Text(
                            downloadableVersion,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Globals.COLOR_MOVIX_GREEN,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  "Une nouvelle version de l'application est disponible avec des améliorations et corrections de bugs.",
                  style: TextStyle(
                    fontSize: 14,
                    color: Globals.COLOR_TEXT_DARK,
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text(
                  "Plus tard",
                  style: TextStyle(
                    fontSize: 16,
                    color: Globals.COLOR_TEXT_DARK_SECONDARY,
                  ),
                ),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.push(
                    context,
                    MaterialPageRoute<void>(
                      builder: (context) => const UpdatePage(),
                    ),
                  );
                },
                icon: Icon(Icons.download, size: 18),
                label: const Text("Mettre à jour"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Globals.COLOR_MOVIX,
                  foregroundColor: Globals.COLOR_TEXT_LIGHT,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
        );
      }
    }
  }

  Future<void> _initializeApp() async {
    setState(() => _loadingText = "Chargement des variables d'environnement...");
    try {
      await dotenv.load(fileName: ".env");
    } catch (e) {
      print("Fichier .env non trouvé, utilisation des valeurs par défaut");
    }

    setState(() => _loadingText = "Configuration de la date...");
    await initializeDateFormatting('fr_FR', null);
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    setState(() => _loadingText = "Initialisation de la base de données...");
    await Hive.initFlutter();

    setState(() => _loadingText = "Configuration du spooler...");
    await SpoolerManager().initialize();
    
    setState(() => _loadingText = "Chargement des données...");
    final appDocDir = await getApplicationDocumentsDirectory();
    Hive.init(appDocDir.path);
    loadToursFromHive();
    Globals.SCAN_MODE = await getScanMode();
    Globals.SOUND_PACK = await getSoundPack();
    Globals.MAP_APP = await getMapApp();
    setupLocator();

    setState(() => _loadingText = "Configuration de la carte...");
    await FMTCObjectBoxBackend().initialise();
    await const FMTCStore('mapStore').manage.create();

    setState(() => _loadingText = "Vérification de la connexion...");
    var logged = await isLogged();
    if (logged) {
      setState(() => _loadingText = "Récupération du profil...");
      Globals.profil = await getProfil();
      Globals.profil = await me();
      if (Globals.profil == null) {
        Globals.showSnackbar("Impossible de récupérer le profil.",
            backgroundColor: Globals.COLOR_MOVIX_RED);
        logged = false;
      }
    }

    setState(() => _loadingText = "Vérification des mises à jour...");

    if (!mounted) return;

    if (logged) {
      await _checkAndShowUpdateDialog();
      if (mounted) context.go('/home');
    } else {
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Globals.COLOR_MOVIX,
      body: Center(
        child: ValueListenableBuilder<bool>(
          valueListenable: Globals.darkModeNotifier,
          builder: (context, isDarkMode, child) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 150,
                  child: Image(
                    image: AssetImage(
                      isDarkMode 
                        ? 'assets/images/logo_dark.png'
                        : 'assets/images/logo.png'
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  _loadingText,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
