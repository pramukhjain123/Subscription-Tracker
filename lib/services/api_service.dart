import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/subscription.dart';

class ApiService {
  // Read API base URL from build-time define. Defaults:
  // - Android emulator: http://10.0.2.2:5000/api
  // - Others: http://localhost:5000/api
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    // Default to the provided ngrok tunnel so builds work without extra flags
    defaultValue: 'https://880ed8ea364e.ngrok-free.app/api',
  );
  static String? _authToken;
  static const _timeout = Duration(seconds: 15);
  
  static void setAuthToken(String token) {
    _authToken = token;
  }
  
  static void clearAuthToken() {
    _authToken = null;
  }
  
  static Map<String, String> get _headers {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (_authToken != null) {
      headers['Authorization'] = 'Bearer $_authToken';
      print('API: Using auth token: ${_authToken!.substring(0, 10)}...');
    } else {
      print('API: No auth token available');
    }
    return headers;
  }

  static T _parseJsonOrThrow<T>(String body, {String fallbackMessage = 'Unexpected response format'}) {
    try {
      final decoded = json.decode(body);
      return decoded as T;
    } catch (e) {
      final snippet = body.length > 200 ? body.substring(0, 200) : body;
      throw Exception('$fallbackMessage. Body starts with: ${snippet.replaceAll('\n', ' ')}');
    }
  }
  
  // Get all subscriptions
  static Future<List<Subscription>> getSubscriptions() async {
    try {
      print('API: Getting subscriptions with headers: $_headers');
      final response = await http
          .get(
        Uri.parse('$baseUrl/subscriptions'),
        headers: _headers,
      )
          .timeout(_timeout);
      
      print('API: Response status: ${response.statusCode}, body: ${response.body}');
      
      if (response.statusCode == 200) {
        final List<dynamic> data = _parseJsonOrThrow<List<dynamic>>(response.body, fallbackMessage: 'Failed to parse subscriptions');
        return data.map((json) => Subscription.fromJson(json)).toList();
      } else if (response.statusCode == 401) {
        throw Exception('Authentication failed. Please log in again.');
      } else if (response.statusCode == 403) {
        throw Exception('Access denied. Please check your permissions.');
      } else {
        final snippet = response.body.length > 200 ? response.body.substring(0, 200) : response.body;
        throw Exception('Failed to load subscriptions: ${response.statusCode} - ${snippet.replaceAll('\n', ' ')}');
      }
    } catch (e) {
      print('API: Error getting subscriptions: $e');
      if (e.toString().contains('Connection refused') || e.toString().contains('Failed host lookup')) {
        throw Exception('Cannot connect to server. Please check if the backend is running.');
      } else {
        throw Exception('Network error: $e');
      }
    }
  }

  // Add new subscription
  static Future<Subscription> addSubscription(Subscription subscription) async {
    try {
      final response = await http
          .post(
        Uri.parse('$baseUrl/subscriptions'),
        headers: _headers,
        body: json.encode(subscription.toJson()),
      )
          .timeout(_timeout);

      if (response.statusCode == 200) {
        return Subscription.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to add subscription');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Delete subscription
  static Future<void> deleteSubscription(String id) async {
    try {
      final response = await http
          .delete(
        Uri.parse('$baseUrl/subscriptions/$id'),
        headers: _headers,
      )
          .timeout(_timeout);
      
      if (response.statusCode != 200) {
        throw Exception('Failed to delete subscription');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Update subscription
  static Future<Subscription> updateSubscription(String id, Subscription subscription) async {
    try {
      final response = await http
          .put(
        Uri.parse('$baseUrl/subscriptions/$id'),
        headers: _headers,
        body: json.encode(subscription.toJson()),
      )
          .timeout(_timeout);
      if (response.statusCode == 200) {
        return Subscription.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to update subscription');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
  
  // Authentication methods
  static Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http
          .post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
        body: json.encode({'email': email, 'password': password}),
      )
          .timeout(_timeout);
      
      if (response.statusCode == 200) {
        final data = _parseJsonOrThrow<Map<String, dynamic>>(response.body, fallbackMessage: 'Failed to parse login response');
        setAuthToken(data['token']);
        return data;
      } else {
        try {
          final error = json.decode(response.body);
          throw Exception(error['error'] ?? 'Login failed');
        } catch (_) {
          final snippet = response.body.length > 160 ? response.body.substring(0, 160) : response.body;
          throw Exception('Login failed: HTTP ${response.statusCode}. ${snippet.replaceAll('\n', ' ')}');
        }
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
  
  static Future<Map<String, dynamic>> register(String email, String password) async {
    try {
      final response = await http
          .post(
        Uri.parse('$baseUrl/auth/register'),
        headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
        body: json.encode({'email': email, 'password': password}),
      )
          .timeout(_timeout);
      
      if (response.statusCode == 200) {
        final data = _parseJsonOrThrow<Map<String, dynamic>>(response.body, fallbackMessage: 'Failed to parse register response');
        setAuthToken(data['token']);
        return data;
      } else {
        try {
          final error = json.decode(response.body);
          throw Exception(error['error'] ?? 'Registration failed');
        } catch (_) {
          final snippet = response.body.length > 160 ? response.body.substring(0, 160) : response.body;
          throw Exception('Registration failed: HTTP ${response.statusCode}. ${snippet.replaceAll('\n', ' ')}');
        }
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
}
 