import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/race_model.dart';
import '../data/models/race_result_model.dart';
import '../data/repositories/race_repository.dart';
import '../providers/core_providers.dart';

final currentSeasonProvider = Provider<String>((ref) {
  return DateTime.now().year.toString();
});

final scheduleProvider =
    FutureProvider.family<List<RaceModel>, String>((ref, season) async {
  final repo = ref.watch(raceRepositoryProvider);
  return repo.getSchedule(season);
});

final nextRaceProvider = Provider<RaceModel?>((ref) {
  final season = ref.watch(currentSeasonProvider);
  final repo = ref.watch(raceRepositoryProvider);
  final cached = repo.getCachedSchedule(season);
  if (cached.isEmpty) return null;
  try {
    return cached.firstWhere((r) => r.isNextRace);
  } catch (_) {
    // If no next race, pick first upcoming by date
    final now = DateTime.now().toUtc();
    try {
      return cached.firstWhere((r) => r.raceDate.isAfter(now));
    } catch (_) {
      return null;
    }
  }
});

/// Fetch race results for a specific season + round.
/// Key format: "season:round" e.g. "2025:1"
final raceResultsProvider = FutureProvider.family<List<RaceResultModel>, String>(
    (ref, key) async {
  final parts = key.split(':');
  final season = parts[0];
  final round = int.parse(parts[1]);
  final jolpica = ref.watch(jolpicaDatasourceProvider);
  return jolpica.fetchRaceResults(season, round);
});
