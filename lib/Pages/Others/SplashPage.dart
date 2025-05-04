import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:movix/Managers/SpoolerManager.dart';
import 'package:movix/Managers/TourManager.dart';
import 'package:movix/Services/globals.dart';
import 'package:movix/Services/login.dart';
import 'package:movix/Services/scanner.dart';
import 'package:movix/Services/settings.dart';
import 'package:movix/Services/update_service.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    SpoolerManager().initialize();
    loadToursFromPreferences();
    Globals.isScannerMode = await isScannerMode();
    Globals.SOUND_PATH = await getSoundPATH();
    Globals.MAP_APP = await getMapApp();

    var logged = await isLogged();
    if (logged) {
      Globals.profil = await getProfil();
      Globals.profil = await me(Globals.profil?.token ?? "");
      if (Globals.profil == null) {
        Globals.showSnackbar("Impossible de récupérer le profil.", backgroundColor: Globals.COLOR_MOVIX_RED);
        logged = false;
      }
    }

    if (!mounted) return;

    if (logged) {
      showUpdateDialog(context);
      context.go('/home');
    } else {
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Globals.COLOR_MOVIX,
      body: Center(
        child: SizedBox(
          width: 150,
          child: Image(
            image: AssetImage('assets/images/logo.png'),
          ),
        ),
      ),
    );
  }
}