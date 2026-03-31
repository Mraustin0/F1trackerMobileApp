class HiveConstants {
  HiveConstants._();

  static const raceBox = 'races_box';
  static const driverStandingsBox = 'driver_standings_box';
  static const constructorStandingsBox = 'constructor_standings_box';
  static const prefsBox = 'prefs_box';

  // Type IDs for Hive adapters
  static const raceTypeId = 0;
  static const sessionTypeId = 1;
  static const driverStandingTypeId = 2;
  static const constructorStandingTypeId = 3;
  static const lapRecordTypeId = 4;
  static const cachedDriverTypeId = 5;

  // Prefs keys
  static const teamKey = 'selected_team';
  static const notifEnabledKey = 'notif_enabled';
  static const notifMinutesKey = 'notif_minutes_before';
  static const favoriteDriversKey = 'favorite_drivers';
}
