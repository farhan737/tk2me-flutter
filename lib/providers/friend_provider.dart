import 'package:flutter/material.dart';
import 'package:tk2me_flutter/models/user.dart';
import 'package:tk2me_flutter/models/friend_request.dart';
import 'package:tk2me_flutter/services/api_service.dart';

class FriendProvider with ChangeNotifier {
  List<User> _friends = [];
  List<FriendRequest> _pendingRequests = [];
  bool _isLoading = false;
  String? _error;

  List<User> get friends => _friends;
  List<FriendRequest> get pendingRequests => _pendingRequests;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadFriends() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await ApiService.getFriends();
      _friends = response.map((data) => User.fromJson(data)).toList();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadPendingRequests() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await ApiService.getPendingRequests();
      _pendingRequests = response.map((data) => FriendRequest.fromJson(data)).toList();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> sendFriendRequest(String username) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await ApiService.sendFriendRequest(username);
      
      if (response.containsKey('message') && 
          response['message'].contains('Friend request sent successfully')) {
        await loadFriends(); // Refresh friends list in case auto-accept happened
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = response['message'] ?? 'Failed to send friend request';
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

  Future<bool> acceptFriendRequest(int requestId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await ApiService.acceptFriendRequest(requestId);
      
      if (response.containsKey('message') && 
          response['message'].contains('accepted successfully')) {
        // Remove the request from pending list
        _pendingRequests.removeWhere((request) => request.id == requestId);
        
        // Refresh friends list
        await loadFriends();
        
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = response['message'] ?? 'Failed to accept friend request';
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

  Future<bool> rejectFriendRequest(int requestId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await ApiService.rejectFriendRequest(requestId);
      
      if (response.containsKey('message') && 
          response['message'].contains('rejected successfully')) {
        // Remove the request from pending list
        _pendingRequests.removeWhere((request) => request.id == requestId);
        
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = response['message'] ?? 'Failed to reject friend request';
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
}
