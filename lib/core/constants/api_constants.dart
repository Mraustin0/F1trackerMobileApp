class ApiConstants {
  ApiConstants._();

  // OpenF1 API — live telemetry, sessions, meetings, drivers
  static const openf1BaseUrl = 'https://api.openf1.org/v1';
  static const openf1Meetings = '/meetings';
  static const openf1Sessions = '/sessions';
  static const openf1Drivers = '/drivers';
  static const openf1Position = '/position';
  static const openf1Laps = '/laps';
  static const openf1Pit = '/pit';
  static const openf1Stints = '/stints';
  static const openf1Intervals = '/intervals';

  // Jolpica-F1 API (Ergast successor) — standings, schedule, results
  static const jolpicaBaseUrl = 'https://api.jolpi.ca/ergast/f1';
  static const jolpicaCurrentDriverStandings = '/current/driverStandings.json';
  static const jolpicaCurrentConstructorStandings = '/current/constructorStandings.json';
  // /{season}/{round}/results.json
  static String jolpicaRaceResults(String season, int round) =>
      '/$season/$round/results.json';
  // /{season}/drivers/{driverId}/driverStandings.json
  static String jolpicaDriverSeasonStanding(String season, String driverId) =>
      '/$season/drivers/$driverId/driverStandings.json';

  // /{season}/drivers/{driverId}.json — driver info (dob, nationality)
  static String jolpicaDriverInfo(String season, String driverId) =>
      '/$season/drivers/$driverId.json';

  // HTTP settings
  static const connectTimeout = Duration(seconds: 15);
  static const receiveTimeout = Duration(seconds: 30);
  static const sendTimeout = Duration(seconds: 15);
}
