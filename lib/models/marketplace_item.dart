import 'package:cloud_firestore/cloud_firestore.dart';

class MarketplaceItem {
  final String id;
  final String projectId;
  final String name;
  final String description;
  final double price;
  final String userId;
  final String userName;
  final String imageUrl;
  final List<String> additionalImages;
  final DateTime listedDate;
  final String category;
  final bool isSold;

  MarketplaceItem({
    required this.id,
    required this.projectId,
    required this.name,
    required this.description,
    required this.price,
    required this.userId,
    required this.userName,
    required this.imageUrl,
    required this.additionalImages,
    required this.listedDate,
    required this.category,
    this.isSold = false,
  });

  // Create from Firestore document
  factory MarketplaceItem.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    return MarketplaceItem(
      id: doc.id,
      projectId: data['projectId'] ?? '',
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      price: (data['price'] ?? 0).toDouble(),
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      additionalImages: List<String>.from(data['additionalImages'] ?? []),
      listedDate:
          (data['listedDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      category: data['category'] ?? 'Other',
      isSold: data['isSold'] ?? false,
    );
  }

  // Convert to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'projectId': projectId,
      'name': name,
      'description': description,
      'price': price,
      'userId': userId,
      'userName': userName,
      'imageUrl': imageUrl,
      'additionalImages': additionalImages,
      'listedDate': Timestamp.fromDate(listedDate),
      'category': category,
      'isSold': isSold,
    };
  }
}
