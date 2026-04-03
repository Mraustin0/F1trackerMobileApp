import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

import '../../core/constants/hive_constants.dart';
import '../../providers/core_providers.dart';
import '../datasources/jolpica_datasource.dart';
import '../models/constructor_standing_model.dart';
import '../models/driver_standing_model.dart';

class StandingsRepository {
  const StandingsRepository(
      this._remote, this._driverBox, this._ctorBox, this._prefsBox);
  final JolpicaDatasource _remote;
  final Box<DriverStandingModel> _driverBox;
  final Box<ConstructorStandingModel> _ctorBox;
  final Box<dynamic> _prefsBox;

  static const _cacheDuration = Duration(hours: 6);

  bool _isCacheStale(String key) {
    final stored = _prefsBox.get(key) as String?;
    if (stored == null) return true;
    final lastFetch = DateTime.tryParse(stored);
    if (lastFetch == null) return true;
    return DateTime.now().difference(lastFetch) > _cacheDuration;
  }

  Future<List<DriverStandingModel>> getDriverStandings(String season,
      {bool forceRefresh = false}) async {
    final stale = _isCacheStale(HiveConstants.driverStandingsCacheTimeKey);
    if (!forceRefresh && _driverBox.isNotEmpty && !stale) {
      return _driverBox.values.toList()
        ..sort((a, b) => a.position.compareTo(b.position));
    }
    final list = await _remote.fetchDriverStandings(season);
    await _driverBox.clear();
    for (final d in list) {
      await _driverBox.put(d.driverId, d);
    }
    await _prefsBox.put(HiveConstants.driverStandingsCacheTimeKey,
        DateTime.now().toIso8601String());
    return list;
  }

  Future<List<ConstructorStandingModel>> getConstructorStandings(String season,
      {bool forceRefresh = false}) async {
    final stale =
        _isCacheStale(HiveConstants.constructorStandingsCacheTimeKey);
    if (!forceRefresh && _ctorBox.isNotEmpty && !stale) {
      return _ctorBox.values.toList()
        ..sort((a, b) => a.position.compareTo(b.position));
    }
    final list = await _remote.fetchConstructorStandings(season);
    await _ctorBox.clear();
    for (final c in list) {
      await _ctorBox.put(c.constructorId, c);
    }
    await _prefsBox.put(HiveConstants.constructorStandingsCacheTimeKey,
        DateTime.now().toIso8601String());
    return list;
  }

  List<DriverStandingModel> getCachedDrivers() {
    return _driverBox.values.toList()
      ..sort((a, b) => a.position.compareTo(b.position));
  }

  List<ConstructorStandingModel> getCachedConstructors() {
    return _ctorBox.values.toList()
      ..sort((a, b) => a.position.compareTo(b.position));
  }
}

final standingsRepositoryProvider = Provider<StandingsRepository>((ref) {
  final dio = ref.watch(jolpicaDioProvider);
  final driverBox =
      Hive.box<DriverStandingModel>(HiveConstants.driverStandingsBox);
  final ctorBox =
      Hive.box<ConstructorStandingModel>(HiveConstants.constructorStandingsBox);
  final prefsBox = Hive.box(HiveConstants.prefsBox);
  return StandingsRepository(
      JolpicaDatasource(dio), driverBox, ctorBox, prefsBox);
});
