import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import '../models/completed_project.dart';
import '../models/recommendation.dart';
import '../models/marketplace_item.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Collection references
  CollectionReference get _completedProjects =>
      _firestore.collection('completedProjects');
  CollectionReference get _users => _firestore.collection('users');
  CollectionReference get _marketplaceItems =>
      _firestore.collection('marketplaceItems');

  // Get current user ID
  String? get currentUserId => _auth.currentUser?.uid;

  // Get current user name
  Future<String> getCurrentUserName() async {
    try {
      if (currentUserId == null) {
        return 'Anonymous User';
      }

      DocumentSnapshot userDoc = await _users.doc(currentUserId).get();
      if (userDoc.exists) {
        Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
        return userData['displayName'] ?? 'User';
      }
      return 'User';
    } catch (e) {
      print('Error getting user name: $e');
      return 'User';
    }
  }

  // Save a completed project to Firestore
  Future<String> saveCompletedProject(
      Recommendation recommendation, double co2Saved, int xpEarned) async {
    try {
      // Default user ID if not authenticated
      String userId = currentUserId ?? 'anonymous';

      // Create completed project from recommendation
      final completedProject = {
        'name': recommendation.name,
        'description': recommendation.description,
        'mainImageUrl': 'https://picsum.photos/400/200', // Dummy image URL
        'stepImages': List.generate(
            recommendation.stepByStep.length,
            (index) =>
                'https://picsum.photos/400/200?random=$index'), // Dummy step images
        'steps': recommendation.stepByStep,
        'co2Saved': co2Saved,
        'xpEarned': xpEarned,
        'userId': userId,
        'completedDate': Timestamp.now(),
        'materialsUsed': recommendation.materials,
      };

      // Add to Firestore
      DocumentReference docRef = await _completedProjects.add(completedProject);

      // Update user stats
      await _updateUserStats(userId, co2Saved, xpEarned);

      return docRef.id;
    } catch (e) {
      print('Error saving completed project: $e');
      return '';
    }
  }

  // Get all completed projects for current user
  Stream<List<CompletedProject>> getUserCompletedProjects() {
    String userId = currentUserId ?? 'anonymous';

    return _completedProjects
        .where('userId', isEqualTo: userId)
        .orderBy('completedDate', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => CompletedProject.fromFirestore(doc))
          .toList();
    });
  }

  // Get all completed projects from all users for the community feed
  Stream<List<CompletedProject>> getAllCompletedProjects() {
    return _completedProjects
        .orderBy('completedDate', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => CompletedProject.fromFirestore(doc))
          .toList();
    });
  }

  // Search completed projects by name or description
  Stream<List<CompletedProject>> searchCompletedProjects(String query) {
    // Convert query to lowercase for case-insensitive search
    final String searchQuery = query.toLowerCase();

    return _completedProjects
        .orderBy('completedDate', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => CompletedProject.fromFirestore(doc))
          .where((project) =>
              project.name.toLowerCase().contains(searchQuery) ||
              project.description.toLowerCase().contains(searchQuery))
          .toList();
    });
  }

  // Get the total CO2 saved for the monthly challenge
  Future<double> getTotalCO2Saved() async {
    try {
      QuerySnapshot snapshot = await _completedProjects.get();

      double totalCO2 = 0.0;
      for (var doc in snapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        totalCO2 += (data['co2Saved'] ?? 0.0);
      }

      return totalCO2;
    } catch (e) {
      print('Error getting total CO2 saved: $e');
      return 0.0;
    }
  }

  // Get a single completed project by ID
  Future<CompletedProject?> getCompletedProject(String projectId) async {
    try {
      DocumentSnapshot doc = await _completedProjects.doc(projectId).get();
      if (doc.exists) {
        return CompletedProject.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      print('Error getting completed project: $e');
      return null;
    }
  }

  // Update user statistics when a project is completed
  Future<void> _updateUserStats(
      String userId, double co2Saved, int xpEarned) async {
    try {
      // Get user document reference
      DocumentReference userRef = _users.doc(userId);

      // Check if user document exists
      DocumentSnapshot userDoc = await userRef.get();

      if (userDoc.exists) {
        // Update existing user document
        await userRef.update({
          'totalCO2Saved': FieldValue.increment(co2Saved),
          'totalXP': FieldValue.increment(xpEarned),
          'completedProjects': FieldValue.increment(1),
          'lastCompletedDate': Timestamp.now(),
        });
      } else {
        // Create new user document
        await userRef.set({
          'userId': userId,
          'displayName': 'eco_maker23', // Default username
          'totalCO2Saved': co2Saved,
          'totalXP': xpEarned,
          'completedProjects': 1,
          'lastCompletedDate': Timestamp.now(),
          'createdDate': Timestamp.now(),
        });
      }
    } catch (e) {
      print('Error updating user stats: $e');
    }
  }

  // Get total user statistics
  Future<Map<String, dynamic>> getUserStats() async {
    try {
      String userId = currentUserId ?? 'anonymous';
      DocumentSnapshot userDoc = await _users.doc(userId).get();

      if (userDoc.exists) {
        Map<String, dynamic> data = userDoc.data() as Map<String, dynamic>;
        return {
          'totalCO2Saved': data['totalCO2Saved'] ?? 0.0,
          'totalXP': data['totalXP'] ?? 0,
          'completedProjects': data['completedProjects'] ?? 0,
        };
      }

      return {
        'totalCO2Saved': 0.0,
        'totalXP': 0,
        'completedProjects': 0,
      };
    } catch (e) {
      print('Error getting user stats: $e');
      return {
        'totalCO2Saved': 0.0,
        'totalXP': 0,
        'completedProjects': 0,
      };
    }
  }

  // MARKETPLACE METHODS

  // Add a marketplace listing
  Future<String> addMarketplaceListing({
    required String projectId,
    required String name,
    required String description,
    required double price,
    required File imageFile,
    required List<File> additionalImageFiles,
    required String category,
  }) async {
    try {
      print("DEBUG: Starting addMarketplaceListing in FirestoreService");

      // Check Firebase Storage connectivity
      bool storageAvailable = await _checkFirebaseStorage();
      if (!storageAvailable) {
        print("DEBUG: Firebase Storage is not available");
        return '';
      }

      // Default user ID if not authenticated
      String userId = currentUserId ?? 'anonymous';
      print("DEBUG: User ID: $userId");

      String userName = await getCurrentUserName();
      print("DEBUG: User name: $userName");

      // Upload main image
      print("DEBUG: Uploading main image: ${imageFile.path}");
      String imageUrl = await _uploadImage(imageFile,
          'marketplace/$userId/${DateTime.now().millisecondsSinceEpoch}');

      // Check if image upload was successful
      if (imageUrl.isEmpty) {
        print("DEBUG: Main image upload failed");
        return '';
      }

      print("DEBUG: Main image URL: $imageUrl");

      // Upload additional images
      List<String> additionalImages = [];
      print(
          "DEBUG: Starting upload of ${additionalImageFiles.length} additional images");
      for (var file in additionalImageFiles) {
        print("DEBUG: Uploading additional image: ${file.path}");
        String url = await _uploadImage(file,
            'marketplace/$userId/${DateTime.now().millisecondsSinceEpoch}_${additionalImages.length + 1}');
        if (url.isNotEmpty) {
          print("DEBUG: Additional image URL: $url");
          additionalImages.add(url);
        } else {
          print("DEBUG: Additional image upload failed, skipping");
        }
      }

      // Create marketplace item
      print("DEBUG: Creating marketplace item document");
      final marketplaceItem = {
        'projectId': projectId,
        'name': name,
        'description': description,
        'price': price,
        'userId': userId,
        'userName': userName,
        'imageUrl': imageUrl,
        'additionalImages': additionalImages,
        'listedDate': Timestamp.now(),
        'category': category,
        'isSold': false,
      };

      // Add to Firestore
      print("DEBUG: Adding to Firestore collection '_marketplaceItems'");
      DocumentReference docRef = await _marketplaceItems.add(marketplaceItem);
      print("DEBUG: Document added with ID: ${docRef.id}");
      return docRef.id;
    } catch (e) {
      print('DEBUG: Error in addMarketplaceListing: $e');
      if (e is FirebaseException) {
        print('DEBUG: Firebase error code: ${e.code}');
        print('DEBUG: Firebase error message: ${e.message}');
      }
      return '';
    }
  }

  // Check if Firebase Storage is properly configured and accessible
  Future<bool> _checkFirebaseStorage() async {
    try {
      print("DEBUG: Checking Firebase Storage connectivity");

      // Try to access the root reference
      Reference rootRef = _storage.ref();
      print("DEBUG: Root reference created: ${rootRef.fullPath}");

      // Try to list items (limited to 1) in the root to verify access
      try {
        print("DEBUG: Attempting to list items in storage root");
        ListResult result =
            await rootRef.list(const ListOptions(maxResults: 1));
        print(
            "DEBUG: Storage listing successful, found ${result.items.length} items");
        return true;
      } on FirebaseException catch (e) {
        print(
            "DEBUG: Firebase error during storage listing - Code: ${e.code}, Message: ${e.message}");

        if (e.code == 'unauthorized') {
          print(
              "DEBUG: Firebase Storage permission denied. Check your Firebase Storage rules.");
        }

        return false;
      }
    } catch (e) {
      print("DEBUG: Error checking Firebase Storage: $e");
      return false;
    }
  }

  // Upload image to Firebase Storage
  Future<String> _uploadImage(File imageFile, String path) async {
    try {
      print("DEBUG: Starting _uploadImage method");

      // Verify file exists
      if (!imageFile.existsSync()) {
        print(
            "DEBUG: Error - Image file doesn't exist at path: ${imageFile.path}");
        return '';
      }

      print("DEBUG: Image file exists: ${imageFile.existsSync()}");

      // Check file size (Firebase has a 5MB limit for client SDK uploads)
      final fileSize = await imageFile.length();
      print("DEBUG: Image file size: $fileSize bytes");

      if (fileSize > 5 * 1024 * 1024) {
        print("DEBUG: Error - File size exceeds 5MB limit: $fileSize bytes");
        return '';
      }

      print("DEBUG: Upload path: $path");

      // Create storage reference
      Reference ref = _storage.ref().child(path);
      print("DEBUG: Storage reference created");

      // Create upload metadata to specify content type
      SettableMetadata metadata = SettableMetadata(
        contentType: 'image/jpeg',
        customMetadata: {'path': path},
      );

      // Upload image with metadata
      print("DEBUG: Starting file upload with metadata");
      try {
        TaskSnapshot uploadTask = await ref.putFile(imageFile, metadata);
        print(
            "DEBUG: Upload complete. Bytes transferred: ${uploadTask.bytesTransferred}");

        // Get download URL
        String downloadUrl = await ref.getDownloadURL();
        print("DEBUG: Download URL retrieved: $downloadUrl");
        return downloadUrl;
      } on FirebaseException catch (e) {
        print(
            "DEBUG: Firebase error during upload - Code: ${e.code}, Message: ${e.message}");

        // Handle specific Firebase Storage errors
        if (e.code == 'unauthorized') {
          print(
              "DEBUG: Firebase Storage permission denied. Check your Firebase Storage rules.");
        } else if (e.code == 'object-not-found') {
          print("DEBUG: Firebase Storage path not found: $path");
        } else if (e.code == 'canceled') {
          print("DEBUG: Upload was canceled");
        }

        return '';
      }
    } catch (e) {
      print('DEBUG: Error in _uploadImage: $e');
      if (e is FirebaseException) {
        print('DEBUG: Firebase error code: ${e.code}');
        print('DEBUG: Firebase error message: ${e.message}');
      }
      return '';
    }
  }

  // Get all marketplace items
  Stream<List<MarketplaceItem>> getAllMarketplaceItems() {
    return _marketplaceItems
        .where('isSold', isEqualTo: false)
        .orderBy('listedDate', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => MarketplaceItem.fromFirestore(doc))
          .toList();
    });
  }

  // Get marketplace items by category
  Stream<List<MarketplaceItem>> getMarketplaceItemsByCategory(String category) {
    if (category == 'All') {
      return getAllMarketplaceItems();
    }

    return _marketplaceItems
        .where('category', isEqualTo: category)
        .where('isSold', isEqualTo: false)
        .orderBy('listedDate', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => MarketplaceItem.fromFirestore(doc))
          .toList();
    });
  }

  // Search marketplace items
  Stream<List<MarketplaceItem>> searchMarketplaceItems(String query) {
    final String searchQuery = query.toLowerCase();

    return _marketplaceItems
        .where('isSold', isEqualTo: false)
        .orderBy('listedDate', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => MarketplaceItem.fromFirestore(doc))
          .where((item) =>
              item.name.toLowerCase().contains(searchQuery) ||
              item.description.toLowerCase().contains(searchQuery))
          .toList();
    });
  }

  // Get marketplace items by current user
  Stream<List<MarketplaceItem>> getUserMarketplaceItems() {
    String userId = currentUserId ?? 'anonymous';

    return _marketplaceItems
        .where('userId', isEqualTo: userId)
        .orderBy('listedDate', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => MarketplaceItem.fromFirestore(doc))
          .toList();
    });
  }

  // Mark marketplace item as sold/unsold
  Future<void> updateMarketplaceItemStatus(String itemId, bool isSold) async {
    try {
      await _marketplaceItems.doc(itemId).update({'isSold': isSold});
    } catch (e) {
      print('Error updating marketplace item status: $e');
    }
  }
}
