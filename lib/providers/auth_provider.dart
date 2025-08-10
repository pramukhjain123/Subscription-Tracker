import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../services/storage_service.dart';
import '../services/api_service.dart';

class AuthProvider extends ChangeNotifier {
  bool _isAuthenticated = false;
  bool _isLoading = false;
  String? _currentUser;
  String? _error;

  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;
  String? get currentUser => _currentUser;
  String? get error => _error;

  AuthProvider() {
    print('AuthProvider: Constructor called');
    _checkAuthStatus().catchError((error) {
      print('AuthProvider: Error in constructor: $error');
    });
  }

  Future<void> _checkAuthStatus() async {
    _isLoading = true;
    notifyListeners();

    try {
      final token = await StorageService.read('auth_token');
      final user = await StorageService.read('current_user');
      
      print('Auth: Checking auth status - Token: ${token != null ? "exists" : "null"}, User: $user');
      
      if (token != null && user != null) {
        // Restore the auth token in ApiService
        print('Auth: Restoring auth token in ApiService');
        ApiService.setAuthToken(token);
        _isAuthenticated = true;
        _currentUser = user;
        print('Auth: Authentication restored successfully');
      } else {
        _isAuthenticated = false;
        _currentUser = null;
        print('Auth: No stored credentials found');
      }
    } catch (e) {
      print('Auth: Error checking auth status: $e');
      // On web, storage errors might be common, so we'll be more lenient
      if (kIsWeb) {
        print('Auth: Web platform - continuing without stored credentials');
        _isAuthenticated = false;
        _currentUser = null;
      } else {
        _isAuthenticated = false;
        _currentUser = null;
      }
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
      
      await StorageService.write('auth_token', response['token']);
      await StorageService.write('current_user', email);
      
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
      
      await StorageService.write('auth_token', response['token']);
      await StorageService.write('current_user', email);
      
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
      await StorageService.delete('auth_token');
      await StorageService.delete('current_user');
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
      final token = await StorageService.read('auth_token');
      final user = await StorageService.read('current_user');
      
      print('Auth: Verifying session - Token: ${token != null ? "exists" : "null"}, User: $user');
      
      if (token != null && user != null) {
        // Restore the auth token in ApiService
        print('Auth: Restoring auth token in ApiService during session verification');
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
      print('Auth: Error verifying session: $e');
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

  Future<void> refreshAuthState() async {
    print('Auth: Refreshing auth state...');
    await _checkAuthStatus();
  }


} 