import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import '../../data/models/milestone.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    tz.initializeTimeZones();

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    final DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    final InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
    );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) async {},
    );
  }

  Future<void> scheduleAnniversaryReminder(Milestone milestone) async {
    if (!milestone.reminderEnabled) return;

    final reminderDate = milestone.date.subtract(Duration(days: milestone.reminderDaysBefore));
    if (reminderDate.isBefore(DateTime.now())) return;

    final tz.TZDateTime scheduledDate = tz.TZDateTime.from(reminderDate, tz.local)
        .add(const Duration(hours: 9)); // Auto remind at 9:00 AM

    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'anniversary_channel',
      'Date Luv Nhắc Nhở',
      channelDescription: 'Nhắc nhở ngày kỷ niệm tình yêu',
      importance: Importance.max,
      priority: Priority.high,
      color: Color(0xFFFF6B9D),
    );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: DarwinNotificationDetails(badgeNumber: 1),
    );

    await flutterLocalNotificationsPlugin.zonedSchedule(
      milestone.id.hashCode,
      'Sắp tới: ${milestone.title} ${milestone.icon}',
      'Chỉ còn ${milestone.reminderDaysBefore} ngày nữa là đến ${milestone.title}. Hãy chuẩn bị điều bất ngờ nhé!',
      scheduledDate,
      platformChannelSpecifics,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  Future<void> cancelReminder(String id) async {
    await flutterLocalNotificationsPlugin.cancel(id.hashCode);
  }

  Future<void> cancelAll() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }
}
