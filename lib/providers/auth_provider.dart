import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../services/api_service.dart';

class AuthProvider extends ChangeNotifier {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  bool _isAuthenticated = false;
  bool _isLoading = false;
  String? _currentUser;
  String? _error;

  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;
  String? get currentUser => _currentUser;
  String? get error => _error;

  AuthProvider() {
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    _isLoading = true;
    notifyListeners();

    try {
      final token = await _secureStorage.read(key: 'auth_token');
      final user = await _secureStorage.read(key: 'current_user');
      
      if (token != null && user != null) {
        _isAuthenticated = true;
        _currentUser = user;
      } else {
        _isAuthenticated = false;
        _currentUser = null;
      }
    } catch (e) {
      _isAuthenticated = false;
      _currentUser = null;
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await ApiService.login(email, password);
      
      await _secureStorage.write(key: 'auth_token', value: response['token']);
      await _secureStorage.write(key: 'current_user', value: email);
      
      _isAuthenticated = true;
      _currentUser = email;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> register(String email, String password, String confirmPassword) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      if (password != confirmPassword) {
        _error = 'Passwords do not match';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      if (password.length < 6) {
        _error = 'Password must be at least 6 characters long';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      final response = await ApiService.register(email, password);
      
      await _secureStorage.write(key: 'auth_token', value: response['token']);
      await _secureStorage.write(key: 'current_user', value: email);
      
      _isAuthenticated = true;
      _currentUser = email;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _secureStorage.delete(key: 'auth_token');
      await _secureStorage.delete(key: 'current_user');
      ApiService.clearAuthToken();
      
      _isAuthenticated = false;
      _currentUser = null;
    } catch (e) {
      // Handle error silently
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> changePassword(String currentPassword, String newPassword) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // For now, we'll skip password change functionality
      // as it requires additional backend endpoints
      _error = 'Password change not implemented yet';
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'Password change failed: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> verifySession() async {
    try {
      final token = await _secureStorage.read(key: 'auth_token');
      final user = await _secureStorage.read(key: 'current_user');
      
      if (token != null && user != null) {
        ApiService.setAuthToken(token);
        _isAuthenticated = true;
        _currentUser = user;
        notifyListeners();
        return true;
      } else {
        _isAuthenticated = false;
        _currentUser = null;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _isAuthenticated = false;
      _currentUser = null;
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }


} 