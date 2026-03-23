import 'package:hive/hive.dart';

part 'race_result_model.g.dart';

@HiveType(typeId: 5)
class RaceResultModel {
  RaceResultModel({
    required this.position,
    required this.driverCode,
    required this.driverNumber,
    required this.givenName,
    required this.familyName,
    required this.constructorId,
    required this.constructorName,
    required this.points,
    required this.status,
    this.time,
    this.fastestLapTime,
    this.fastestLapRank,
  });

  @HiveField(0)
  final int position;

  @HiveField(1)
  final String driverCode;

  @HiveField(2)
  final String driverNumber;

  @HiveField(3)
  final String givenName;

  @HiveField(4)
  final String familyName;

  @HiveField(5)
  final String constructorId;

  @HiveField(6)
  final String constructorName;

  @HiveField(7)
  final double points;

  @HiveField(8)
  final String status;

  @HiveField(9)
  final String? time;

  @HiveField(10)
  final String? fastestLapTime;

  @HiveField(11)
  final int? fastestLapRank;

  String get fullName => '$givenName $familyName';

  bool get isFinished => status == 'Finished';

  bool get hasFastestLap => fastestLapRank == 1;

  factory RaceResultModel.fromJson(Map<String, dynamic> json) {
    final driver = json['Driver'] as Map<String, dynamic>;
    final constructor = json['Constructor'] as Map<String, dynamic>;
    final fastestLap = json['FastestLap'] as Map<String, dynamic>?;

    return RaceResultModel(
      position: int.parse(json['position'] as String),
      driverCode: (driver['code'] as String?) ?? '',
      driverNumber: (json['number'] as String?) ?? '',
      givenName: driver['givenName'] as String,
      familyName: driver['familyName'] as String,
      constructorId: constructor['constructorId'] as String,
      constructorName: constructor['name'] as String,
      points: double.parse(json['points'] as String),
      status: json['status'] as String,
      time: (json['Time'] as Map<String, dynamic>?)?['time'] as String?,
      fastestLapTime:
          (fastestLap?['Time'] as Map<String, dynamic>?)?['time'] as String?,
      fastestLapRank: fastestLap != null
          ? int.tryParse(fastestLap['rank'] as String? ?? '')
          : null,
    );
  }
}
