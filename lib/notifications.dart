import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import 'app_state.dart';
import 'l10n.dart';
import 'models.dart';

/// Schedules all local notifications:
///  - every night: "plan tomorrow"
///  - every morning: "today's tasks"
///  - one-time reminders for tasks that have a time
class Notifier {
  Notifier._();
  static final Notifier instance = Notifier._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  bool _ready = false;

  static const NotificationDetails _details = NotificationDetails(
    android: AndroidNotificationDetails(
      'rojan_reminders',
      'Rojan reminders',
      channelDescription: 'Planning and task reminders',
      importance: Importance.high,
      priority: Priority.high,
    ),
  );

  Future<void> init() async {
    tzdata.initializeTimeZones();
    try {
      final zone = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(zone));
    } catch (_) {
      // Falls back to UTC; times may be shifted on some devices.
    }
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    await _plugin.initialize(const InitializationSettings(android: android));
    _ready = true;
  }

  /// Asks Android 13+ for the notification permission. Returns true if granted.
  Future<bool> requestPermission() async {
    if (!_ready) return false;
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    final granted = await android?.requestNotificationsPermission();
    return granted ?? true;
  }

  Future<void> reschedule(AppState s) async {
    if (!_ready) return;
    await _plugin.cancelAll();
    if (!s.notificationsOn || !s.onboarded) return;

    final l = s.lang;
    await _daily(1, s.nightH, s.nightM, tr(l, 'nightNotifTitle'),
        tr(l, 'nightNotifBody'));
    await _daily(2, s.morningH, s.morningM, tr(l, 'morningNotifTitle'),
        tr(l, 'morningNotifBody'));

    final now = tz.TZDateTime.now(tz.local);
    for (final t in s.tasks) {
      if (t.done || t.time == null) continue;
      final day = parseKey(t.date);
      final p = t.time!.split(':');
      final when = tz.TZDateTime(tz.local, day.year, day.month, day.day,
          int.parse(p[0]), int.parse(p[1]));
      if (when.isAfter(now)) {
        await _plugin.zonedSchedule(
          3 + (t.id.hashCode & 0x3fffffff),
          tr(l, 'taskNotifTitle'),
          t.title,
          when,
          _details,
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        );
      }
    }
  }

  Future<void> _daily(
      int id, int hour, int minute, String title, String body) async {
    final now = tz.TZDateTime.now(tz.local);
    var when =
        tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (when.isBefore(now)) when = when.add(const Duration(days: 1));
    await _plugin.zonedSchedule(
      id,
      title,
      body,
      when,
      _details,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }
}
