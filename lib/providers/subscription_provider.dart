import 'package:flutter/foundation.dart';
import 'dart:async';
import '../models/subscription.dart';
import '../services/api_service.dart';
import '../services/notification_service.dart';
import '../services/usage_service.dart';

class SubscriptionProvider with ChangeNotifier {
  List<Subscription> _subscriptions = [];
  bool _isLoading = false;
  String? _error;
  Timer? _autoSyncTimer;

  List<Subscription> get subscriptions => _subscriptions;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAutoSyncEnabled => _autoSyncTimer != null;

  // Get subscriptions sorted by due date
  List<Subscription> get sortedSubscriptions {
    final sorted = List<Subscription>.from(_subscriptions);
    sorted.sort((a, b) => a.dueDate.compareTo(b.dueDate));
    return sorted;
  }

  Future<void> markAsPaid(String id, {int days = 30}) async {
    final index = _subscriptions.indexWhere((s) => s.id == id);
    if (index == -1) return;
    final current = _subscriptions[index];
    final newDue = current.dueDate.add(Duration(days: days));
    final updated = current.copyWith(dueDate: newDue);
    await updateSubscription(id, updated);
    await NotificationService.notifyPaymentMade(current.name, newDue);
  }

  // Get overdue subscriptions
  List<Subscription> get overdueSubscriptions {
    return _subscriptions.where((sub) => sub.isOverdue).toList();
  }

  // Get due soon subscriptions
  List<Subscription> get dueSoonSubscriptions {
    return _subscriptions.where((sub) => sub.isDueSoon).toList();
  }

  // Get total monthly cost
  double get totalMonthlyCost {
    return _subscriptions.fold(0.0, (sum, sub) => sum + sub.price);
  }

  // Estimated daily total cost assuming a 30-day billing cycle per subscription
  double get totalDailyCost {
    if (_subscriptions.isEmpty) return 0.0;
    return _subscriptions.fold(0.0, (sum, sub) => sum + (sub.price / 30.0));
  }

  Future<void> loadSubscriptions() async {
    print('SubscriptionProvider: Loading subscriptions...');
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _subscriptions = await ApiService.getSubscriptions();
      print('SubscriptionProvider: Loaded ${_subscriptions.length} subscriptions');
      await _scheduleNotifications();
    } catch (e) {
      print('SubscriptionProvider: Error loading subscriptions: $e');
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void startAutoSync({Duration interval = const Duration(minutes: 5)}) {
    _autoSyncTimer?.cancel();
    _autoSyncTimer = Timer.periodic(interval, (_) async {
      try {
        await syncUsageFromDevice(days: 30);
      } catch (_) {}
    });
    notifyListeners();
  }

  void stopAutoSync() {
    _autoSyncTimer?.cancel();
    _autoSyncTimer = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _autoSyncTimer?.cancel();
    super.dispose();
  }

  Future<void> addSubscription(Subscription subscription) async {
    try {
      final newSub = await ApiService.addSubscription(subscription);
      _subscriptions.add(newSub);
      notifyListeners();
      await _scheduleNotifications();
      await NotificationService.notifySubscriptionAdded(newSub.name);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> deleteSubscription(String id) async {
    try {
      final sub = _subscriptions.firstWhere((s) => s.id == id);
      await ApiService.deleteSubscription(id);
      _subscriptions.removeWhere((sub) => sub.id == id);
      notifyListeners();
      await NotificationService.notifySubscriptionDeleted(sub.name);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> updateSubscription(String id, Subscription updated) async {
    try {
      // Optimistic update
      final index = _subscriptions.indexWhere((s) => s.id == id);
      if (index == -1) return;
      final previous = _subscriptions[index];
      _subscriptions[index] = updated;
      notifyListeners();

      await ApiService.updateSubscription(id, updated);
      await _scheduleNotifications();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> updateUsage(String subscriptionId, double hours) async {
    final index = _subscriptions.indexWhere((sub) => sub.id == subscriptionId);
    if (index != -1) {
      final previous = _subscriptions[index];
      final updatedSubscription = previous.copyWith(
        usageHours: hours,
        lastUsed: DateTime.now(),
      );
      _subscriptions[index] = updatedSubscription;
      notifyListeners();
      try {
        await ApiService.updateSubscription(subscriptionId, updatedSubscription);
        await _scheduleNotifications();
      } catch (e) {
        _subscriptions[index] = previous;
        _error = e.toString();
        notifyListeners();
        rethrow;
      }
    }
  }

  Future<void> _scheduleNotifications() async {
    await NotificationService.initialize();
    
    for (final subscription in _subscriptions) {
      await NotificationService.scheduleDueDateNotification(subscription);
      await NotificationService.scheduleUsageNotification(subscription);
    }

    // High spend: surface expensive subscriptions
    for (final s in _subscriptions) {
      await NotificationService.scheduleHighSpendNotification(s);
    }
  }

  Future<void> rescheduleNotifications() async {
    await _scheduleNotifications();
  }

  // Fetch usage from device Digital Wellbeing (Android) and persist to backend
  Future<void> syncUsageFromDevice({int days = 30}) async {
    final hasPerm = await UsageService.hasPermission();
    if (!hasPerm) {
      await UsageService.openUsageAccessSettings();
      return;
    }

    for (final sub in _subscriptions) {
      if (sub.packageName == null || sub.packageName!.isEmpty) continue;
      final minutes = await UsageService.getUsageMinutes(sub.packageName!, days: days);
      final hours = minutes / 60.0;
      if (hours > 0) {
        await updateUsage(sub.id!, hours);
      }
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
} 