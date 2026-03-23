import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

import '../../core/constants/hive_constants.dart';
import '../../providers/core_providers.dart';
import '../datasources/jolpica_datasource.dart';
import '../models/constructor_standing_model.dart';
import '../models/driver_standing_model.dart';

class StandingsRepository {
  const StandingsRepository(this._remote, this._driverBox, this._ctorBox);
  final JolpicaDatasource _remote;
  final Box<DriverStandingModel> _driverBox;
  final Box<ConstructorStandingModel> _ctorBox;

  Future<List<DriverStandingModel>> getDriverStandings(String season,
      {bool forceRefresh = false}) async {
    if (!forceRefresh && _driverBox.isNotEmpty) {
      return _driverBox.values.toList()
        ..sort((a, b) => a.position.compareTo(b.position));
    }
    final list = await _remote.fetchDriverStandings(season);
    await _driverBox.clear();
    for (final d in list) {
      await _driverBox.put(d.driverId, d);
    }
    return list;
  }

  Future<List<ConstructorStandingModel>> getConstructorStandings(String season,
      {bool forceRefresh = false}) async {
    if (!forceRefresh && _ctorBox.isNotEmpty) {
      return _ctorBox.values.toList()
        ..sort((a, b) => a.position.compareTo(b.position));
    }
    final list = await _remote.fetchConstructorStandings(season);
    await _ctorBox.clear();
    for (final c in list) {
      await _ctorBox.put(c.constructorId, c);
    }
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
  return StandingsRepository(JolpicaDatasource(dio), driverBox, ctorBox);
});
