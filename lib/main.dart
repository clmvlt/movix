import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:movix/Managers/SpoolerManager.dart';
import 'package:movix/Models/MapAdapter.dart';
import 'package:movix/Models/Spooler.dart';
import 'package:movix/Router/app_router.dart';
import 'package:movix/Services/globals.dart';
import 'package:movix/Services/location.dart';
import 'package:flutter_map_tile_caching/flutter_map_tile_caching.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

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

  await Hive.initFlutter();
  //await Hive.deleteBoxFromDisk('spoolerBox');

  Hive.registerAdapter(SpoolerAdapter());
  Hive.registerAdapter(MapAdapter());
  await SpoolerManager().initialize();

  final appDocDir = await getApplicationDocumentsDirectory();
  Hive.init(appDocDir.path);

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
