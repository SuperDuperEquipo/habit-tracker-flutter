import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:rachas/core/config/app_strings.dart';
import 'package:rachas/core/utils/date_helpers.dart';
import 'package:rachas/features/habits/habit.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  NotificationService({FlutterLocalNotificationsPlugin? plugin})
    : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  static const String _channelId = 'habit_reminders';
  static const NotificationDetails _details = NotificationDetails(
    android: AndroidNotificationDetails(
      _channelId,
      AppStrings.reminderChannelName,
      channelDescription: AppStrings.reminderChannelDescription,
      importance: Importance.high,
      priority: Priority.high,
    ),
  );

  final FlutterLocalNotificationsPlugin _plugin;
  bool _ready = false;
  bool _permissionRequested = false;

  /// Id numérico estable: cancel() lo recalcula aunque la app se reinicie.
  static int idFor(String habitId) {
    var hash = 0x811c9dc5;
    for (final unit in habitId.codeUnits) {
      hash ^= unit;
      hash = (hash * 0x01000193) & 0xffffffff;
    }
    return hash & 0x7fffffff;
  }

  Future<void> init() async {
    if (_ready) return;
    try {
      tz_data.initializeTimeZones();
      final timezone = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(timezone.identifier));
      await _plugin.initialize(
        settings: const InitializationSettings(
          android: AndroidInitializationSettings('ic_notification'),
        ),
      );
      _ready = true;
    } on Object catch (error) {
      debugPrint('NotificationService.init falló: $error');
    }
  }

  Future<void> schedule(Habit habit) async {
    assert(habit.id.isNotEmpty, 'El hábito debe estar guardado (con id).');
    final time = parseReminderTime(habit.reminderTime);
    if (time == null) {
      await cancel(habit.id);
      return;
    }
    if (!_ready) return;

    await _requestPermissionOnce();
    await _plugin.zonedSchedule(
      id: idFor(habit.id),
      scheduledDate: _nextOccurrence(time.hour, time.minute),
      notificationDetails: _details,
      androidScheduleMode: await _scheduleMode(),
      title: habit.name,
      body: AppStrings.reminderBody,
      payload: habit.id,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<void> cancel(String habitId) async {
    if (!_ready) return;
    await _plugin.cancel(id: idFor(habitId));
  }

  Future<void> cancelAll() async {
    if (!_ready) return;
    await _plugin.cancelAll();
  }

  AndroidFlutterLocalNotificationsPlugin? get _android {
    return _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
  }

  Future<void> _requestPermissionOnce() async {
    if (_permissionRequested) return;
    _permissionRequested = true;
    await _android?.requestNotificationsPermission();
  }

  Future<AndroidScheduleMode> _scheduleMode() async {
    final canUseExact =
        await _android?.canScheduleExactNotifications() ?? false;
    return canUseExact
        ? AndroidScheduleMode.exactAllowWhileIdle
        : AndroidScheduleMode.inexactAllowWhileIdle;
  }

  tz.TZDateTime _nextOccurrence(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    final today = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );
    if (today.isAfter(now)) return today;
    return tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day + 1,
      hour,
      minute,
    );
  }
}
