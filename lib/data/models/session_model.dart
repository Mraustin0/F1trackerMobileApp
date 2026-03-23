import 'package:hive/hive.dart';

part 'session_model.g.dart';

@HiveType(typeId: 1)
class SessionModel extends HiveObject {
  @HiveField(0)
  final int sessionKey;

  @HiveField(1)
  final String sessionName; // Practice 1, Qualifying, Race…

  @HiveField(2)
  final String sessionType;

  @HiveField(3)
  final DateTime dateStart;

  @HiveField(4)
  final DateTime dateEnd;

  @HiveField(5)
  final String circuitShortName;

  @HiveField(6)
  final String countryName;

  @HiveField(7)
  final String location;

  @HiveField(8)
  final int year;

  @HiveField(9)
  final int meetingKey;

  @HiveField(10)
  final bool gmtOffset; // stored as bool placeholder — use dateStart UTC

  SessionModel({
    required this.sessionKey,
    required this.sessionName,
    required this.sessionType,
    required this.dateStart,
    required this.dateEnd,
    required this.circuitShortName,
    required this.countryName,
    required this.location,
    required this.year,
    required this.meetingKey,
    this.gmtOffset = false,
  });

  bool get isLive {
    final now = DateTime.now().toUtc();
    return now.isAfter(dateStart) && now.isBefore(dateEnd);
  }

  bool get isPast => DateTime.now().toUtc().isAfter(dateEnd);
  bool get isFuture => DateTime.now().toUtc().isBefore(dateStart);

  factory SessionModel.fromOpenF1Json(Map<String, dynamic> json) {
    DateTime parseOrNow(dynamic v) {
      if (v == null) return DateTime.now().toUtc();
      try {
        return DateTime.parse(v.toString()).toUtc();
      } catch (_) {
        return DateTime.now().toUtc();
      }
    }

    return SessionModel(
      sessionKey: (json['session_key'] as num?)?.toInt() ?? 0,
      sessionName: json['session_name'] as String? ?? '',
      sessionType: json['session_type'] as String? ?? '',
      dateStart: parseOrNow(json['date_start']),
      dateEnd: parseOrNow(json['date_end']),
      circuitShortName: json['circuit_short_name'] as String? ?? '',
      countryName: json['country_name'] as String? ?? '',
      location: json['location'] as String? ?? '',
      year: (json['year'] as num?)?.toInt() ?? DateTime.now().year,
      meetingKey: (json['meeting_key'] as num?)?.toInt() ?? 0,
    );
  }
}
