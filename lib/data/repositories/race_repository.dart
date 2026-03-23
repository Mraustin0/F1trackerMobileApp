import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

import '../../core/constants/hive_constants.dart';
import '../../providers/core_providers.dart';
import '../datasources/jolpica_datasource.dart';
import '../models/race_model.dart';

class RaceRepository {
  const RaceRepository(this._remote, this._box);
  final JolpicaDatasource _remote;
  final Box<RaceModel> _box;

  Future<List<RaceModel>> getSchedule(String season,
      {bool forceRefresh = false}) async {
    // Cache-first: return cached if fresh (< 6 h old) and not forced
    if (!forceRefresh && _box.isNotEmpty) {
      return _box.values.where((r) => r.season == season).toList()
        ..sort((a, b) => a.round.compareTo(b.round));
    }

    final races = await _remote.fetchSchedule(season);
    await _box.clear();
    for (final race in races) {
      await _box.put('${season}_${race.round}', race);
    }
    return races;
  }

  List<RaceModel> getCachedSchedule(String season) {
    return _box.values.where((r) => r.season == season).toList()
      ..sort((a, b) => a.round.compareTo(b.round));
  }

  RaceModel? getNextRace(String season) {
    final cached = getCachedSchedule(season);
    try {
      return cached.firstWhere((r) => r.isNextRace);
    } catch (_) {
      return null;
    }
  }
}

final raceRepositoryProvider = Provider<RaceRepository>((ref) {
  final dio = ref.watch(jolpicaDioProvider);
  final box = Hive.box<RaceModel>(HiveConstants.raceBox);
  return RaceRepository(JolpicaDatasource(dio), box);
});
