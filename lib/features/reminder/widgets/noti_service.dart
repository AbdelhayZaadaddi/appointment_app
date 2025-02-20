import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';


class NotiService {
  static final NotiService _instance = NotiService._internal();
  factory NotiService() => _instance;
  NotiService._internal();
  final FlutterLocalNotificationsPlugin notificationPlugin =
  FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  bool get isInitialized => _isInitialized;

  // INITIALIZE
  Future<void> initNotification() async {
    if (_isInitialized) return;

    // Request notification permissions for Android 13+
    if (await Permission.notification.isDenied) {
      await Permission.notification.request();
    }

    // Initialize timezone handling
    tz.initializeTimeZones();
    final String currentTimeZone = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(currentTimeZone));

    // Prepare Android init settings
    const AndroidInitializationSettings initSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    // Prepare iOS init settings
    const DarwinInitializationSettings initSettingsIOS = DarwinInitializationSettings(
      requestCriticalPermission: true,
      requestBadgePermission: true,
      requestAlertPermission: true,
    );

    // Initialize settings
    const InitializationSettings initSettings = InitializationSettings(
      android: initSettingsAndroid,
      iOS: initSettingsIOS,
    );

    // Initialize the plugin
    await notificationPlugin.initialize(initSettings);
    _isInitialized = true;
  }

  // NOTIFICATION DETAILS
  NotificationDetails notificationDetails() {
    return const NotificationDetails(
      android: AndroidNotificationDetails(
        'daily_channel_id',
        'Daily Notifications',
        channelDescription: 'Daily notification channel',
        importance: Importance.max,
        priority: Priority.high,
      ),
      iOS: DarwinNotificationDetails(),
    );
  }

  // SHOW NOTIFICATION
  Future<void> showNotification({
    int id = 0,
    String? title,
    String? body,
  }) async {
    if (!_isInitialized) {
      await initNotification();
    }
    print('Showing notification: $title, $body');

    await notificationPlugin.show(
      id,
      title,
      body,
      notificationDetails(), // Use the correct notification details
    );
  }

  // Schedule a notification at a specified time
  // - hour
  // - minute

  Future<void> scheduleNotification({
    int id = 1,
    required String title,
    required String body,
    required DateTime reminderTime, // This should be a DateTime object
  }) async {
    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime.from(reminderTime, tz.local);

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    await notificationPlugin.zonedSchedule(
      id,
      title,
      body,
      scheduledDate,
      notificationDetails(),
      uiLocalNotificationDateInterpretation:
      UILocalNotificationDateInterpretation.absoluteTime,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );

    print('Notification scheduled for $scheduledDate');
  }

  Future<void> cancelAllNotifications() async {
    await notificationPlugin.cancelAll();
  }



}