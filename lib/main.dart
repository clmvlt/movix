import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:movix/Router/app_router.dart';
import 'package:movix/Services/globals.dart';
import 'package:movix/Services/settings.dart';
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
  
  Globals.DARK_MODE = await getDarkMode();
  Globals.darkModeNotifier.value = Globals.DARK_MODE;
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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
