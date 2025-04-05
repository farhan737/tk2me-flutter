import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tk2me_flutter/models/message.dart';
import 'package:tk2me_flutter/models/user.dart';
import 'package:tk2me_flutter/providers/auth_provider.dart';
import 'package:tk2me_flutter/providers/message_provider.dart';
import 'package:intl/intl.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late User _friend;
  bool _isFirstLoad = true;

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _sendMessage() async {
    final messageText = _messageController.text.trim();
    if (messageText.isEmpty) return;

    final messageProvider = Provider.of<MessageProvider>(context, listen: false);
    final success = await messageProvider.sendMessage(_friend.username, messageText);

    if (success) {
      _messageController.clear();
      // Scroll to the bottom to show the new message
      Future.delayed(const Duration(milliseconds: 100), _scrollToBottom);
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(messageProvider.error ?? 'Failed to send message'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final messageProvider = Provider.of<MessageProvider>(context);
    
    // Get the friend from the route arguments
    if (ModalRoute.of(context)!.settings.arguments != null) {
      _friend = ModalRoute.of(context)!.settings.arguments as User;
    }

    // Load the conversation when the screen is first built
    if (_isFirstLoad) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        messageProvider.loadConversation(_friend.username).then((_) {
          _scrollToBottom();
        });
      });
      _isFirstLoad = false;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_friend.username),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              messageProvider.loadConversation(_friend.username).then((_) {
                _scrollToBottom();
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Messages list
          Expanded(
            child: messageProvider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : messageProvider.messages.isEmpty
                    ? const Center(child: Text('No messages yet. Start a conversation!'))
                    : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(8.0),
                        itemCount: messageProvider.messages.length,
                        itemBuilder: (context, index) {
                          final message = messageProvider.messages[index];
                          final isMe = message.sender.id == authProvider.currentUser!.id;
                          final time = DateFormat('HH:mm').format(DateTime.parse(message.sentAt));

                          return Align(
                            alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                            child: Container(
                              margin: const EdgeInsets.symmetric(vertical: 4.0),
                              padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                              decoration: BoxDecoration(
                                color: isMe ? Colors.blue[100] : Colors.grey[300],
                                borderRadius: BorderRadius.circular(16.0),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    message.content,
                                    style: const TextStyle(fontSize: 16.0),
                                  ),
                                  const SizedBox(height: 4.0),
                                  Text(
                                    time,
                                    style: TextStyle(
                                      fontSize: 12.0,
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
          
          // Message input
          Container(
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 1,
                  blurRadius: 5,
                  offset: const Offset(0, -1),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      hintText: 'Type a message...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(24.0)),
                      ),
                      contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    ),
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8.0),
                FloatingActionButton(
                  onPressed: _sendMessage,
                  mini: true,
                  child: const Icon(Icons.send),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
