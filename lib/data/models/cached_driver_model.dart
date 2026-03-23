import 'package:hive/hive.dart';

part 'cached_driver_model.g.dart';

@HiveType(typeId: 5)
class CachedDriverModel extends HiveObject {
  @HiveField(0)
  final int driverNumber;

  @HiveField(1)
  final String broadcastName; // "M. VERSTAPPEN"

  @HiveField(2)
  final String fullName;

  @HiveField(3)
  final String nameAcronym; // VER

  @HiveField(4)
  final String teamName;

  @HiveField(5)
  final String teamColour; // hex string "3671C6"

  @HiveField(6)
  final String? headshotUrl;

  @HiveField(7)
  final String countryCode;

  @HiveField(8)
  final int sessionKey;

  CachedDriverModel({
    required this.driverNumber,
    required this.broadcastName,
    required this.fullName,
    required this.nameAcronym,
    required this.teamName,
    required this.teamColour,
    this.headshotUrl,
    required this.countryCode,
    required this.sessionKey,
  });

  factory CachedDriverModel.fromOpenF1Json(Map<String, dynamic> json) {
    return CachedDriverModel(
      driverNumber: (json['driver_number'] as num?)?.toInt() ?? 0,
      broadcastName: json['broadcast_name'] as String? ?? '',
      fullName: json['full_name'] as String? ?? '',
      nameAcronym: json['name_acronym'] as String? ?? '',
      teamName: json['team_name'] as String? ?? '',
      teamColour: json['team_colour'] as String? ?? 'FF553D',
      headshotUrl: json['headshot_url'] as String?,
      countryCode: json['country_code'] as String? ?? '',
      sessionKey: (json['session_key'] as num?)?.toInt() ?? 0,
    );
  }
}
