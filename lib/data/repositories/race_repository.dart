import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

import '../../core/constants/hive_constants.dart';
import '../../providers/core_providers.dart';
import '../datasources/jolpica_datasource.dart';
import '../models/race_model.dart';

class RaceRepository {
  const RaceRepository(this._remote, this._box, this._prefsBox);
  final JolpicaDatasource _remote;
  final Box<RaceModel> _box;
  final Box<dynamic> _prefsBox;

  static const _cacheDuration = Duration(hours: 6);

  bool _isCacheStale(String season) {
    final key = '${HiveConstants.raceCacheTimePrefix}$season';
    final stored = _prefsBox.get(key) as String?;
    if (stored == null) return true;
    final lastFetch = DateTime.tryParse(stored);
    if (lastFetch == null) return true;
    return DateTime.now().difference(lastFetch) > _cacheDuration;
  }

  Future<List<RaceModel>> getSchedule(String season,
      {bool forceRefresh = false}) async {
    final stale = _isCacheStale(season);
    final hasCached =
        _box.values.any((r) => r.season == season);
    if (!forceRefresh && hasCached && !stale) {
      return _box.values.where((r) => r.season == season).toList()
        ..sort((a, b) => a.round.compareTo(b.round));
    }

    final races = await _remote.fetchSchedule(season);
    await _box.clear();
    for (final race in races) {
      await _box.put('${season}_${race.round}', race);
    }
    await _prefsBox.put(
        '${HiveConstants.raceCacheTimePrefix}$season',
        DateTime.now().toIso8601String());
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
  final prefsBox = Hive.box(HiveConstants.prefsBox);
  return RaceRepository(JolpicaDatasource(dio), box, prefsBox);
});
