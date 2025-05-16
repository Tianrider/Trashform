import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/chat.dart';
import '../services/realtime_db_service.dart';
import 'chat_screen.dart';
import 'onboarding_screen.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  final RealtimeDBService _realtimeDBService = RealtimeDBService();

  String? get _currentUserId => FirebaseAuth.instance.currentUser?.uid;

  @override
  void initState() {
    super.initState();
    // Check authentication when screen loads
    _checkAuthentication();
  }

  // Check if user is logged in, redirect if not
  void _checkAuthentication() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      // Delayed navigation to avoid calling during build
      Future.microtask(() {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const OnboardingScreen()),
          (route) => false,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Check authentication on each build
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      // Show loading while we redirect
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF377047),
        title: const Text(
          'Messages',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
        elevation: 0,
      ),
      body: StreamBuilder<List<Chat>>(
        stream: _realtimeDBService.getUserChats(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          final chats = snapshot.data ?? [];

          if (chats.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.chat_bubble_outline,
                    size: 64,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No messages yet',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Start a conversation by contacting a seller',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: chats.length,
            itemBuilder: (context, index) {
              final chat = chats[index];

              // Determine if current user is buyer or seller
              final isBuyer = _currentUserId == chat.buyerId;

              // Determine if there are unread messages for the current user
              final hasUnread =
                  isBuyer ? chat.hasUnreadBuyer : chat.hasUnreadSeller;

              // Get the name of the other user (buyer or seller)
              final otherUserName = isBuyer ? chat.sellerName : chat.buyerName;

              return ChatListItem(
                chat: chat,
                otherUserName: otherUserName,
                hasUnread: hasUnread,
                onTap: () {
                  // Mark as read when opening the chat
                  _realtimeDBService.markChatAsRead(chat.id);

                  // Navigate to chat screen
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChatScreen(
                        chatId: chat.id,
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

class ChatListItem extends StatelessWidget {
  final Chat chat;
  final String otherUserName;
  final bool hasUnread;
  final VoidCallback onTap;

  const ChatListItem({
    super.key,
    required this.chat,
    required this.otherUserName,
    required this.hasUnread,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: hasUnread ? Colors.green.shade50 : Colors.white,
          border: Border(
            bottom: BorderSide(
              color: Colors.grey.shade200,
              width: 1,
            ),
          ),
        ),
        child: Row(
          children: [
            // User avatar or product image
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(28),
                image: chat.productImageUrl.isNotEmpty
                    ? DecorationImage(
                        image: NetworkImage(chat.productImageUrl),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: chat.productImageUrl.isEmpty
                  ? Center(
                      child: Text(
                        otherUserName.isNotEmpty
                            ? otherUserName[0].toUpperCase()
                            : '?',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                    )
                  : null,
            ),

            const SizedBox(width: 12),

            // Chat details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Chat name and time
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Other user's name
                      Text(
                        otherUserName,
                        style: TextStyle(
                          fontWeight:
                              hasUnread ? FontWeight.bold : FontWeight.normal,
                          fontSize: 16,
                        ),
                      ),

                      // Last message time
                      Text(
                        _getTimeAgo(chat.lastMessageTime),
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 4),

                  // Product name
                  if (chat.productName.isNotEmpty)
                    Text(
                      'About: ${chat.productName}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),

                  const SizedBox(height: 2),

                  // Last message
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          chat.lastMessage,
                          style: TextStyle(
                            color:
                                hasUnread ? Colors.black87 : Colors.grey[600],
                            fontWeight:
                                hasUnread ? FontWeight.w500 : FontWeight.normal,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),

                      // Unread indicator
                      if (hasUnread)
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Color(0xFF377047),
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getTimeAgo(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inDays > 7) {
      // Format as date if more than a week ago
      return '${time.day}/${time.month}/${time.year}';
    } else if (difference.inDays > 0) {
      // Days ago
      return difference.inDays == 1 ? 'Yesterday' : '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      // Hours ago
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      // Minutes ago
      return '${difference.inMinutes}m ago';
    } else {
      // Just now
      return 'Just now';
    }
  }
}
