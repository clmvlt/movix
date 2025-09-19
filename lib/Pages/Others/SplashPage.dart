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
import 'dart:async';
import 'package:movix/Pages/Others/UpdatePage.dart';
import 'package:package_info_plus/package_info_plus.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  String _loadingText = "Initialisation...";
  String? _errorMessage;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }


  void _showError(String message) {
    setState(() {
      _hasError = true;
      _errorMessage = message;
    });
  }

  void _retryInitialization() {
    setState(() {
      _hasError = false;
      _errorMessage = null;
      _loadingText = "Initialisation...";
    });
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
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
        try {
          Globals.profil = await getProfil().timeout(
            const Duration(seconds: 10),
            onTimeout: () => throw TimeoutException("Timeout lors de la récupération du profil local", const Duration(seconds: 10)),
          );
          
          Globals.profil = await me().timeout(
            const Duration(seconds: 15),
            onTimeout: () => throw TimeoutException("Timeout lors de la récupération du profil serveur", const Duration(seconds: 15)),
          );
          
          if (Globals.profil == null) {
            throw Exception("Profil null après récupération");
          }
        } catch (e) {
          Globals.showSnackbar("Impossible de récupérer le profil: ${e.toString()}",
              backgroundColor: Globals.COLOR_MOVIX_RED);
          logged = false;
        }
      }

      if (!mounted) return;

      if (logged) {
        context.go('/home');
      } else {
        context.go('/login');
      }
    } catch (e) {
      _showError("Erreur d'initialisation : ${e.toString()}");
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
            if (_hasError) {
              return Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      color: Colors.white,
                      size: 64,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      "Erreur d'initialisation",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _errorMessage ?? "Une erreur inconnue s'est produite",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: _retryInitialization,
                      icon: const Icon(Icons.refresh),
                      label: const Text("Réessayer"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Globals.COLOR_MOVIX,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }
            
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
                const SizedBox(height: 20),
                const CircularProgressIndicator(
                  color: Colors.white,
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
