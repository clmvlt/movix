import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:movix/Router/app_router.dart';
import 'package:movix/Services/globals.dart';
import 'package:movix/Services/login.dart';
import 'package:movix/Services/settings.dart';
import 'package:movix/Services/update_check_cache.dart';
import 'package:movix/Services/update_service.dart';
import 'package:path_provider/path_provider.dart';

class RestartWidget extends StatefulWidget {
  const RestartWidget({super.key, required this.child});

  final Widget child;

  static void restartApp(BuildContext context) {
    context.findAncestorStateOfType<_RestartWidgetState>()?.restartApp();
  }

  @override
  State<RestartWidget> createState() => _RestartWidgetState();
}

class _RestartWidgetState extends State<RestartWidget> {
  Key key = UniqueKey();

  void restartApp() {
    setState(() {
      key = UniqueKey();
    });
  }

  @override
  Widget build(BuildContext context) {
    return KeyedSubtree(
      key: key,
      child: widget.child,
    );
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialisation de Hive
  final appDocumentDir = await getApplicationDocumentsDirectory();
  await Hive.initFlutter(appDocumentDir.path);

  // Initialisation du cache de vérification des mises à jour
  await UpdateCheckCache.init();

  Globals.DARK_MODE = await getDarkMode();
  Globals.darkModeNotifier.value = Globals.DARK_MODE;
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    // Enregistre l'observer pour détecter les changements d'état de l'app globalement
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    // Retire l'observer quand l'app est détruite
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    // Quand l'app revient au premier plan (sortie de veille/arrière-plan)
    if (state == AppLifecycleState.resumed) {
      // Vérifie /auth/me uniquement si 12h se sont écoulées
      // Timeout de 3s : si le réseau est lent, la vérification est ignorée
      _checkAuthMe();

      // Vérifie les mises à jour uniquement si 12h se sont écoulées
      _checkForUpdates();
    }
  }

  void _checkAuthMe() {
    // Vérifie /auth/me avec cache et timeout
    checkAuthMeWithCache();
  }

  void _checkForUpdates() {
    // Récupère le contexte de navigation pour afficher le dialogue
    final context = appRouter.routerDelegate.navigatorKey.currentContext;
    if (context != null && context.mounted) {
      checkAndShowUpdateDialog(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return RestartWidget(
      child: ValueListenableBuilder<bool>(
        valueListenable: Globals.darkModeNotifier,
        builder: (context, isDarkMode, child) {
          return ProviderScope(
            child: MaterialApp.router(
              title: 'Movix',
              scaffoldMessengerKey: Globals.scaffoldMessengerKey,
              theme: ThemeData(
                colorSchemeSeed: Globals.COLOR_MOVIX,
                brightness: isDarkMode ? Brightness.dark : Brightness.light,
              ),
              darkTheme: ThemeData(
                colorSchemeSeed: Globals.COLOR_MOVIX,
                brightness: Brightness.dark,
              ),
              themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
              routerConfig: appRouter,
            ),
          );
        },
      ),
    );
  }
}
