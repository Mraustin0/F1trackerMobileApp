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
