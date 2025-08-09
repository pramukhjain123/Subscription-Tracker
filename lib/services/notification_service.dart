import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import '../models/subscription.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();
  static bool _initialized = false;

  static Future<void> initialize() async {
    if (_initialized) return;

    // Initialize timezone
    tz.initializeTimeZones();

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings();

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _notifications.initialize(initializationSettings);
    _initialized = true;
  }

  static Future<void> scheduleDueDateNotification(Subscription subscription) async {
    if (subscription.daysUntilDue <= 7 && subscription.daysUntilDue >= 0) {
      await _notifications.zonedSchedule(
        subscription.id.hashCode,
        'Subscription Due Soon!',
        '${subscription.name} is due in ${subscription.daysUntilDue} days',
        tz.TZDateTime.now(tz.local).add(const Duration(seconds: 5)),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'subscription_due',
            'Subscription Due',
            channelDescription: 'Notifications for subscription due dates',
            importance: Importance.high,
            priority: Priority.high,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    }
  }

  static Future<void> scheduleUsageNotification(Subscription subscription) async {
    if (subscription.lastUsed != null) {
      final daysSinceLastUsed = DateTime.now().difference(subscription.lastUsed!).inDays;
      
      if (daysSinceLastUsed >= 7) {
        await _notifications.zonedSchedule(
          (subscription.id.hashCode + 1000), // Different ID for usage notifications
          'Unused Subscription Alert',
          'You haven\'t used ${subscription.name} for $daysSinceLastUsed days. Consider if it\'s worth your money!',
          tz.TZDateTime.now(tz.local).add(const Duration(seconds: 5)),
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'subscription_usage',
              'Subscription Usage',
              channelDescription: 'Notifications for unused subscriptions',
              importance: Importance.defaultImportance,
              priority: Priority.defaultPriority,
            ),
          ),
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
        );
      }
    }
  }

  static Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id);
  }

  static Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }
} 