import 'dart:io';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import '../models/subscription.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();
  static bool _initialized = false;
  static bool _canScheduleExact = true;

  static Future<void> initialize() async {
    if (_initialized) return;

    // Initialize timezone
    tz.initializeTimeZones();

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _notifications.initialize(initializationSettings);

    // Android 12+ exact alarm permission
    if (Platform.isAndroid) {
      final androidPlugin = _notifications
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      if (androidPlugin != null) {
        try {
          // Android 13+ notifications permission
          await androidPlugin.requestNotificationsPermission();

          // Create notification channels explicitly
          await androidPlugin.createNotificationChannel(const AndroidNotificationChannel(
            'subscription_due',
            'Subscription Due',
            description: 'Notifications for subscription due dates',
            importance: Importance.high,
          ));
          await androidPlugin.createNotificationChannel(const AndroidNotificationChannel(
            'subscription_usage',
            'Subscription Usage',
            description: 'Notifications for unused subscriptions',
            importance: Importance.high,
          ));
          await androidPlugin.createNotificationChannel(const AndroidNotificationChannel(
            'test_channel',
            'Test Notifications',
            description: 'Manual test notifications',
            importance: Importance.high,
          ));
          await androidPlugin.createNotificationChannel(const AndroidNotificationChannel(
            'subscription_actions',
            'Subscription Actions',
            description: 'Notifications for subscription add/delete/pay actions',
            importance: Importance.high,
          ));

          // Best-effort request for exact alarms on Android 12+
          await androidPlugin.requestExactAlarmsPermission();
          // Conservatively assume not granted unless user enables in settings.
          _canScheduleExact = false;
        } catch (_) {
          _canScheduleExact = false;
        }
      }
    }
    _initialized = true;
  }

  static Future<void> scheduleDueDateNotification(Subscription subscription) async {
    await initialize();
    final now = DateTime.now();
    final days = subscription.daysUntilDue;
    
    // Cancel any existing notification for this subscription
    await _notifications.cancel(subscription.id.hashCode);
    
    if (subscription.isOverdue) {
      // Fire immediately for overdue
      await _notifications.show(
        subscription.id.hashCode,
        'Payment overdue — Pay now',
        '${subscription.name} payment is overdue. Pay to continue access.',
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'subscription_due',
            'Subscription Due',
            channelDescription: 'Notifications for subscription due dates',
            importance: Importance.high,
            priority: Priority.high,
          ),
        ),
      );
      return;
    }
    
    if (days <= 3 && days > 0) {
      // Schedule for 9 AM today if not yet passed, otherwise 9 AM tomorrow
      var scheduledTime = DateTime(now.year, now.month, now.day, 9, 0);
      if (scheduledTime.isBefore(now)) {
        scheduledTime = scheduledTime.add(const Duration(days: 1));
      }
      
      await _notifications.zonedSchedule(
        subscription.id.hashCode,
        'Payment due in $days days — Pay for ${subscription.name}',
        'Pay before the due date to avoid interruption.',
        tz.TZDateTime.from(scheduledTime, tz.local),
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
      );
      return;
    }
    
    // Schedule notification for when it becomes due soon (3 days before)
    if (days > 3) {
      final daysUntilDueSoon = days - 3;
      var scheduledTime = DateTime(now.year, now.month, now.day, 9, 0).add(Duration(days: daysUntilDueSoon));
      
      await _notifications.zonedSchedule(
        subscription.id.hashCode,
        'Payment due in 3 days — Pay for ${subscription.name}',
        'Pay before the due date to avoid interruption.',
        tz.TZDateTime.from(scheduledTime, tz.local),
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
      );
    }
  }

  static Future<void> scheduleUsageNotification(Subscription subscription) async {
    await initialize();
    final now = DateTime.now();
    final days = subscription.daysUntilDue;
    final hours = subscription.usageHours;
    final monthlyCost = subscription.price;
    final double hourlyCost = hours > 0 ? (monthlyCost / hours) : monthlyCost;
    final double hourlyCostRatio = monthlyCost > 0 ? (hourlyCost / monthlyCost) : 1.0;
    
    // Cancel any existing usage notification for this subscription
    await _notifications.cancel(subscription.id.hashCode + 1000);
    
    // Schedule for 8 PM today if not yet passed, otherwise 8 PM tomorrow
    var scheduledTime = DateTime(now.year, now.month, now.day, 20, 0);
    if (scheduledTime.isBefore(now)) {
      scheduledTime = scheduledTime.add(const Duration(days: 1));
    }
    
    if (days <= 5 && days >= 0) {
      if ((hours > 0 && hourlyCostRatio <= 0.05) || hours >= 15) {
        // Great value - fire immediately
        await _notifications.show(
          (subscription.id.hashCode + 1000),
          'Great value — Renew ${subscription.name}',
          'You used ${hours.toStringAsFixed(1)}h this cycle. Renew to keep watching.',
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'subscription_usage',
              'Subscription Usage',
              channelDescription: 'Notifications for unused subscriptions',
              importance: Importance.high,
              priority: Priority.high,
            ),
          ),
        );
        return;
      }
      if (hours < 3) {
        // Low usage - fire immediately
        await _notifications.show(
          (subscription.id.hashCode + 1000),
          'Low usage — Consider pausing ${subscription.name}',
          'You used only ${hours.toStringAsFixed(1)}h. It\'s ₹${monthlyCost.toStringAsFixed(0)}/month.',
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'subscription_usage',
              'Subscription Usage',
              channelDescription: 'Notifications for unused subscriptions',
              importance: Importance.high,
              priority: Priority.high,
            ),
          ),
        );
        return;
      }
    }
    
    if (subscription.lastUsed != null) {
      final int daysSinceLastUsed = now.difference(subscription.lastUsed!).inDays;
      if (daysSinceLastUsed >= 7) {
        // Not using - fire immediately
        await _notifications.show(
          (subscription.id.hashCode + 1000),
          'Not using ${subscription.name}?',
          'It costs you ₹${monthlyCost.toStringAsFixed(0)}/month. You can cancel to save it.',
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'subscription_usage',
              'Subscription Usage',
              channelDescription: 'Notifications for unused subscriptions',
              importance: Importance.high,
              priority: Priority.high,
            ),
          ),
        );
      }
    } else if (days > 10) {
      // Haven't started - schedule for 10 days from now at 8 PM
      scheduledTime = DateTime(now.year, now.month, now.day, 20, 0).add(const Duration(days: 10));
      await _notifications.zonedSchedule(
        (subscription.id.hashCode + 1000),
        'Haven\'t started ${subscription.name}?',
        'It costs you ₹${monthlyCost.toStringAsFixed(0)}/month. Cancel anytime to save it.',
        tz.TZDateTime.from(scheduledTime, tz.local),
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
      );
    }
  }

  static Future<void> scheduleHighSpendNotification(Subscription subscription) async {
    await initialize();
    
    // Cancel any existing high spend notification for this subscription
    await _notifications.cancel(subscription.id.hashCode + 2000);
    
    if (subscription.price >= 999) {
      // Fire immediately for high spend
      await _notifications.show(
        (subscription.id.hashCode + 2000),
        'High monthly spend — Review ${subscription.name}',
        '₹${subscription.price.toStringAsFixed(0)}/month. Consider a lower plan or pausing.',
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'subscription_usage',
            'Subscription Usage',
            channelDescription: 'Notifications for unused subscriptions',
            importance: Importance.high,
            priority: Priority.high,
          ),
        ),
      );
    }
  }

  static Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id);
  }

  static Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }

  static Future<void> sendTestNotification() async {
    await initialize();
    await _notifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      'Test notification',
      'If you see this, notifications are working',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'test_channel',
          'Test Notifications',
          channelDescription: 'Manual test notifications',
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
    );
  }

  static Future<void> notifySubscriptionAdded(String name) async {
    await initialize();
    await _notifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      'Subscription added',
      '$name has been added to your subscriptions.',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'subscription_actions',
          'Subscription Actions',
          channelDescription: 'Notifications for subscription add/delete/pay actions',
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
    );
  }

  static Future<void> notifySubscriptionDeleted(String name) async {
    await initialize();
    await _notifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      'Subscription deleted',
      '$name has been removed from your subscriptions.',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'subscription_actions',
          'Subscription Actions',
          channelDescription: 'Notifications for subscription add/delete/pay actions',
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
    );
  }

  static Future<void> notifyPaymentMade(String name, DateTime newDueDate) async {
    await initialize();
    await _notifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      'Payment recorded',
      '$name payment recorded. Next due: ${newDueDate.day}/${newDueDate.month}/${newDueDate.year}',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'subscription_actions',
          'Subscription Actions',
          channelDescription: 'Notifications for subscription add/delete/pay actions',
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
    );
  }

  static Future<void> sendSampleContextual({String name = 'Sample OTT', double price = 499, double hours = 2, int daysUntilDue = 2}) async {
    await initialize();
    // Due soon
    await _notifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000 + 1,
      'Payment due in $daysUntilDue days — Pay for $name',
      'Pay before the due date to avoid interruption.',
      const NotificationDetails(
        android: AndroidNotificationDetails('subscription_due','Subscription Due', channelDescription: 'Notifications for subscription due dates', importance: Importance.high, priority: Priority.high),
      ),
    );
    // Overdue
    await _notifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000 + 2,
      'Payment overdue — Pay now',
      '$name payment is overdue. Pay to continue access.',
      const NotificationDetails(
        android: AndroidNotificationDetails('subscription_due','Subscription Due', channelDescription: 'Notifications for subscription due dates', importance: Importance.high, priority: Priority.high),
      ),
    );
    // Low usage
    await _notifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000 + 3,
      'Low usage — Consider pausing $name',
      'You used only ${hours.toStringAsFixed(1)}h. It’s ₹${price.toStringAsFixed(0)}/month.',
      const NotificationDetails(
        android: AndroidNotificationDetails('subscription_usage','Subscription Usage', channelDescription: 'Notifications for unused subscriptions', importance: Importance.high, priority: Priority.high),
      ),
    );
    // Renew-worthy
    await _notifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000 + 4,
      'Great value — Renew $name',
      'You used 16.0h this cycle. Renew to keep watching.',
      const NotificationDetails(
        android: AndroidNotificationDetails('subscription_usage','Subscription Usage', channelDescription: 'Notifications for unused subscriptions', importance: Importance.high, priority: Priority.high),
      ),
    );
    // High spend
    await _notifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000 + 5,
      'High monthly spend — Review $name',
      '₹${price.toStringAsFixed(0)}/month. Consider a lower plan or pausing.',
      const NotificationDetails(
        android: AndroidNotificationDetails('subscription_usage','Subscription Usage', channelDescription: 'Notifications for unused subscriptions', importance: Importance.high, priority: Priority.high),
      ),
    );
  }
}