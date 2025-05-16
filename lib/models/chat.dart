import 'package:cloud_firestore/cloud_firestore.dart';

class Chat {
  final String id;
  final String productId;
  final String productName;
  final String productImageUrl;
  final String buyerId;
  final String sellerId;
  final String buyerName;
  final String sellerName;
  final DateTime lastMessageTime;
  final String lastMessage;
  final bool hasUnreadBuyer;
  final bool hasUnreadSeller;

  Chat({
    required this.id,
    required this.productId,
    required this.productName,
    required this.productImageUrl,
    required this.buyerId,
    required this.sellerId,
    required this.buyerName,
    required this.sellerName,
    required this.lastMessageTime,
    required this.lastMessage,
    required this.hasUnreadBuyer,
    required this.hasUnreadSeller,
  });

  // Create from Firebase Realtime Database snapshot
  factory Chat.fromRTDB(Map<String, dynamic> data, String id) {
    return Chat(
      id: id,
      productId: data['productId'] ?? '',
      productName: data['productName'] ?? '',
      productImageUrl: data['productImageUrl'] ?? '',
      buyerId: data['buyerId'] ?? '',
      sellerId: data['sellerId'] ?? '',
      buyerName: data['buyerName'] ?? '',
      sellerName: data['sellerName'] ?? '',
      lastMessageTime: data['lastMessageTime'] != null
          ? DateTime.fromMillisecondsSinceEpoch(data['lastMessageTime'])
          : DateTime.now(),
      lastMessage: data['lastMessage'] ?? '',
      hasUnreadBuyer: data['hasUnreadBuyer'] ?? false,
      hasUnreadSeller: data['hasUnreadSeller'] ?? false,
    );
  }

  // Convert to Firebase Realtime Database format
  Map<String, dynamic> toRTDB() {
    return {
      'productId': productId,
      'productName': productName,
      'productImageUrl': productImageUrl,
      'buyerId': buyerId,
      'sellerId': sellerId,
      'buyerName': buyerName,
      'sellerName': sellerName,
      'lastMessageTime': lastMessageTime.millisecondsSinceEpoch,
      'lastMessage': lastMessage,
      'hasUnreadBuyer': hasUnreadBuyer,
      'hasUnreadSeller': hasUnreadSeller,
    };
  }
}

class ChatMessage {
  final String id;
  final String chatId;
  final String senderId;
  final String text;
  final DateTime timestamp;
  final bool isRead;

  ChatMessage({
    required this.id,
    required this.chatId,
    required this.senderId,
    required this.text,
    required this.timestamp,
    required this.isRead,
  });

  // Create from Firebase Realtime Database snapshot
  factory ChatMessage.fromRTDB(Map<String, dynamic> data, String id) {
    return ChatMessage(
      id: id,
      chatId: data['chatId'] ?? '',
      senderId: data['senderId'] ?? '',
      text: data['text'] ?? '',
      timestamp: data['timestamp'] != null
          ? DateTime.fromMillisecondsSinceEpoch(data['timestamp'])
          : DateTime.now(),
      isRead: data['isRead'] ?? false,
    );
  }

  // Convert to Firebase Realtime Database format
  Map<String, dynamic> toRTDB() {
    return {
      'chatId': chatId,
      'senderId': senderId,
      'text': text,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'isRead': isRead,
    };
  }
}
