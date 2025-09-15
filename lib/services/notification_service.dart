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
    final double monthlyCost = subscription.price;
    if (subscription.lastUsed != null) {
      final int daysSinceLastUsed = DateTime.now().difference(subscription.lastUsed!).inDays;
      if (daysSinceLastUsed >= 7) {
        await _notifications.zonedSchedule(
          (subscription.id.hashCode + 1000),
          'Not using ${subscription.name}?',
          'It costs you ₹${monthlyCost.toStringAsFixed(0)}/month. You can cancel to save it.',
          tz.TZDateTime.now(tz.local).add(const Duration(seconds: 5)),
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'subscription_usage',
              'Subscription Usage',
              channelDescription: 'Notifications for unused subscriptions',
              importance: Importance.high,
              priority: Priority.high,
            ),
          ),
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        );
      }
    } else {
      // Never used: send a gentle reminder once after 10 days of tracking
      await _notifications.zonedSchedule(
        (subscription.id.hashCode + 1000),
        'Haven\'t started ${subscription.name}?',
        'It costs you ₹${monthlyCost.toStringAsFixed(0)}/month. Cancel anytime to save it.',
        tz.TZDateTime.now(tz.local).add(const Duration(days: 10)),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'subscription_usage',
            'Subscription Usage',
            channelDescription: 'Notifications for unused subscriptions',
            importance: Importance.high,
            priority: Priority.high,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      );
    }
  }

  static Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id);
  }

  static Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }
} 