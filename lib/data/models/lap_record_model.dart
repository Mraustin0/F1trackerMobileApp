import 'package:hive/hive.dart';

part 'lap_record_model.g.dart';

@HiveType(typeId: 4)
class LapRecordModel extends HiveObject {
  @HiveField(0)
  final String circuitId;

  @HiveField(1)
  final String driverCode;

  @HiveField(2)
  final String driverName;

  @HiveField(3)
  final String team;

  @HiveField(4)
  final String lapTime; // "1:30.983"

  @HiveField(5)
  final int year;

  LapRecordModel({
    required this.circuitId,
    required this.driverCode,
    required this.driverName,
    required this.team,
    required this.lapTime,
    required this.year,
  });
}

// Static lap record data (embedded, no API call needed)
final Map<String, LapRecordModel> kLapRecords = {
  'suzuka': LapRecordModel(
    circuitId: 'suzuka',
    driverCode: 'HAM',
    driverName: 'L. Hamilton',
    team: 'Mercedes-AMG (2019)',
    lapTime: '1:30.983',
    year: 2019,
  ),
  'marina_bay': LapRecordModel(
    circuitId: 'marina_bay',
    driverCode: 'SAI',
    driverName: 'C. Sainz',
    team: 'Ferrari (2023)',
    lapTime: '1:30.984',
    year: 2023,
  ),
  'monza': LapRecordModel(
    circuitId: 'monza',
    driverCode: 'RUB',
    driverName: 'R. Barrichello',
    team: 'Ferrari (2004)',
    lapTime: '1:21.046',
    year: 2004,
  ),
  'spa': LapRecordModel(
    circuitId: 'spa',
    driverCode: 'VET',
    driverName: 'S. Vettel',
    team: 'Red Bull (2009)',
    lapTime: '1:46.286',
    year: 2009,
  ),
  'silverstone': LapRecordModel(
    circuitId: 'silverstone',
    driverCode: 'HAM',
    driverName: 'L. Hamilton',
    team: 'Mercedes (2020)',
    lapTime: '1:24.303',
    year: 2020,
  ),
  'monaco': LapRecordModel(
    circuitId: 'monaco',
    driverCode: 'HAM',
    driverName: 'L. Hamilton',
    team: 'Mercedes (2021)',
    lapTime: '1:12.909',
    year: 2021,
  ),
  'bahrain': LapRecordModel(
    circuitId: 'bahrain',
    driverCode: 'PER',
    driverName: 'S. Perez',
    team: 'Red Bull (2023)',
    lapTime: '1:31.447',
    year: 2023,
  ),
  'albert_park': LapRecordModel(
    circuitId: 'albert_park',
    driverCode: 'BOT',
    driverName: 'V. Bottas',
    team: 'Mercedes (2019)',
    lapTime: '1:20.432',
    year: 2019,
  ),
  'americas': LapRecordModel(
    circuitId: 'americas',
    driverCode: 'VER',
    driverName: 'M. Verstappen',
    team: 'Red Bull (2023)',
    lapTime: '1:36.169',
    year: 2023,
  ),
};
