import 'package:dio/dio.dart';

import '../../core/constants/api_constants.dart';
import '../models/constructor_standing_model.dart';
import '../models/driver_standing_model.dart';
import '../models/race_model.dart';
import '../models/race_result_model.dart';

class JolpicaDatasource {
  const JolpicaDatasource(this._dio);
  final Dio _dio;

  Future<List<RaceModel>> fetchSchedule(String season) async {
    final resp = await _dio.get('/$season.json');
    final table = resp.data['MRData']['RaceTable'] as Map<String, dynamic>;
    final races = table['Races'] as List;
    final list = races
        .map((e) => RaceModel.fromJolpicaJson(
            e as Map<String, dynamic>, season))
        .toList();

    // Mark next race
    final now = DateTime.now().toUtc();
    int nextIdx = -1;
    for (int i = 0; i < list.length; i++) {
      if (list[i].raceDate.isAfter(now)) {
        nextIdx = i;
        break;
      }
    }
    return list.asMap().entries.map((e) {
      return e.value.copyWith(isNextRace: e.key == nextIdx);
    }).toList();
  }

  Future<List<DriverStandingModel>> fetchDriverStandings(
      String season) async {
    final resp = await _dio.get(
        ApiConstants.jolpicaCurrentDriverStandings.replaceFirst(
            'current', season));
    final table = resp.data['MRData']['StandingsTable'] as Map<String, dynamic>;
    final lists = table['StandingsLists'] as List;
    if (lists.isEmpty) return [];
    final standings = lists.first['DriverStandings'] as List;
    return standings
        .asMap()
        .entries
        .map((e) => DriverStandingModel.fromJson(
            e.value as Map<String, dynamic>, e.key + 1))
        .toList();
  }

  Future<List<RaceResultModel>> fetchRaceResults(
      String season, int round) async {
    final resp =
        await _dio.get(ApiConstants.jolpicaRaceResults(season, round));
    final table =
        resp.data['MRData']['RaceTable'] as Map<String, dynamic>;
    final races = table['Races'] as List;
    if (races.isEmpty) return [];
    final results = races.first['Results'] as List;
    return results
        .map((e) => RaceResultModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Fetches driver info (dob, nationality, etc.) from a specific season.
  Future<Map<String, dynamic>> fetchDriverInfo(
      String season, String driverId) async {
    final resp =
        await _dio.get(ApiConstants.jolpicaDriverInfo(season, driverId));
    final table =
        resp.data['MRData']['DriverTable'] as Map<String, dynamic>;
    final drivers = table['Drivers'] as List;
    return drivers.isNotEmpty
        ? drivers.first as Map<String, dynamic>
        : <String, dynamic>{};
  }

  /// Fetches a driver's standing for a specific season.
  /// Returns null if the driver didn't compete that season.
  Future<Map<String, dynamic>?> fetchDriverSeasonStanding(
      String season, String driverId) async {
    try {
      final resp = await _dio
          .get(ApiConstants.jolpicaDriverSeasonStanding(season, driverId));
      final table =
          resp.data['MRData']['StandingsTable'] as Map<String, dynamic>;
      final lists = table['StandingsLists'] as List;
      if (lists.isEmpty) return null;
      final standings =
          (lists.first as Map<String, dynamic>)['DriverStandings'] as List;
      if (standings.isEmpty) return null;
      final standing = standings.first as Map<String, dynamic>;
      standing['season'] = table['season'] ?? season;
      return standing;
    } catch (_) {
      return null;
    }
  }

  Future<List<ConstructorStandingModel>> fetchConstructorStandings(
      String season) async {
    final resp = await _dio.get(
        ApiConstants.jolpicaCurrentConstructorStandings.replaceFirst(
            'current', season));
    final table = resp.data['MRData']['StandingsTable'] as Map<String, dynamic>;
    final lists = table['StandingsLists'] as List;
    if (lists.isEmpty) return [];
    final standings = lists.first['ConstructorStandings'] as List;
    return standings
        .asMap()
        .entries
        .map((e) => ConstructorStandingModel.fromJson(
            e.value as Map<String, dynamic>, e.key + 1))
        .toList();
  }
}
