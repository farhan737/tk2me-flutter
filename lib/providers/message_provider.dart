import 'package:flutter/material.dart';
import 'package:tk2me_flutter/models/message.dart';
import 'package:tk2me_flutter/services/api_service.dart';

class MessageProvider with ChangeNotifier {
  List<Message> _messages = [];
  List<Message> _unreadMessages = [];
  bool _isLoading = false;
  String? _error;
  String? _currentChatUser;

  List<Message> get messages => _messages;
  List<Message> get unreadMessages => _unreadMessages;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get currentChatUser => _currentChatUser;

  void setCurrentChatUser(String username) {
    _currentChatUser = username;
    notifyListeners();
  }

  Future<void> loadConversation(String username) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await ApiService.getConversation(username);
      _messages = response.map((data) => Message.fromJson(data)).toList();
      _currentChatUser = username;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> sendMessage(String username, String content) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await ApiService.sendMessage(username, content);
      
      if (response.containsKey('id')) {
        // Add the new message to the conversation
        final newMessage = Message.fromJson(response);
        _messages.add(newMessage);
        
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = response['message'] ?? 'Failed to send message';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> loadUnreadMessages() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await ApiService.getUnreadMessages();
      _unreadMessages = response.map((data) => Message.fromJson(data)).toList();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Get unread message count for a specific user
  int getUnreadCountForUser(String username) {
    return _unreadMessages.where((message) => 
      message.sender.username == username).length;
  }
}
