import 'package:flutter/foundation.dart';
import '../models/subscription.dart';
import '../services/api_service.dart';
import '../services/notification_service.dart';

class SubscriptionProvider with ChangeNotifier {
  List<Subscription> _subscriptions = [];
  bool _isLoading = false;
  String? _error;

  List<Subscription> get subscriptions => _subscriptions;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Get subscriptions sorted by due date
  List<Subscription> get sortedSubscriptions {
    final sorted = List<Subscription>.from(_subscriptions);
    sorted.sort((a, b) => a.dueDate.compareTo(b.dueDate));
    return sorted;
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

  Future<void> loadSubscriptions() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _subscriptions = await ApiService.getSubscriptions();
      await _scheduleNotifications();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addSubscription(Subscription subscription) async {
    try {
      final newSubscription = await ApiService.addSubscription(subscription);
      _subscriptions.add(newSubscription);
      await _scheduleNotifications();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> deleteSubscription(String id) async {
    try {
      await ApiService.deleteSubscription(id);
      _subscriptions.removeWhere((sub) => sub.id == id);
      await NotificationService.cancelNotification(id.hashCode);
      await NotificationService.cancelNotification(id.hashCode + 1000);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> updateUsage(String subscriptionId, double hours) async {
    final index = _subscriptions.indexWhere((sub) => sub.id == subscriptionId);
    if (index != -1) {
      final updatedSubscription = _subscriptions[index].copyWith(
        usageHours: hours,
        lastUsed: DateTime.now(),
      );
      _subscriptions[index] = updatedSubscription;
      notifyListeners();
    }
  }

  Future<void> _scheduleNotifications() async {
    await NotificationService.initialize();
    
    for (final subscription in _subscriptions) {
      await NotificationService.scheduleDueDateNotification(subscription);
      await NotificationService.scheduleUsageNotification(subscription);
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
} 