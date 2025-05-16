import 'package:flutter/material.dart';
import '../models/marketplace_item.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/realtime_db_service.dart';
import 'chat_screen.dart';
import 'onboarding_screen.dart';

class ProductDetailsScreen extends StatefulWidget {
  final MarketplaceItem item;

  const ProductDetailsScreen({super.key, required this.item});

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
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

    // Check if current user is the seller
    final bool isCurrentUserSeller = user.uid == widget.item.userId;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF377047),
        title: const Text(
          'Product Details',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Main product image
                  SizedBox(
                    width: double.infinity,
                    height: 300,
                    child: Image.network(
                      widget.item.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 300,
                          width: double.infinity,
                          color: Colors.grey[300],
                          child: const Icon(Icons.image_not_supported,
                              color: Colors.white, size: 50),
                        );
                      },
                    ),
                  ),

                  // Additional images if available (horizontal scroll)
                  if (widget.item.additionalImages.isNotEmpty)
                    SizedBox(
                      height: 80,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.all(8),
                        itemCount: widget.item.additionalImages.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: Container(
                              width: 80,
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey.shade300),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  widget.item.additionalImages[index],
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      color: Colors.grey[300],
                                      child: const Icon(
                                          Icons.image_not_supported,
                                          color: Colors.white),
                                    );
                                  },
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                  // Product info
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Name and price row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                widget.item.name,
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Text(
                              '\$${widget.item.price.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF377047),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 8),

                        // Category badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEDF7ED),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            widget.item.category,
                            style: const TextStyle(
                              color: Color(0xFF377047),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Seller info
                        Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: const Color(0xFF377047),
                              radius: 20,
                              child: Text(
                                widget.item.userName.isNotEmpty
                                    ? widget.item.userName[0].toUpperCase()
                                    : '?',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Listed by',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 12,
                                  ),
                                ),
                                Text(
                                  '@${widget.item.userName}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                            const Spacer(),
                            Text(
                              'Listed ${_getTimeAgo(widget.item.listedDate)}',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),

                        // Description
                        const Text(
                          'Description',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          widget.item.description,
                          style: TextStyle(
                            color: Colors.grey[800],
                            height: 1.5,
                          ),
                        ),

                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Chat with seller button - disabled if current user is the seller
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  offset: const Offset(0, -2),
                  blurRadius: 8,
                ),
              ],
            ),
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: isCurrentUserSeller
                    ? null // Disable button if user is the seller
                    : () async {
                        // Show loading indicator
                        final scaffoldMessenger = ScaffoldMessenger.of(context);
                        scaffoldMessenger.showSnackBar(
                          const SnackBar(
                            content: Text('Opening chat with seller...'),
                            duration: Duration(seconds: 2),
                          ),
                        );

                        // Get current user's display name
                        final User? currentUser =
                            FirebaseAuth.instance.currentUser;
                        String buyerName = 'User';
                        if (currentUser != null &&
                            currentUser.displayName != null) {
                          buyerName = currentUser.displayName!;
                        } else if (currentUser != null &&
                            currentUser.email != null) {
                          // Use email as fallback
                          buyerName = currentUser.email!.split('@')[0];
                        }

                        // Create or get existing chat
                        final realtimeDBService = RealtimeDBService();
                        final chatId = await realtimeDBService.createChat(
                          widget.item,
                          buyerName,
                        );

                        // Check if creation was successful
                        if (chatId != null && context.mounted) {
                          // Navigate to chat screen
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ChatScreen(
                                chatId: chatId,
                                product: widget.item,
                              ),
                            ),
                          );
                        } else if (context.mounted) {
                          // Show error if chat creation failed
                          scaffoldMessenger.showSnackBar(
                            const SnackBar(
                              content: Text(
                                  'Failed to start chat. Please try again.'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF377047),
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: Colors.grey.shade300,
                  disabledForegroundColor: Colors.grey.shade600,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                ),
                child: Text(
                  isCurrentUserSeller ? 'Your Own Listing' : 'Chat with Seller',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getTimeAgo(DateTime dateTime) {
    final difference = DateTime.now().difference(dateTime);

    if (difference.inDays > 30) {
      final months = (difference.inDays / 30).floor();
      return months == 1 ? '1 month ago' : '$months months ago';
    } else if (difference.inDays > 0) {
      return difference.inDays == 1
          ? '1 day ago'
          : '${difference.inDays} days ago';
    } else if (difference.inHours > 0) {
      return difference.inHours == 1
          ? '1 hour ago'
          : '${difference.inHours} hours ago';
    } else if (difference.inMinutes > 0) {
      return difference.inMinutes == 1
          ? '1 minute ago'
          : '${difference.inMinutes} minutes ago';
    } else {
      return 'just now';
    }
  }
}
