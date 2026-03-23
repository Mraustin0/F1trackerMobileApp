import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:timezone/data/latest.dart' as tz;

import 'core/constants/hive_constants.dart';
import 'data/models/race_model.dart';
import 'data/models/session_model.dart';
import 'data/models/driver_standing_model.dart';
import 'data/models/constructor_standing_model.dart';
import 'data/models/lap_record_model.dart';
import 'data/models/cached_driver_model.dart';
import 'app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock to portrait
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Transparent status bar
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));

  // Init timezone DB
  tz.initializeTimeZones();

  // Init Hive
  await Hive.initFlutter();
  Hive.registerAdapter(RaceModelAdapter());
  Hive.registerAdapter(SessionModelAdapter());
  Hive.registerAdapter(DriverStandingModelAdapter());
  Hive.registerAdapter(ConstructorStandingModelAdapter());
  Hive.registerAdapter(LapRecordModelAdapter());
  Hive.registerAdapter(CachedDriverModelAdapter());

  await Future.wait([
    Hive.openBox<RaceModel>(HiveConstants.raceBox),
    Hive.openBox<DriverStandingModel>(HiveConstants.driverStandingsBox),
    Hive.openBox<ConstructorStandingModel>(HiveConstants.constructorStandingsBox),
    Hive.openBox(HiveConstants.prefsBox),
  ]);

  runApp(const ProviderScope(child: F1TrackerApp()));
}
