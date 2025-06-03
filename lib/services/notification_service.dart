import 'dart:io';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:daily_reminder_app/models/reminder.dart';
import 'package:logger/logger.dart';

final logger = Logger();

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _hasExactAlarmPermission = true;

  Future<void> init() async {
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const initializationSettings = InitializationSettings(
      android: androidSettings,
    );
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
    tz.initializeTimeZones();

    _hasExactAlarmPermission = await _checkExactAlarmPermission();
  }

  /// Menjadwalkan 4 notifikasi: -15, -10, -5, dan tepat waktu (0 menit)
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    final List<int> offsets = [0, -5, -10, -15];

    for (int i = 0; i < offsets.length; i++) {
      final offset = offsets[i];
      final scheduledTime = scheduledDate.subtract(Duration(minutes: -offset));

      if (scheduledTime.isBefore(DateTime.now())) {
        logger.w('⏩ Skipped offset $offset (already in past)');
        continue;
      }

      await flutterLocalNotificationsPlugin.zonedSchedule(
        id + i,
        offset == 0 ? title : '$title (Dalam ${-offset} menit)',
        body,
        tz.TZDateTime.from(scheduledTime, tz.local),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'reminder_channel',
            'Reminder Notifications',
            channelDescription: 'Channel for scheduled reminders',
            importance: Importance.max,
            priority: Priority.high,
            playSound: true,
          ),
        ),
        androidScheduleMode: _hasExactAlarmPermission
            ? AndroidScheduleMode.exactAllowWhileIdle
            : AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: null,
      );
    }
  }

  /// Fungsi tambahan agar ReminderProvider bisa langsung pakai Reminder
  Future<void> scheduleMultipleNotifications(Reminder reminder) async {
    if (reminder.id == null) return;

    final int baseId = _generateId(reminder.id!);
    await scheduleNotification(
      id: baseId,
      title: reminder.title,
      body: reminder.description,
      scheduledDate: reminder.dateTime,
    );
  }

  /// Batalkan semua notifikasi berdasarkan id Reminder
  Future<void> cancelNotifications(String reminderId) async {
    final int baseId = _generateId(reminderId);
    for (int i = 0; i < 4; i++) {
      await flutterLocalNotificationsPlugin.cancel(baseId + i);
    }
  }

  /// Batalkan semua notifikasi di seluruh aplikasi
  Future<void> cancelAllNotifications() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }

  /// 🔢 Konversi string ID (Firestore) ke int untuk notifikasi
  int _generateId(String id) {
    return id.hashCode & 0x7FFFFFFF;
  }

  /// 📋 Cek apakah SCHEDULE_EXACT_ALARM tersedia di Android 12+
  Future<bool> _checkExactAlarmPermission() async {
    if (!Platform.isAndroid) return true;

    final deviceInfo = await DeviceInfoPlugin().androidInfo;
    final sdkInt = deviceInfo.version.sdkInt;

    if (sdkInt >= 31) {
      final status = await Permission.scheduleExactAlarm.status;
      if (status.isGranted) return true;

      logger.w(
        "⏰ Exact alarm permission not granted. Trying to open settings...",
      );
      await Permission.scheduleExactAlarm.request();
      final updatedStatus = await Permission.scheduleExactAlarm.status;
      if (!updatedStatus.isGranted) {
        logger.w(
          "⚠️ Fallback to inexact alarms. Open Settings manually if needed.",
        );
        return false;
      }
    }
    return true;
  }
}
