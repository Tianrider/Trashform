import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'home_screen.dart';
import 'community_screen.dart';
import 'marketplace_screen.dart';
import 'profile_screen.dart';
import 'scan_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  // List of screens for bottom navigation
  final List<Widget> _screens = [
    const HomeScreen(),
    const CommunityScreen(),
    Container(), // Placeholder for scan - this will be handled by the FAB
    const MarketplaceScreen(),
    const ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    // If scan button (index 2) is tapped, we'll handle it separately
    if (index == 2) {
      _showScanOptions();
      return;
    }

    setState(() {
      _selectedIndex = index;
    });
  }

  void _showScanOptions() {
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
    return Scaffold(
      body: _screens[_selectedIndex],
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
