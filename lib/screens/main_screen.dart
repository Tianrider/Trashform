import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'home_screen.dart';
import 'community_screen.dart';
import 'marketplace_screen.dart';
import 'profile_screen.dart';
import 'scan_screen.dart';
import 'chat_list_screen.dart';
import 'onboarding_screen.dart';
import '../services/realtime_db_service.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  final RealtimeDBService _realtimeDBService = RealtimeDBService();

  // List of screens for bottom navigation
  final List<Widget> _screens = [
    const HomeScreen(),
    const CommunityScreen(),
    Container(), // Placeholder for scan - this will be handled by the FAB
    const MarketplaceScreen(),
    const ProfileScreen(),
  ];

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

  void _onItemTapped(int index) {
    // If scan button (index 2) is tapped, we'll handle it separately
    if (index == 2) {
      _showScanOptions();
      return;
    }

    // Special handling for Profile tab
    if (index == 4) {
      setState(() {
        _selectedIndex = index;
      });
      // Force refresh to ensure ProfileScreen is shown
      if (mounted) {
        Future.microtask(() {
          setState(() {});
        });
      }
      return;
    }

    setState(() {
      _selectedIndex = index;
    });
  }

  void _navigateToChat() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ChatListScreen()),
    );
  }

  void _showScanOptions() {
    // Double-check authentication before showing scan
    if (FirebaseAuth.instance.currentUser == null) {
      _checkAuthentication();
      return;
    }

    if (kDebugMode) {
      print("Opening camera for scanning");
    }
    // Navigate to the scan screen
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ScanScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Check authentication on every build
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      // Return loading state while we trigger navigation in initState/didChangeDependencies
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF377047),
        title: _getScreenTitle(),
        centerTitle: false,
        elevation: 0,
        actions: [
          // Chat icon with unread count
          StreamBuilder<int>(
              stream: _realtimeDBService.getUnreadChatsCount(),
              builder: (context, snapshot) {
                final int unreadCount = snapshot.data ?? 0;

                return Stack(
                  alignment: Alignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.chat_outlined,
                          color: Colors.white, size: 24),
                      onPressed: _navigateToChat,
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
                            minWidth: 14,
                            minHeight: 14,
                          ),
                          child: Text(
                            unreadCount > 9 ? '9+' : '$unreadCount',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 8,
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
      body: _selectedIndex == 4
          ? const ProfileScreen() // Explicitly use ProfileScreen for index 4
          : _screens[_selectedIndex],
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            // Home button
            _buildNavItem(0, Icons.home_outlined, Icons.home, 'Home'),

            // Community button
            _buildNavItem(1, Icons.people_outline, Icons.people, 'Community'),

            // Empty space for FAB
            const SizedBox(width: 40),

            // Marketplace button
            _buildNavItem(3, Icons.store_outlined, Icons.store, 'Shop'),

            // Profile button
            _buildNavItem(4, Icons.person_outline, Icons.person, 'Profile'),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showScanOptions,
        backgroundColor: const Color(0xFF2E7D32),
        child: const Icon(
          Icons.qr_code_scanner,
          color: Colors.white,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _getScreenTitle() {
    switch (_selectedIndex) {
      case 0:
        return const Text(
          'Home',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        );
      case 1:
        return const Text(
          'Community',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        );
      case 3:
        return const Text(
          'Marketplace',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        );
      case 4:
        return const Text(
          'Profile',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        );
      default:
        return const Text(
          'Trashform',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        );
    }
  }

  Widget _buildNavItem(
      int index, IconData outlinedIcon, IconData filledIcon, String label) {
    final bool isSelected = _selectedIndex == index;

    return InkWell(
      onTap: () => _onItemTapped(index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? filledIcon : outlinedIcon,
              color: isSelected ? const Color(0xFF2E7D32) : Colors.grey,
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: isSelected ? const Color(0xFF2E7D32) : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
