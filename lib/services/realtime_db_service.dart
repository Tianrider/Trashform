import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import '../models/chat.dart';
import '../models/marketplace_item.dart';
import 'package:flutter/material.dart';

class RealtimeDBService {
  final FirebaseDatabase _database = FirebaseDatabase.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Initialize Firebase Realtime Database with the provided URL
  RealtimeDBService() {
    _database.databaseURL =
        'https://trashform-72d5f-default-rtdb.asia-southeast1.firebasedatabase.app/';
  }

  // Get the current authenticated user ID
  String? get currentUserId => _auth.currentUser?.uid;

  // Create a new chat between buyer and seller
  Future<String?> createChat(MarketplaceItem product, String buyerName) async {
    try {
      if (currentUserId == null) return null;

      // Reference to the chats node
      final chatsRef = _database.reference().child('chats');

      // Check if chat already exists for this product and buyer
      DataSnapshot existingChats =
          await chatsRef.orderByChild('productId').equalTo(product.id).get();

      // Convert to Map
      Map<dynamic, dynamic>? chatsMap =
          existingChats.value as Map<dynamic, dynamic>?;

      if (chatsMap != null) {
        // Check each chat to see if it involves this buyer and seller
        String? existingChatId;
        chatsMap.forEach((key, value) {
          if (value['buyerId'] == currentUserId &&
              value['sellerId'] == product.userId) {
            existingChatId = key;
          }
        });

        // If chat exists, return its ID
        if (existingChatId != null) {
          return existingChatId;
        }
      }

      // Create a new chat entry
      final newChatRef = chatsRef.push();
      final chat = Chat(
        id: newChatRef.key ?? '',
        productId: product.id,
        productName: product.name,
        productImageUrl: product.imageUrl,
        buyerId: currentUserId!,
        sellerId: product.userId,
        buyerName: buyerName,
        sellerName: product.userName,
        lastMessageTime: DateTime.now(),
        lastMessage: "Let's talk about this item!",
        hasUnreadBuyer: false,
        hasUnreadSeller: true,
      );

      // Save the chat data
      await newChatRef.set(chat.toRTDB());

      // Add initial message
      final messagesRef =
          _database.reference().child('messages').child(newChatRef.key!);
      final newMessageRef = messagesRef.push();

      final initialMessage = ChatMessage(
        id: newMessageRef.key ?? '',
        chatId: newChatRef.key ?? '',
        senderId: currentUserId!,
        text: "Hi, I'm interested in your ${product.name}!",
        timestamp: DateTime.now(),
        isRead: false,
      );

      await newMessageRef.set(initialMessage.toRTDB());

      return newChatRef.key;
    } catch (e) {
      debugPrint('Error creating chat: $e');
      return null;
    }
  }

  // Get all chats for the current user (as buyer or seller)
  Stream<List<Chat>> getUserChats() {
    if (currentUserId == null) {
      return Stream.value([]);
    }

    return _database
        .reference()
        .child('chats')
        .orderByChild('lastMessageTime')
        .onValue
        .map((event) {
      final chatMap = event.snapshot.value as Map<dynamic, dynamic>?;

      if (chatMap == null) {
        return <Chat>[];
      }

      List<Chat> chats = [];

      chatMap.forEach((key, value) {
        // Only include chats where the current user is the buyer or seller
        if (value['buyerId'] == currentUserId ||
            value['sellerId'] == currentUserId) {
          chats.add(Chat.fromRTDB(Map<String, dynamic>.from(value), key));
        }
      });

      // Sort by last message time (most recent first)
      chats.sort((a, b) => b.lastMessageTime.compareTo(a.lastMessageTime));

      return chats;
    });
  }

  // Get messages for a specific chat
  Stream<List<ChatMessage>> getChatMessages(String chatId) {
    return _database
        .reference()
        .child('messages')
        .child(chatId)
        .orderByChild('timestamp')
        .onValue
        .map((event) {
      final messagesMap = event.snapshot.value as Map<dynamic, dynamic>?;

      if (messagesMap == null) {
        return <ChatMessage>[];
      }

      List<ChatMessage> messages = [];

      messagesMap.forEach((key, value) {
        messages
            .add(ChatMessage.fromRTDB(Map<String, dynamic>.from(value), key));
      });

      // Sort by timestamp (oldest first)
      messages.sort((a, b) => a.timestamp.compareTo(b.timestamp));

      return messages;
    });
  }

  // Send a new message in a chat
  Future<bool> sendMessage(String chatId, String text) async {
    try {
      if (currentUserId == null) return false;

      // Get the chat details
      final chatSnapshot =
          await _database.reference().child('chats').child(chatId).get();
      final chatData = chatSnapshot.value as Map<dynamic, dynamic>?;

      if (chatData == null) return false;

      // Create new message reference
      final messagesRef = _database.reference().child('messages').child(chatId);
      final newMessageRef = messagesRef.push();

      // Create message
      final message = ChatMessage(
        id: newMessageRef.key ?? '',
        chatId: chatId,
        senderId: currentUserId!,
        text: text,
        timestamp: DateTime.now(),
        isRead: false,
      );

      // Save message
      await newMessageRef.set(message.toRTDB());

      // Update chat with last message details
      Map<String, dynamic> chatUpdateData = {
        'lastMessage': text,
        'lastMessageTime': DateTime.now().millisecondsSinceEpoch,
      };

      // Mark as unread for the recipient
      if (currentUserId == chatData['buyerId']) {
        chatUpdateData['hasUnreadSeller'] = true;
        chatUpdateData['hasUnreadBuyer'] = false;
      } else {
        chatUpdateData['hasUnreadBuyer'] = true;
        chatUpdateData['hasUnreadSeller'] = false;
      }

      await _database
          .reference()
          .child('chats')
          .child(chatId)
          .update(chatUpdateData);

      return true;
    } catch (e) {
      debugPrint('Error sending message: $e');
      return false;
    }
  }

  // Mark all messages in a chat as read for the current user
  Future<void> markChatAsRead(String chatId) async {
    try {
      if (currentUserId == null) return;

      // Get the chat details
      final chatSnapshot =
          await _database.reference().child('chats').child(chatId).get();
      final chatData = chatSnapshot.value as Map<dynamic, dynamic>?;

      if (chatData == null) return;

      // Determine if user is buyer or seller
      final isBuyer = currentUserId == chatData['buyerId'];

      // Update the appropriate unread flag
      if (isBuyer) {
        await _database
            .reference()
            .child('chats')
            .child(chatId)
            .update({'hasUnreadBuyer': false});
      } else {
        await _database
            .reference()
            .child('chats')
            .child(chatId)
            .update({'hasUnreadSeller': false});
      }

      // Mark all messages from the other user as read
      final messagesSnapshot = await _database
          .reference()
          .child('messages')
          .child(chatId)
          .orderByChild('isRead')
          .equalTo(false)
          .get();

      final messagesData = messagesSnapshot.value as Map<dynamic, dynamic>?;

      if (messagesData != null) {
        final otherUserId =
            isBuyer ? chatData['sellerId'] : chatData['buyerId'];

        messagesData.forEach((key, value) {
          if (value['senderId'] == otherUserId) {
            _database
                .reference()
                .child('messages')
                .child(chatId)
                .child(key)
                .update({'isRead': true});
          }
        });
      }
    } catch (e) {
      debugPrint('Error marking chat as read: $e');
    }
  }

  // Get count of unread chats for the current user
  Stream<int> getUnreadChatsCount() {
    if (currentUserId == null) {
      return Stream.value(0);
    }

    return _database.reference().child('chats').onValue.map((event) {
      final chatMap = event.snapshot.value as Map<dynamic, dynamic>?;

      if (chatMap == null) {
        return 0;
      }

      int unreadCount = 0;

      chatMap.forEach((key, value) {
        // Check if user is buyer or seller and has unread messages
        if (value['buyerId'] == currentUserId &&
            value['hasUnreadBuyer'] == true) {
          unreadCount++;
        } else if (value['sellerId'] == currentUserId &&
            value['hasUnreadSeller'] == true) {
          unreadCount++;
        }
      });

      return unreadCount;
    });
  }
}
