import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/completed_project.dart';
import '../models/recommendation.dart';
import '../services/firestore_service.dart';
import '../services/realtime_db_service.dart';
import 'scan_screen.dart';
import 'chat_list_screen.dart';
import 'onboarding_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final RealtimeDBService _realtimeDBService = RealtimeDBService();
  late Future<Map<String, dynamic>> _userStatsFuture;

  // Dummy recommendation for UI testing
  final Recommendation _recommendedProject = Recommendation(
    co2Saved: "4.2 kg",
    description: "Create beautiful terracotta pots from recycled materials",
    imagePrompt: "Terracotta pot made from recycled materials",
    materials: {
      "plastic_bottle": 2,
      "tin_can": 1,
    },
    name: "Terracotta",
    stepByStep: [
      "Clean the plastic bottles thoroughly",
      "Cut the bottles into desired shapes",
      "Paint with terracotta colored paint",
      "Let dry completely",
      "Decorate as desired"
    ],
  );

  @override
  void initState() {
    super.initState();
    _userStatsFuture = _firestoreService.getUserStats();
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

    // Get user display name or email for greeting
    final String userName = user.displayName?.split(' ')[0] ??
        (user.email?.split('@')[0] ?? 'User');

    return Scaffold(
        backgroundColor: const Color(0xFFF5F5F5),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Greeting section with chat icon
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: const BoxDecoration(
                  color: Color(0xFFF5F5F5),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Hello, $userName!',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF333333),
                      ),
                    ),
                    // Chat icon with unread count
                    StreamBuilder<int>(
                        stream: _realtimeDBService.getUnreadChatsCount(),
                        builder: (context, snapshot) {
                          final int unreadCount = snapshot.data ?? 0;

                          return Stack(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.chat_outlined, size: 28),
                                onPressed: () {
                                  // Navigate to chat list screen
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const ChatListScreen(),
                                    ),
                                  );
                                },
                              ),
                              if (unreadCount > 0)
                                Positioned(
                                  top: 8,
                                  right: 8,
                                  child: Container(
                                    padding: const EdgeInsets.all(2),
                                    decoration: const BoxDecoration(
                                      color: Colors.red,
                                      shape: BoxShape.circle,
                                    ),
                                    constraints: const BoxConstraints(
                                      minWidth: 16,
                                      minHeight: 16,
                                    ),
                                    child: Text(
                                      unreadCount > 9 ? '9+' : '$unreadCount',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                            ],
                          );
                        }),
                  ],
                ),
              ),

              // Main card for scanning
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFF377047),
                        Color(0xFF4CAF50),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Transform waste into creation',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),
                      InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ScanScreen(),
                            ),
                          );
                        },
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                              vertical: 12, horizontal: 16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  const Icon(
                                    Icons.qr_code_scanner,
                                    color: Color(0xFF377047),
                                  ),
                                  const SizedBox(width: 12),
                                  const Text(
                                    'Start Scanning',
                                    style: TextStyle(
                                      color: Color(0xFF377047),
                                      fontWeight: FontWeight.w500,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                              const Icon(
                                Icons.arrow_forward_ios,
                                color: Color(0xFF377047),
                                size: 16,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Stats section
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: FutureBuilder<Map<String, dynamic>>(
                  future: _userStatsFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final stats = snapshot.data ??
                        {
                          'totalCO2Saved': 0.0,
                          'totalXP': 0,
                          'completedProjects': 0,
                        };

                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          _buildStatsContainer(
                            icon: Icons.qr_code_scanner,
                            value: '${stats['completedProjects']}',
                            label: 'Total Scans',
                          ),
                          Container(
                            width: 1,
                            height: 50,
                            color: Colors.grey.shade200,
                          ),
                          _buildStatsContainer(
                            icon: Icons.recycling,
                            value: '${stats['completedProjects']}',
                            label: 'Completed Projects',
                          ),
                          Container(
                            width: 1,
                            height: 50,
                            color: Colors.grey.shade200,
                          ),
                          _buildStatsContainer(
                            icon: Icons.star_border,
                            value: '${stats['totalXP']}',
                            label: 'Points Earned',
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              // Badge Earned section
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: FutureBuilder<Map<String, dynamic>>(
                  future: _userStatsFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final stats = snapshot.data ??
                        {
                          'totalCO2Saved': 0.0,
                          'totalXP': 0,
                          'completedProjects': 0,
                        };

                    // Calculate progress - cap at 1.0 for completed progress
                    final progress =
                        (stats['totalXP'] / 1000.0).clamp(0.0, 1.0);

                    return Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Badge Earned: Eco Explorer',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Text(
                                'CO',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[700],
                                ),
                              ),
                              Text(
                                '2',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey[700],
                                ),
                              ),
                              Text(
                                ' Saved: ${stats['totalCO2Saved'].toStringAsFixed(1)} kg',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[700],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          // Progress bar
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: LinearProgressIndicator(
                              value: progress,
                              minHeight: 10,
                              backgroundColor: Colors.grey[200],
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                Color(0xFF377047),
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${stats['totalXP']}/1000 XP',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                              const Icon(
                                Icons.recycling,
                                color: Color(0xFF377047),
                                size: 24,
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              // Recommended project section
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Upcycle Project for You',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Project card
                    SizedBox(
                      height: 180,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          _buildProjectCard(_recommendedProject),
                          const SizedBox(width: 16),
                          _buildProjectCard(_recommendedProject),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Add space at the bottom
              const SizedBox(height: 80),
            ],
          ),
        ));
  }

  Widget _buildStatsContainer({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          children: [
            Icon(icon, color: const Color(0xFF377047), size: 20),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProjectCard(Recommendation project) {
    return Container(
      width: 180,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            ),
            child: Image.network(
              'https://picsum.photos/200/120',
              height: 120,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          // Category label
          Container(
            margin: const EdgeInsets.only(left: 12, top: 8),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Text(
              'Outdoor',
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey,
              ),
            ),
          ),
          // Project name and price
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: Text(
              project.name,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: const Text(
              '\$15.00',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF377047),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
