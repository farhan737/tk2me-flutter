import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tk2me_flutter/models/friend_request.dart';
import 'package:tk2me_flutter/models/user.dart';
import 'package:tk2me_flutter/providers/auth_provider.dart';
import 'package:tk2me_flutter/providers/connection_provider.dart';
import 'package:tk2me_flutter/providers/friend_provider.dart';
import 'package:tk2me_flutter/providers/message_provider.dart';
import 'package:tk2me_flutter/widgets/connection_indicator.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _usernameController = TextEditingController();
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    
    // Load friends and pending requests when the screen is first loaded
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshData();
    });
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    _usernameController.dispose();
    super.dispose();
  }
  
  Future<void> _refreshData() async {
    final friendProvider = Provider.of<FriendProvider>(context, listen: false);
    final messageProvider = Provider.of<MessageProvider>(context, listen: false);
    final connectionProvider = Provider.of<ConnectionProvider>(context, listen: false);
    
    // Check connection status first
    await connectionProvider.checkConnection();
    
    // Only try to load data if connected
    if (connectionProvider.isConnected) {
      await friendProvider.loadFriends();
      await friendProvider.loadPendingRequests();
      await messageProvider.loadUnreadMessages();
    } else {
      // Show a message if not connected
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Not connected to server. Check your connection.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
  
  void _showAddFriendDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Friend'),
        content: TextField(
          controller: _usernameController,
          decoration: const InputDecoration(
            labelText: 'Username',
            hintText: 'Enter username',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _usernameController.clear();
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final username = _usernameController.text.trim();
              if (username.isNotEmpty) {
                Navigator.of(context).pop();
                
                final friendProvider = Provider.of<FriendProvider>(context, listen: false);
                final success = await friendProvider.sendFriendRequest(username);
                
                if (!mounted) return;
                
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Friend request sent successfully'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(friendProvider.error ?? 'Failed to send friend request'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
                
                _usernameController.clear();
              }
            },
            child: const Text('Send Request'),
          ),
        ],
      ),
    );
  }
  
  void _navigateToChat(User friend) {
    final messageProvider = Provider.of<MessageProvider>(context, listen: false);
    messageProvider.setCurrentChatUser(friend.username);
    
    Navigator.of(context).pushNamed(
      '/chat',
      arguments: friend,
    );
  }
  
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final friendProvider = Provider.of<FriendProvider>(context);
    final messageProvider = Provider.of<MessageProvider>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Text('TK2ME Messenger'),
            const SizedBox(width: 10),
            const ConnectionIndicator(),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshData,
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await authProvider.logout();
              if (!mounted) return;
              Navigator.of(context).pushReplacementNamed('/login');
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Friends'),
            Tab(text: 'Requests'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Friends Tab
          RefreshIndicator(
            onRefresh: _refreshData,
            child: friendProvider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : friendProvider.friends.isEmpty
                    ? const Center(child: Text('No friends yet. Add some friends!'))
                    : ListView.builder(
                        itemCount: friendProvider.friends.length,
                        itemBuilder: (context, index) {
                          final friend = friendProvider.friends[index];
                          final unreadCount = messageProvider.getUnreadCountForUser(friend.username);
                          
                          return ListTile(
                            leading: CircleAvatar(
                              child: Text(friend.username.substring(0, 1).toUpperCase()),
                            ),
                            title: Text(friend.username),
                            trailing: unreadCount > 0
                                ? Badge(
                                    label: Text(unreadCount.toString()),
                                    child: const Icon(Icons.message),
                                  )
                                : const Icon(Icons.message),
                            onTap: () => _navigateToChat(friend),
                          );
                        },
                      ),
          ),
          
          // Requests Tab
          RefreshIndicator(
            onRefresh: _refreshData,
            child: friendProvider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : friendProvider.pendingRequests.isEmpty
                    ? const Center(child: Text('No pending friend requests'))
                    : ListView.builder(
                        itemCount: friendProvider.pendingRequests.length,
                        itemBuilder: (context, index) {
                          final request = friendProvider.pendingRequests[index];
                          
                          return ListTile(
                            leading: CircleAvatar(
                              child: Text(request.sender.username.substring(0, 1).toUpperCase()),
                            ),
                            title: Text(request.sender.username),
                            subtitle: const Text('Wants to be your friend'),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.check, color: Colors.green),
                                  onPressed: () async {
                                    final success = await friendProvider.acceptFriendRequest(request.id);
                                    
                                    if (!mounted) return;
                                    
                                    if (success) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('Friend request accepted'),
                                          backgroundColor: Colors.green,
                                        ),
                                      );
                                    } else {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text(friendProvider.error ?? 'Failed to accept request'),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                    }
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.close, color: Colors.red),
                                  onPressed: () async {
                                    final success = await friendProvider.rejectFriendRequest(request.id);
                                    
                                    if (!mounted) return;
                                    
                                    if (success) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('Friend request rejected'),
                                          backgroundColor: Colors.orange,
                                        ),
                                      );
                                    } else {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text(friendProvider.error ?? 'Failed to reject request'),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                    }
                                  },
                                ),
                              ],
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddFriendDialog,
        child: const Icon(Icons.person_add),
      ),
    );
  }
}
