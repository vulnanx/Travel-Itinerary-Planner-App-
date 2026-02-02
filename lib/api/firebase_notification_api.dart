import 'package:firebase_messaging/firebase_messaging.dart';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tzl;

Future<void> handleBackgroundMessage(RemoteMessage message) async {}

class NotifApi {
  final notificationPlugin = FlutterLocalNotificationsPlugin();
  final bool _isinitialized = false;

  bool get initialized => _isinitialized;

  // initialize
  Future<void> initNotif() async {
    if (_isinitialized) return;

    tzl.initializeTimeZones();
    final String currentTimeZone = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(currentTimeZone));

    const initSettings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
    );

    await Permission.notification.request();
    await notificationPlugin.initialize(initSettings);
  }

  // notif detail setup
  NotificationDetails notifDetails() {
    return const NotificationDetails(
      android: AndroidNotificationDetails(
        "NearTrip_notif",
        "trippals",
        importance: Importance.max,
        priority: Priority.high,
      ),
    );
  }

  //show notification
  Future<void> showNotification({
    int id = 0,
    String? title,
    String? body,
  }) async {
    await notificationPlugin.show(
      id,
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'instant_notification_channel_id',
          'Instant Notifications',
          importance: Importance.max,
          priority: Priority.max,
        ),
      ),
    );
  }

  // when notif is tapped

  // schedule notif
  Future<void> scheduleNotification({
    int id = 1,
    required String title,
    required String body,
    required DateTime date,
  }) async {
    final now = tz.TZDateTime.now(tz.local);

    var scheduledDate = tz.TZDateTime(
      tz.local,
      date.year,
      date.month,
      date.day,
      0,
      0,
    );

    // print(tz.local);
    // print(date);

    await notificationPlugin.zonedSchedule(
      id,
      title,
      body,
      scheduledDate,
      notifDetails(),
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    );
  }
}
