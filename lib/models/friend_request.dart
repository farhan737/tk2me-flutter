import 'package:tk2me_flutter/models/user.dart';

enum FriendRequestStatus { PENDING, ACCEPTED, REJECTED }

class FriendRequest {
  final int id;
  final User sender;
  final User receiver;
  final FriendRequestStatus status;
  final String createdAt;
  final String? updatedAt;

  FriendRequest({
    required this.id,
    required this.sender,
    required this.receiver,
    required this.status,
    required this.createdAt,
    this.updatedAt,
  });

  factory FriendRequest.fromJson(Map<String, dynamic> json) {
    return FriendRequest(
      id: json['id'],
      sender: User.fromJson(json['sender']),
      receiver: User.fromJson(json['receiver']),
      status: _parseStatus(json['status']),
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
    );
  }

  static FriendRequestStatus _parseStatus(String status) {
    switch (status) {
      case 'PENDING':
        return FriendRequestStatus.PENDING;
      case 'ACCEPTED':
        return FriendRequestStatus.ACCEPTED;
      case 'REJECTED':
        return FriendRequestStatus.REJECTED;
      default:
        return FriendRequestStatus.PENDING;
    }
  }
}
