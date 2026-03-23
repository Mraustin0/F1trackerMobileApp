import 'package:hive/hive.dart';

part 'driver_standing_model.g.dart';

@HiveType(typeId: 2)
class DriverStandingModel extends HiveObject {
  @HiveField(0)
  final int position;

  @HiveField(1)
  final String driverId;

  @HiveField(2)
  final String givenName;

  @HiveField(3)
  final String familyName;

  @HiveField(4)
  final String code; // VER, HAM, etc.

  @HiveField(5)
  final int permanentNumber;

  @HiveField(6)
  final String nationality;

  @HiveField(7)
  final double points;

  @HiveField(8)
  final int wins;

  @HiveField(9)
  final String constructorId;

  @HiveField(10)
  final String constructorName;

  DriverStandingModel({
    required this.position,
    required this.driverId,
    required this.givenName,
    required this.familyName,
    required this.code,
    required this.permanentNumber,
    required this.nationality,
    required this.points,
    required this.wins,
    required this.constructorId,
    required this.constructorName,
  });

  String get fullName => '$givenName $familyName';
  String get displayNumber => permanentNumber > 0 ? '$permanentNumber' : '';

  factory DriverStandingModel.fromJson(Map<String, dynamic> json, int pos) {
    final driver = json['Driver'] as Map<String, dynamic>;
    final constructors = (json['Constructors'] as List);
    final constructor = constructors.isNotEmpty
        ? constructors.first as Map<String, dynamic>
        : <String, dynamic>{};

    return DriverStandingModel(
      position: pos,
      driverId: driver['driverId'] as String? ?? '',
      givenName: driver['givenName'] as String? ?? '',
      familyName: driver['familyName'] as String? ?? '',
      code: driver['code'] as String? ?? '',
      permanentNumber:
          int.tryParse(driver['permanentNumber']?.toString() ?? '0') ?? 0,
      nationality: driver['nationality'] as String? ?? '',
      points: double.tryParse(json['points']?.toString() ?? '0') ?? 0,
      wins: int.tryParse(json['wins']?.toString() ?? '0') ?? 0,
      constructorId: constructor['constructorId'] as String? ?? '',
      constructorName: constructor['name'] as String? ?? '',
    );
  }
}
