import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:developer' as developer;
import 'dart:math' as math;

class ApiService {
  // You can change this to match your environment:
  // - Use 'http://10.0.2.2:8080/api' for Android emulator
  // - Use 'http://localhost:8080/api' for iOS simulator or desktop app
  // - Use actual IP address when testing on physical devices
  // For ngrok, use the full URL without port number
  static const String baseUrl = 'https://model-bunny-just.ngrok-free.app/api';
  
  static const storage = FlutterSecureStorage();
  
  // Helper method to get a standard HTTP client
  static http.Client _getClient() {
    return http.Client();
  }
  
  // Auth endpoints
  static Future<Map<String, dynamic>> register(String username, String password) async {
    try {
      print('\n===== REGISTRATION REQUEST =====');
      print('Attempting to register user: $username');
      print('API URL: ${Uri.parse('$baseUrl/auth/signup')}');
      print('Request body: {"username": "$username", "password": "***"}');
      
      final client = _getClient();
      final response = await client.post(
        Uri.parse('$baseUrl/auth/signup'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'password': password,
        }),
      );
      client.close();
      
      print('\n===== REGISTRATION RESPONSE =====');
      print('Status code: ${response.statusCode}');
      print('Response headers: ${response.headers}');
      print('Response body: ${response.body}');
      
      if (response.statusCode >= 400) {
        print('\n===== REGISTRATION ERROR =====');
        print('Server returned error status: ${response.statusCode}');
        print('Error response: ${response.body}');
        return {
          'error': true,
          'status': response.statusCode,
          'message': 'Server error: ${response.statusCode}',
          'body': response.body
        };
      }
      
      print('\n===== REGISTRATION SUCCESSFUL =====');
      return jsonDecode(response.body);
    } catch (e, stackTrace) {
      print('\n===== REGISTRATION EXCEPTION =====');
      print('Exception: $e');
      print('Stack trace: $stackTrace');
      return {'error': true, 'message': 'Exception: $e'};
    }
  }
  
  static Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      print('\n===== LOGIN REQUEST =====');
      print('Attempting to login user: $username');
      print('API URL: ${Uri.parse('$baseUrl/auth/signin')}');
      print('Request body: {"username": "$username", "password": "***"}');
      
      final client = _getClient();
      final response = await client.post(
        Uri.parse('$baseUrl/auth/signin'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'password': password,
        }),
      );
      client.close();
      
      print('\n===== LOGIN RESPONSE =====');
      print('Status code: ${response.statusCode}');
      print('Response headers: ${response.headers}');
      print('Response body: ${response.body}');
      
      if (response.statusCode >= 400) {
        print('\n===== LOGIN ERROR =====');
        print('Server returned error status: ${response.statusCode}');
        print('Error response: ${response.body}');
        return {
          'error': true,
          'status': response.statusCode,
          'message': 'Server error: ${response.statusCode}',
          'body': response.body
        };
      }
      
      final data = jsonDecode(response.body);
      
      if (response.statusCode == 200) {
        print('\n===== LOGIN SUCCESSFUL =====');
        print('User logged in: $username');
        print('Token received: ${data.containsKey("token") ? "Yes" : "No"}');
        
        // Save token to secure storage
        if (data.containsKey('token')) {
          await storage.write(key: 'token', value: data['token']);
          await storage.write(key: 'userId', value: data['id'].toString());
          await storage.write(key: 'username', value: data['username']);
          print('Token and user data saved to secure storage');
        } else {
          print('WARNING: No token found in response');
        }
      }
      
      return data;
    } catch (e, stackTrace) {
      print('\n===== LOGIN EXCEPTION =====');
      print('Exception: $e');
      print('Stack trace: $stackTrace');
      return {'error': true, 'message': 'Exception: $e'};
    }
  }
  
  static Future<void> logout() async {
    await storage.delete(key: 'token');
    await storage.delete(key: 'userId');
    await storage.delete(key: 'username');
  }
  
  // Helper method to get auth headers
  static Future<Map<String, String>> _getAuthHeaders() async {
    print('\n===== API SERVICE: GETTING AUTH HEADERS =====');
    final token = await storage.read(key: 'token');
    
    if (token == null || token.isEmpty) {
      print('WARNING: No token found in secure storage');
      return {
        'Content-Type': 'application/json',
      };
    }
    
    print('Token found in secure storage: ${token.substring(0, math.min(10, token.length as int))}...');
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
    
    print('Auth headers prepared: ${headers.keys.toList()}');
    return headers;
  }
  
  // Friend endpoints
  static Future<List<dynamic>> getFriends() async {
    try {
      print('\n===== API SERVICE: GETTING FRIENDS LIST =====');
      final headers = await _getAuthHeaders();
      final requestUrl = '$baseUrl/friends/list';
      print('Request URL: ${Uri.parse(requestUrl)}');
      print('Request headers: $headers');
      
      final client = _getClient();
      final response = await client.get(
        Uri.parse(requestUrl),
        headers: headers,
      );
      client.close();
      
      print('Response status code: ${response.statusCode}');
      print('Response headers: ${response.headers}');
      print('Response body: ${response.body}');
      
      if (response.statusCode >= 400) {
        print('Error response: ${response.body}');
        return [];
      }
      
      return jsonDecode(response.body);
    } catch (e, stackTrace) {
      print('Exception during getFriends: $e');
      print('Stack trace: $stackTrace');
      return [];
    }
  }
  
  static Future<List<dynamic>> getPendingRequests() async {
    try {
      print('\n===== API SERVICE: GETTING PENDING REQUESTS =====');
      final headers = await _getAuthHeaders();
      final requestUrl = '$baseUrl/friends/requests/pending';
      print('Request URL: ${Uri.parse(requestUrl)}');
      print('Request headers: $headers');
      
      final client = _getClient();
      final response = await client.get(
        Uri.parse(requestUrl),
        headers: headers,
      );
      client.close();
      
      print('Response status code: ${response.statusCode}');
      print('Response headers: ${response.headers}');
      print('Response body: ${response.body}');
      
      if (response.statusCode >= 400) {
        print('Error response: ${response.body}');
        return [];
      }
      
      return jsonDecode(response.body);
    } catch (e, stackTrace) {
      print('Exception during getPendingRequests: $e');
      print('Stack trace: $stackTrace');
      return [];
    }
  }
  
  static Future<Map<String, dynamic>> sendFriendRequest(String username) async {
    try {
      print('\n===== API SERVICE: SENDING FRIEND REQUEST =====');
      final headers = await _getAuthHeaders();
      
      // Fixed URL path to match the Spring Boot controller endpoint
      // baseUrl already includes '/api', so we don't need to add it again
      final requestUrl = '$baseUrl/friends/request/$username';
      print('Request URL: ${Uri.parse(requestUrl)}');
      print('Request headers: $headers');
      
      final client = _getClient();
      final response = await client.post(
        Uri.parse(requestUrl),
        headers: headers,
      );
      client.close();
      
      print('Response status code: ${response.statusCode}');
      print('Response headers: ${response.headers}');
      print('Response body: ${response.body}');
      
      if (response.statusCode >= 400) {
        print('Error response: ${response.body}');
        return {'error': 'Failed to send friend request', 'details': response.body};
      }
      
      return jsonDecode(response.body);
    } catch (e, stackTrace) {
      print('Exception during sendFriendRequest: $e');
      print('Stack trace: $stackTrace');
      return {'error': 'Exception occurred: $e'};
    }
  }
  
  static Future<Map<String, dynamic>> acceptFriendRequest(int requestId) async {
    try {
      print('\n===== API SERVICE: ACCEPTING FRIEND REQUEST =====');
      final headers = await _getAuthHeaders();
      final requestUrl = '$baseUrl/friends/request/$requestId/accept';
      print('Request URL: ${Uri.parse(requestUrl)}');
      print('Request headers: $headers');
      
      final client = _getClient();
      final response = await client.put(
        Uri.parse(requestUrl),
        headers: headers,
      );
      client.close();
      
      print('Response status code: ${response.statusCode}');
      print('Response headers: ${response.headers}');
      print('Response body: ${response.body}');
      
      if (response.statusCode >= 400) {
        print('Error response: ${response.body}');
        return {'error': 'Failed to accept friend request', 'details': response.body};
      }
      
      return jsonDecode(response.body);
    } catch (e, stackTrace) {
      print('Exception during acceptFriendRequest: $e');
      print('Stack trace: $stackTrace');
      return {'error': 'Exception occurred: $e'};
    }
  }
  
  static Future<Map<String, dynamic>> rejectFriendRequest(int requestId) async {
    try {
      print('\n===== API SERVICE: REJECTING FRIEND REQUEST =====');
      final headers = await _getAuthHeaders();
      final requestUrl = '$baseUrl/friends/request/$requestId/reject';
      print('Request URL: ${Uri.parse(requestUrl)}');
      print('Request headers: $headers');
      
      final client = _getClient();
      final response = await client.put(
        Uri.parse(requestUrl),
        headers: headers,
      );
      client.close();
      
      print('Response status code: ${response.statusCode}');
      print('Response headers: ${response.headers}');
      print('Response body: ${response.body}');
      
      if (response.statusCode >= 400) {
        print('Error response: ${response.body}');
        return {'error': 'Failed to reject friend request', 'details': response.body};
      }
      
      return jsonDecode(response.body);
    } catch (e, stackTrace) {
      print('Exception during rejectFriendRequest: $e');
      print('Stack trace: $stackTrace');
      return {'error': 'Exception occurred: $e'};
    }
  }
  
  // Message endpoints
  static Future<List<dynamic>> getConversation(String username) async {
    try {
      print('\n===== API SERVICE: GETTING CONVERSATION =====');
      final headers = await _getAuthHeaders();
      final requestUrl = '$baseUrl/messages/conversation/$username';
      print('Request URL: ${Uri.parse(requestUrl)}');
      print('Request headers: $headers');
      
      final client = _getClient();
      final response = await client.get(
        Uri.parse(requestUrl),
        headers: headers,
      );
      client.close();
      
      print('Response status code: ${response.statusCode}');
      print('Response headers: ${response.headers}');
      print('Response body: ${response.body}');
      
      if (response.statusCode >= 400) {
        print('Error response: ${response.body}');
        return [];
      }
      
      return jsonDecode(response.body);
    } catch (e, stackTrace) {
      print('Exception during getConversation: $e');
      print('Stack trace: $stackTrace');
      return [];
    }
  }
  
  static Future<Map<String, dynamic>> sendMessage(String username, String content) async {
    try {
      print('\n===== API SERVICE: SENDING MESSAGE =====');
      final headers = await _getAuthHeaders();
      final requestUrl = '$baseUrl/messages/send/$username';
      print('Request URL: ${Uri.parse(requestUrl)}');
      print('Request headers: $headers');
      print('Request body: ${jsonEncode({'content': content})}');
      
      final client = _getClient();
      final response = await client.post(
        Uri.parse(requestUrl),
        headers: headers,
        body: jsonEncode({
          'content': content,
        }),
      );
      client.close();
      
      print('Response status code: ${response.statusCode}');
      print('Response headers: ${response.headers}');
      print('Response body: ${response.body}');
      
      if (response.statusCode >= 400) {
        print('Error response: ${response.body}');
        return {'error': 'Failed to send message', 'details': response.body};
      }
      
      return jsonDecode(response.body);
    } catch (e, stackTrace) {
      print('Exception during sendMessage: $e');
      print('Stack trace: $stackTrace');
      return {'error': 'Exception occurred: $e'};
    }
  }
  
  static Future<List<dynamic>> getUnreadMessages() async {
    try {
      print('\n===== API SERVICE: GETTING UNREAD MESSAGES =====');
      final headers = await _getAuthHeaders();
      final requestUrl = '$baseUrl/messages/unread';
      print('Request URL: ${Uri.parse(requestUrl)}');
      print('Request headers: $headers');
      
      final client = _getClient();
      final response = await client.get(
        Uri.parse(requestUrl),
        headers: headers,
      );
      client.close();
      
      print('Response status code: ${response.statusCode}');
      print('Response headers: ${response.headers}');
      print('Response body: ${response.body}');
      
      if (response.statusCode >= 400) {
        print('Error response: ${response.body}');
        return [];
      }
      
      return jsonDecode(response.body);
    } catch (e, stackTrace) {
      print('Exception during getUnreadMessages: $e');
      print('Stack trace: $stackTrace');
      return [];
    }
  }
}
