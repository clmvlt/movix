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
import 'package:path_provider/path_provider.dart';
import 'dart:async';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  String _loadingText = "Initialisation...";
  String? _errorMessage;
  bool _hasError = false;

  // Couleur Movix pour le texte et les éléments
  static const Color _movixColor = Color(0xff123456);

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
      Globals.SOUND_ENABLED = await getSoundEnabled();
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

          if (Globals.profil == null) {
            throw Exception("Profil null après récupération");
          }

          // Vérification auth/me avec timeout de 3 secondes - ignoré si trop lent
          me().timeout(
            const Duration(seconds: 3),
            onTimeout: () => null,
          ).then((profil) {
            if (profil != null) {
              Globals.profil = profil;
            }
          }).catchError((_) {});
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
      backgroundColor: Colors.white,
      body: Center(
        child: _hasError ? _buildErrorView() : _buildLoadingView(),
      ),
    );
  }

  Widget _buildLoadingView() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: 150,
          child: Image.asset('assets/images/logo.png'),
        ),
        const SizedBox(height: 30),
        Text(
          _loadingText,
          style: const TextStyle(
            color: _movixColor,
            fontSize: 14,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),
        const SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            color: _movixColor,
            strokeWidth: 2.5,
          ),
        ),
      ],
    );
  }

  Widget _buildErrorView() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            color: Colors.red,
            size: 64,
          ),
          const SizedBox(height: 24),
          const Text(
            "Erreur d'initialisation",
            style: TextStyle(
              color: _movixColor,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              _errorMessage ?? "Une erreur inconnue s'est produite",
              style: TextStyle(
                color: Colors.grey.shade700,
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
              backgroundColor: _movixColor,
              foregroundColor: Colors.white,
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
}
