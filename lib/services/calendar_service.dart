import 'package:device_calendar/device_calendar.dart';
import 'package:timezone/timezone.dart' as tz;

import '../data/models/race_model.dart';

class CalendarService {
  CalendarService._();
  static final CalendarService instance = CalendarService._();

  final DeviceCalendarPlugin _plugin = DeviceCalendarPlugin();

  // ── Permission ─────────────────────────────────────────────────────────────

  Future<bool> requestPermission() async {
    var result = await _plugin.requestPermissions();
    return result.isSuccess && (result.data ?? false);
  }

  Future<bool> hasPermission() async {
    var result = await _plugin.hasPermissions();
    return result.isSuccess && (result.data ?? false);
  }

  // ── Calendar selection ─────────────────────────────────────────────────────

  Future<String?> _getWritableCalendarId() async {
    final result = await _plugin.retrieveCalendars();
    if (!result.isSuccess || result.data == null) return null;
    final writable = result.data!.where((c) => !(c.isReadOnly ?? true)).toList();
    if (writable.isEmpty) return null;
    // Prefer the device default calendar (usually first)
    return writable.first.id;
  }

  // ── Add race weekend ───────────────────────────────────────────────────────

  /// Adds all sessions of [race] to the native calendar.
  /// Returns the number of events successfully added, or -1 if permission denied.
  Future<int> addRaceWeekend(RaceModel race) async {
    final permitted = await hasPermission() || await requestPermission();
    if (!permitted) return -1;

    final calId = await _getWritableCalendarId();
    if (calId == null) return -1;

    final sessions = _buildSessions(race);
    int added = 0;
    for (final s in sessions) {
      final ok = await _addEvent(calId, s);
      if (ok) added++;
    }
    return added;
  }

  /// Adds a single session of [race] identified by [sessionKey].
  /// Returns true on success.
  Future<bool> addSession(RaceModel race, SessionType type) async {
    final permitted = await hasPermission() || await requestPermission();
    if (!permitted) return false;

    final calId = await _getWritableCalendarId();
    if (calId == null) return false;

    final sessions = _buildSessions(race);
    final target = sessions.where((s) => s.type == type).firstOrNull;
    if (target == null) return false;
    return _addEvent(calId, target);
  }

  // ── Internals ──────────────────────────────────────────────────────────────

  Future<bool> _addEvent(String calId, _SessionInfo s) async {
    final local = tz.TZDateTime.from(s.start, tz.local);
    final end = local.add(s.duration);
    final event = Event(
      calId,
      title: s.title,
      start: local,
      end: end,
      description: 'Formula 1 ${s.season} — Round ${s.round}\n${s.circuitName}',
      location: '${s.locality}, ${s.country}',
    );
    final result = await _plugin.createOrUpdateEvent(event);
    return result?.isSuccess == true;
  }

  List<_SessionInfo> _buildSessions(RaceModel race) {
    final sessions = <_SessionInfo>[];

    void add(SessionType type, String label, DateTime? dt, Duration dur) {
      if (dt == null) return;
      sessions.add(_SessionInfo(
        type: type,
        title: '$label — ${race.raceName}',
        start: dt,
        duration: dur,
        season: race.season,
        round: race.round,
        circuitName: race.circuitName,
        locality: race.locality,
        country: race.country,
      ));
    }

    add(SessionType.fp1, 'Practice 1', race.practice1Date,
        const Duration(hours: 1, minutes: 30));
    add(SessionType.fp2, 'Practice 2', race.practice2Date,
        const Duration(hours: 1, minutes: 30));
    add(SessionType.sprint, 'Sprint', race.sprintDate,
        const Duration(hours: 1));
    add(SessionType.fp3, 'Practice 3', race.practice3Date,
        const Duration(hours: 1, minutes: 30));
    add(SessionType.qualifying, 'Qualifying', race.qualifyingDate,
        const Duration(hours: 1));
    add(SessionType.race, '🏁 Race', race.raceDate,
        const Duration(hours: 2));

    return sessions;
  }
}

// ── Session helpers ────────────────────────────────────────────────────────

enum SessionType { fp1, fp2, fp3, sprint, qualifying, race }

class _SessionInfo {
  const _SessionInfo({
    required this.type,
    required this.title,
    required this.start,
    required this.duration,
    required this.season,
    required this.round,
    required this.circuitName,
    required this.locality,
    required this.country,
  });

  final SessionType type;
  final String title;
  final DateTime start;
  final Duration duration;
  final String season;
  final int round;
  final String circuitName;
  final String locality;
  final String country;
}

// Public session descriptor used by UI
class RaceSession {
  const RaceSession({
    required this.label,
    required this.date,
    required this.type,
  });

  final String label;
  final DateTime date;
  final SessionType type;
}

/// Returns sessions available for [race] (non-null dates only).
List<RaceSession> sessionsForRace(RaceModel race) {
  final list = <RaceSession>[];
  void add(String label, DateTime? dt, SessionType t) {
    if (dt != null) list.add(RaceSession(label: label, date: dt, type: t));
  }

  add('Practice 1', race.practice1Date, SessionType.fp1);
  add('Practice 2', race.practice2Date, SessionType.fp2);
  add('Sprint', race.sprintDate, SessionType.sprint);
  add('Practice 3', race.practice3Date, SessionType.fp3);
  add('Qualifying', race.qualifyingDate, SessionType.qualifying);
  add('Race', race.raceDate, SessionType.race);
  return list;
}
