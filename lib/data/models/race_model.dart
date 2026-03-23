import 'package:hive/hive.dart';

part 'race_model.g.dart';

@HiveType(typeId: 0)
class RaceModel extends HiveObject {
  @HiveField(0)
  final int round;

  @HiveField(1)
  final String raceName;

  @HiveField(2)
  final String circuitId;

  @HiveField(3)
  final String circuitName;

  @HiveField(4)
  final String country;

  @HiveField(5)
  final String locality;

  @HiveField(6)
  final DateTime raceDate; // UTC

  @HiveField(7)
  final DateTime? qualifyingDate;

  @HiveField(8)
  final DateTime? practice1Date;

  @HiveField(9)
  final DateTime? practice2Date;

  @HiveField(10)
  final DateTime? practice3Date;

  @HiveField(11)
  final DateTime? sprintDate;

  @HiveField(12)
  final String season;

  @HiveField(13)
  final bool isCompleted;

  @HiveField(14)
  final bool isNextRace;

  RaceModel({
    required this.round,
    required this.raceName,
    required this.circuitId,
    required this.circuitName,
    required this.country,
    required this.locality,
    required this.raceDate,
    this.qualifyingDate,
    this.practice1Date,
    this.practice2Date,
    this.practice3Date,
    this.sprintDate,
    required this.season,
    required this.isCompleted,
    required this.isNextRace,
  });

  static DateTime? _parseDateTime(String? date, String? time) {
    if (date == null) return null;
    final t = time ?? '00:00:00Z';
    try {
      return DateTime.parse('${date}T$t').toUtc();
    } catch (_) {
      return null;
    }
  }

  static Map<String, dynamic>? _sub(Map<String, dynamic> json, String key) {
    final v = json[key];
    if (v is Map<String, dynamic>) return v;
    return null;
  }

  factory RaceModel.fromJolpicaJson(Map<String, dynamic> json, String season) {
    final circuit = json['Circuit'] as Map<String, dynamic>;
    final loc = circuit['Location'] as Map<String, dynamic>;
    final raceDate = _parseDateTime(
        json['date'] as String?, json['time'] as String?);
    final now = DateTime.now().toUtc();

    final qual = _sub(json, 'Qualifying');
    final fp1 = _sub(json, 'FirstPractice');
    final fp2 = _sub(json, 'SecondPractice');
    final fp3 = _sub(json, 'ThirdPractice');
    final sprint = _sub(json, 'Sprint');

    return RaceModel(
      round: int.tryParse(json['round']?.toString() ?? '0') ?? 0,
      raceName: json['raceName'] as String? ?? '',
      circuitId: circuit['circuitId'] as String? ?? '',
      circuitName: circuit['circuitName'] as String? ?? '',
      country: loc['country'] as String? ?? '',
      locality: loc['locality'] as String? ?? '',
      raceDate: raceDate ?? now,
      qualifyingDate:
          _parseDateTime(qual?['date'] as String?, qual?['time'] as String?),
      practice1Date:
          _parseDateTime(fp1?['date'] as String?, fp1?['time'] as String?),
      practice2Date:
          _parseDateTime(fp2?['date'] as String?, fp2?['time'] as String?),
      practice3Date:
          _parseDateTime(fp3?['date'] as String?, fp3?['time'] as String?),
      sprintDate:
          _parseDateTime(sprint?['date'] as String?, sprint?['time'] as String?),
      season: season,
      isCompleted: raceDate != null && raceDate.isBefore(now),
      isNextRace: false,
    );
  }

  RaceModel copyWith({bool? isNextRace, bool? isCompleted}) {
    return RaceModel(
      round: round,
      raceName: raceName,
      circuitId: circuitId,
      circuitName: circuitName,
      country: country,
      locality: locality,
      raceDate: raceDate,
      qualifyingDate: qualifyingDate,
      practice1Date: practice1Date,
      practice2Date: practice2Date,
      practice3Date: practice3Date,
      sprintDate: sprintDate,
      season: season,
      isCompleted: isCompleted ?? this.isCompleted,
      isNextRace: isNextRace ?? this.isNextRace,
    );
  }
}
