import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/subscription.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:5000/api';
  static String? _authToken;
  
  static void setAuthToken(String token) {
    _authToken = token;
  }
  
  static void clearAuthToken() {
    _authToken = null;
  }
  
  static Map<String, String> get _headers {
    final headers = {'Content-Type': 'application/json'};
    if (_authToken != null) {
      headers['Authorization'] = 'Bearer $_authToken';
      print('API: Using auth token: ${_authToken!.substring(0, 10)}...');
    } else {
      print('API: No auth token available');
    }
    return headers;
  }
  
  // Get all subscriptions
  static Future<List<Subscription>> getSubscriptions() async {
    try {
      print('API: Getting subscriptions with headers: $_headers');
      final response = await http.get(
        Uri.parse('$baseUrl/subscriptions'),
        headers: _headers,
      );
      
      print('API: Response status: ${response.statusCode}, body: ${response.body}');
      
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Subscription.fromJson(json)).toList();
      } else if (response.statusCode == 401) {
        throw Exception('Authentication failed. Please log in again.');
      } else if (response.statusCode == 403) {
        throw Exception('Access denied. Please check your permissions.');
      } else {
        throw Exception('Failed to load subscriptions: ${response.statusCode} - ${response.body}');
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
      final response = await http.post(
        Uri.parse('$baseUrl/subscriptions'),
        headers: _headers,
        body: json.encode(subscription.toJson()),
      );

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
      final response = await http.delete(
        Uri.parse('$baseUrl/subscriptions/$id'),
        headers: _headers,
      );
      
      if (response.statusCode != 200) {
        throw Exception('Failed to delete subscription');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
  
  // Authentication methods
  static Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email, 'password': password}),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setAuthToken(data['token']);
        return data;
      } else {
        final error = json.decode(response.body);
        throw Exception(error['error'] ?? 'Login failed');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
  
  static Future<Map<String, dynamic>> register(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email, 'password': password}),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setAuthToken(data['token']);
        return data;
      } else {
        final error = json.decode(response.body);
        throw Exception(error['error'] ?? 'Registration failed');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
} 