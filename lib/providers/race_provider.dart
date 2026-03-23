import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/race_model.dart';
import '../data/repositories/race_repository.dart';

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
