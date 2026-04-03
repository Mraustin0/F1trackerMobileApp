class DriverDetailModel {
  final String driverId;
  final String givenName;
  final String familyName;
  final String code;
  final int permanentNumber;
  final String nationality;
  final DateTime? dateOfBirth;
  final List<SeasonStanding> seasonStandings;
  final String? headshotUrl;

  DriverDetailModel({
    required this.driverId,
    required this.givenName,
    required this.familyName,
    required this.code,
    required this.permanentNumber,
    required this.nationality,
    this.dateOfBirth,
    required this.seasonStandings,
    this.headshotUrl,
  });

  String get fullName => '$givenName $familyName';

  int? get age {
    if (dateOfBirth == null) return null;
    final now = DateTime.now();
    int years = now.year - dateOfBirth!.year;
    if (now.month < dateOfBirth!.month ||
        (now.month == dateOfBirth!.month && now.day < dateOfBirth!.day)) {
      years--;
    }
    return years;
  }

  int get championships =>
      seasonStandings.where((s) => s.position == 1).length;

  int get careerWins =>
      seasonStandings.fold(0, (sum, s) => sum + s.wins);

  double get careerPoints =>
      seasonStandings.fold(0.0, (sum, s) => sum + s.points);

  int get totalSeasons => seasonStandings.length;

  String? get debutYear =>
      seasonStandings.isNotEmpty ? seasonStandings.last.season : null;

  String? get debutTeam =>
      seasonStandings.isNotEmpty ? seasonStandings.last.constructorName : null;

  /// Build from per-season standings + driver info
  factory DriverDetailModel.fromSeasonStandings({
    required Map<String, dynamic> driverInfo,
    required List<Map<String, dynamic>> seasonStandings,
    String? headshotUrl,
  }) {
    final driverId = driverInfo['driverId'] as String? ?? '';
    final givenName = driverInfo['givenName'] as String? ?? '';
    final familyName = driverInfo['familyName'] as String? ?? '';
    final code = driverInfo['code'] as String? ?? '';
    final permanentNumber =
        int.tryParse(driverInfo['permanentNumber']?.toString() ?? '0') ?? 0;
    final nationality = driverInfo['nationality'] as String? ?? '';
    final dobStr = driverInfo['dateOfBirth'] as String?;
    final dob = dobStr != null ? DateTime.tryParse(dobStr) : null;

    final seasons = <SeasonStanding>[];
    final currentYear = DateTime.now().year.toString();

    for (final ds in seasonStandings) {
      final season = ds['season']?.toString() ?? '';
      final constructors = ds['Constructors'] as List? ?? [];
      final constructor = constructors.isNotEmpty
          ? constructors.first as Map<String, dynamic>
          : <String, dynamic>{};

      seasons.add(SeasonStanding(
        season: season,
        position: int.tryParse(ds['position']?.toString() ?? '0') ?? 0,
        points: double.tryParse(ds['points']?.toString() ?? '0') ?? 0,
        wins: int.tryParse(ds['wins']?.toString() ?? '0') ?? 0,
        constructorId: constructor['constructorId'] as String? ?? '',
        constructorName: constructor['name'] as String? ?? '',
        isOngoing: season == currentYear,
      ));
    }

    // Sort seasons descending (newest first)
    seasons.sort((a, b) => b.season.compareTo(a.season));

    return DriverDetailModel(
      driverId: driverId,
      givenName: givenName,
      familyName: familyName,
      code: code,
      permanentNumber: permanentNumber,
      nationality: nationality,
      dateOfBirth: dob,
      seasonStandings: seasons,
      headshotUrl: headshotUrl,
    );
  }
}

class SeasonStanding {
  final String season;
  final int position;
  final double points;
  final int wins;
  final String constructorId;
  final String constructorName;
  final bool isOngoing;

  const SeasonStanding({
    required this.season,
    required this.position,
    required this.points,
    required this.wins,
    required this.constructorId,
    required this.constructorName,
    this.isOngoing = false,
  });
}
