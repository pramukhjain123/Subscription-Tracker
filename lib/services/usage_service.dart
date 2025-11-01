import 'dart:io';
import 'package:flutter/services.dart';

class UsageService {
  static const MethodChannel _channel = MethodChannel('usage_stats');

  static Future<bool> hasPermission() async {
    if (!Platform.isAndroid) return false;
    try {
      final res = await _channel.invokeMethod<bool>('hasPermission');
      return res ?? false;
    } catch (_) {
      return false;
    }
  }

  static Future<bool> openUsageAccessSettings() async {
    if (!Platform.isAndroid) return false;
    try {
      final res = await _channel.invokeMethod<bool>('openUsageAccessSettings');
      return res ?? false;
    } catch (_) {
      return false;
    }
  }

  static Future<int> getUsageMinutes(String packageName, {int days = 30}) async {
    if (!Platform.isAndroid) return 0;
    try {
      final res = await _channel.invokeMethod<int>('getUsageMinutes', {
        'packageName': packageName,
        'days': days,
      });
      return res ?? 0;
    } catch (_) {
      return 0;
    }
  }

  static Future<List<Map<String, String>>> listInstalledApps() async {
    if (!Platform.isAndroid) return [];
    try {
      final List<dynamic>? res = await _channel.invokeMethod('listInstalledApps');
      if (res == null) return [];
      return res
          .whereType<Map>()
          .map((e) => e.map((key, value) => MapEntry(key.toString(), value.toString())))
          .cast<Map<String, String>>()
          .toList();
    } catch (_) {
      return [];
    }
  }
}


