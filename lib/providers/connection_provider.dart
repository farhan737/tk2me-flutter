import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:tk2me_flutter/services/api_service.dart';

class ConnectionProvider with ChangeNotifier {
  bool _isConnected = false;
  Timer? _connectionCheckTimer;
  
  bool get isConnected => _isConnected;
  
  ConnectionProvider() {
    // Check connection immediately when provider is created
    checkConnection();
    
    // Set up periodic connection check every 10 seconds
    _connectionCheckTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      checkConnection();
    });
  }
  
  @override
  void dispose() {
    _connectionCheckTimer?.cancel();
    super.dispose();
  }
  
  Future<void> checkConnection() async {
    try {
      // Try to connect to the server health check endpoint
      final response = await http.get(
        Uri.parse('${ApiService.baseUrl}/health'),
        // Set a short timeout to avoid hanging
      ).timeout(const Duration(seconds: 3));
      
      // If we get a successful response or even a 404 (which means the server is up but endpoint doesn't exist)
      final bool wasConnected = _isConnected;
      _isConnected = response.statusCode == 200 || response.statusCode == 404;
      
      // Only notify if the connection status changed
      if (wasConnected != _isConnected) {
        notifyListeners();
      }
    } catch (e) {
      // If there's an error (timeout, connection refused, etc.), we're not connected
      final bool wasConnected = _isConnected;
      _isConnected = false;
      
      // Only notify if the connection status changed
      if (wasConnected != _isConnected) {
        notifyListeners();
      }
    }
  }
}
