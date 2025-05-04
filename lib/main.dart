import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:movix/Router/app_router.dart';
import 'package:movix/Services/globals.dart';
import 'package:movix/Services/location.dart';
import 'package:flutter_map_tile_caching/flutter_map_tile_caching.dart';
import 'package:flutter/services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  setupLocator();
  await initializeDateFormatting('fr_FR', null);
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  await FMTCObjectBoxBackend().initialise();
  await const FMTCStore('mapStore').manage.create();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Movix',
      scaffoldMessengerKey: Globals.scaffoldMessengerKey,
      theme: ThemeData(
        colorSchemeSeed: Globals.COLOR_MOVIX,
      ),
      routerConfig: appRouter,
    );
  }
}