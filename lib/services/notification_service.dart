import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

import '../data/models/race_model.dart';

class NotificationService {
  NotificationService._();

  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;

    // Android settings - uses the app icon as notification icon
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS settings
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _plugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    _initialized = true;
  }

  void _onNotificationTap(NotificationResponse response) {
    // Handle notification tap — deep link routing can be wired here later
  }

  Future<bool> requestPermissions() async {
    // Request Android notification permission (Android 13+)
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (android != null) {
      final granted = await android.requestNotificationsPermission();
      if (granted != true) return false;
    }

    // Request iOS notification permission
    final ios = _plugin.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();
    if (ios != null) {
      final granted = await ios.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      return granted ?? false;
    }

    return true;
  }

  Future<void> scheduleRaceNotification(
    RaceModel race,
    int minutesBefore,
  ) async {
    if (!_initialized) await init();

    final raceLocal = race.raceDate.toLocal();
    final notifyAt = raceLocal.subtract(Duration(minutes: minutesBefore));

    if (notifyAt.isBefore(DateTime.now())) return;

    final tzNotifyAt = tz.TZDateTime.from(notifyAt, tz.local);

    // Android notification details
    const androidDetails = AndroidNotificationDetails(
      'race_reminders',
      'Race Reminders',
      channelDescription: 'Notifications for upcoming F1 races',
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
    );

    // iOS notification details
    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      sound: 'default',
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    // Use round number as notification ID to allow easy cancellation per race
    final notificationId = race.round * 100 + minutesBefore;

    await _plugin.zonedSchedule(
      notificationId,
      '🏎  ${race.raceName} — LIGHTS OUT IN ${minutesBefore}MIN',
      '${race.circuitName} · ${race.locality}, ${race.country}',
      tzNotifyAt,
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  Future<void> cancelRaceNotification(int round) async {
    if (!_initialized) await init();
    // Cancel all possible minutesBefore variants for this round
    for (final mins in [15, 30, 60]) {
      await _plugin.cancel(round * 100 + mins);
    }
  }

  Future<void> cancelAll() async {
    if (!_initialized) await init();
    await _plugin.cancelAll();
  }

  Future<List<PendingNotificationRequest>> getPending() async {
    if (!_initialized) await init();
    return _plugin.pendingNotificationRequests();
  }
}
