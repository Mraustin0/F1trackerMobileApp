import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/constructor_standing_model.dart';
import '../data/models/driver_standing_model.dart';
import '../data/repositories/standings_repository.dart';
import 'race_provider.dart';

final driverStandingsProvider =
    FutureProvider<List<DriverStandingModel>>((ref) async {
  final season = ref.watch(currentSeasonProvider);
  final repo = ref.watch(standingsRepositoryProvider);
  return repo.getDriverStandings(season);
});

final constructorStandingsProvider =
    FutureProvider<List<ConstructorStandingModel>>((ref) async {
  final season = ref.watch(currentSeasonProvider);
  final repo = ref.watch(standingsRepositoryProvider);
  return repo.getConstructorStandings(season);
});
