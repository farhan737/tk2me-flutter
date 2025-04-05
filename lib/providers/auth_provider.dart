import 'package:flutter/material.dart';
import 'package:tk2me_flutter/models/user.dart';
import 'package:tk2me_flutter/services/api_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:developer' as developer;
import 'dart:math' as math;

class AuthProvider with ChangeNotifier {
  User? _currentUser;
  bool _isLoading = false;
  String? _error;
  final storage = const FlutterSecureStorage();

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _currentUser != null;

  Future<void> checkAuthentication() async {
    _isLoading = true;
    notifyListeners();

    try {
      final userId = await storage.read(key: 'userId');
      final username = await storage.read(key: 'username');
      final token = await storage.read(key: 'token');

      if (userId != null && username != null && token != null) {
        _currentUser = User(
          id: int.parse(userId),
          username: username,
        );
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> register(String username, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      print('\n===== AUTH PROVIDER: REGISTRATION START =====');
      print('Processing registration for user: $username');
      
      final response = await ApiService.register(username, password);
      
      print('\n===== AUTH PROVIDER: REGISTRATION RESPONSE =====');
      print('Response data: $response');
      
      if (response.containsKey('error') && response['error'] == true) {
        // Handle detailed error from API service
        _error = 'Registration failed: ${response['message']}\n';
        if (response.containsKey('body')) {
          _error = '$_error\nServer response: ${response['body']}';
        }
        
        print('\n===== AUTH PROVIDER: REGISTRATION ERROR =====');
        print('Error details: $_error');
        
        _isLoading = false;
        notifyListeners();
        return false;
      } else if (response.containsKey('message') && 
          response['message'] == 'User registered successfully!') {
        
        print('\n===== AUTH PROVIDER: REGISTRATION SUCCESSFUL =====');
        print('User registered successfully');
        
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = response['message'] ?? 'Registration failed';
        
        print('\n===== AUTH PROVIDER: REGISTRATION FAILED =====');
        print('Failure reason: $_error');
        
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e, stackTrace) {
      _error = 'Exception during registration: $e';
      
      print('\n===== AUTH PROVIDER: REGISTRATION EXCEPTION =====');
      print('Exception: $e');
      print('Stack trace: $stackTrace');
      
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> login(String username, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      print('\n===== AUTH PROVIDER: LOGIN START =====');
      print('Attempting login for user: $username');
      
      final response = await ApiService.login(username, password);
      
      print('\n===== AUTH PROVIDER: LOGIN RESPONSE =====');
      print('Response data: $response');
      
      if (response.containsKey('token')) {
        // Verify token is received and stored
        final token = response['token'] as String;
        print('Token received: ${token.substring(0, math.min(10, token.length as int))}...');
        
        // Verify token is stored in secure storage
        await storage.write(key: 'token', value: token);
        await storage.write(key: 'userId', value: response['id'].toString());
        await storage.write(key: 'username', value: response['username']);
        
        // Verify token can be retrieved from secure storage
        final storedToken = await storage.read(key: 'token');
        print('Token stored and retrieved successfully: ${storedToken != null}');
        
        if (storedToken == null) {
          _error = 'Failed to store authentication token';
          _isLoading = false;
          notifyListeners();
          return false;
        }
        
        _currentUser = User(
          id: response['id'],
          username: response['username'],
        );
        
        print('\n===== AUTH PROVIDER: LOGIN SUCCESSFUL =====');
        print('User logged in: ${_currentUser?.username}');
        
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = response['message'] ?? 'Login failed';
        
        print('\n===== AUTH PROVIDER: LOGIN FAILED =====');
        print('Failure reason: $_error');
        
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e, stackTrace) {
      _error = 'Exception during login: $e';
      
      print('\n===== AUTH PROVIDER: LOGIN EXCEPTION =====');
      print('Exception: $e');
      print('Stack trace: $stackTrace');
      
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    try {
      await ApiService.logout();
      _currentUser = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
