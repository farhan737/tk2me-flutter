import 'package:tk2me_flutter/models/user.dart';

class Message {
  final int id;
  final User sender;
  final User receiver;
  final String content;
  final bool read;
  final String sentAt;

  Message({
    required this.id,
    required this.sender,
    required this.receiver,
    required this.content,
    required this.read,
    required this.sentAt,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'],
      sender: User.fromJson(json['sender']),
      receiver: User.fromJson(json['receiver']),
      content: json['content'],
      read: json['read'],
      sentAt: json['sentAt'],
    );
  }
}
