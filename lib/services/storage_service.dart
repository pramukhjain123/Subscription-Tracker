import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage();
  
  // For web, use shared preferences; for mobile, use secure storage
  static Future<void> write(String key, String value) async {
    try {
      if (kIsWeb) {
        print('Storage: Writing to SharedPreferences - Key: $key, Value: $value');
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(key, value);
        print('Storage: Successfully wrote to SharedPreferences');
      } else {
        print('Storage: Writing to SecureStorage - Key: $key, Value: $value');
        await _secureStorage.write(key: key, value: value);
        print('Storage: Successfully wrote to SecureStorage');
      }
    } catch (e) {
      print('Storage: Error writing - Key: $key, Error: $e');
      rethrow;
    }
  }
  
  static Future<String?> read(String key) async {
    try {
      if (kIsWeb) {
        print('Storage: Reading from SharedPreferences - Key: $key');
        final prefs = await SharedPreferences.getInstance();
        final value = prefs.getString(key);
        print('Storage: Read from SharedPreferences - Key: $key, Value: ${value != null ? "exists" : "null"}');
        return value;
      } else {
        print('Storage: Reading from SecureStorage - Key: $key');
        final value = await _secureStorage.read(key: key);
        print('Storage: Read from SecureStorage - Key: $key, Value: ${value != null ? "exists" : "null"}');
        return value;
      }
    } catch (e) {
      print('Storage: Error reading - Key: $key, Error: $e');
      rethrow;
    }
  }
  
  static Future<void> delete(String key) async {
    try {
      if (kIsWeb) {
        print('Storage: Deleting from SharedPreferences - Key: $key');
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove(key);
        print('Storage: Successfully deleted from SharedPreferences');
      } else {
        print('Storage: Deleting from SecureStorage - Key: $key');
        await _secureStorage.delete(key: key);
        print('Storage: Successfully deleted from SecureStorage');
      }
    } catch (e) {
      print('Storage: Error deleting - Key: $key, Error: $e');
      rethrow;
    }
  }
  
  static Future<void> clear() async {
    try {
      if (kIsWeb) {
        print('Storage: Clearing SharedPreferences');
        final prefs = await SharedPreferences.getInstance();
        await prefs.clear();
        print('Storage: Successfully cleared SharedPreferences');
      } else {
        print('Storage: Clearing SecureStorage');
        await _secureStorage.deleteAll();
        print('Storage: Successfully cleared SecureStorage');
      }
    } catch (e) {
      print('Storage: Error clearing - Error: $e');
      rethrow;
    }
  }
}
