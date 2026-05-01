import 'package:car_rental_app/core/theme/colors.dart';
import 'package:car_rental_app/core/widgets/app_scaffold.dart';
import 'package:flutter/material.dart';

import 'package:car_rental_app/features/home_feature/presentation/widgets/tabs/profile_tab.dart';

class DriverHomeScreen extends StatefulWidget {
  const DriverHomeScreen({super.key});

  @override
  State<DriverHomeScreen> createState() => _DriverHomeScreenState();
}

class _DriverHomeScreenState extends State<DriverHomeScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final List<Widget> tabs = [
      _buildConsoleTab(), // Driver Action Center
      _buildEmptyTab("Wallet & Earnings"), // Earnings Center
      const ProfileTab(), // Profile & Mode Switching
    ];

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: tabs[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: AppColors.cardColor,
        selectedItemColor: AppColors.primaryColor,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.drive_eta_outlined),
            activeIcon: Icon(Icons.drive_eta),
            label: 'Console',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet_outlined),
            activeIcon: Icon(Icons.account_balance_wallet),
            label: 'Wallet',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  Widget _buildConsoleTab() {
    return AppScaffold(
      appBar: AppBar(
        title:
            const Text("Driver Console", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.white),
        automaticallyImplyLeading: false,
        actions: [
          Switch(
              value: true,
              onChanged: (val) {},
              activeThumbColor: AppColors.primaryColor)
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.wifi_tethering,
                  size: 80, color: AppColors.primaryColor),
            ),
            const SizedBox(height: 20),
            const Text("You are Online",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            const Text("Waiting for trip requests...",
                style: TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyTab(String title) {
    return AppScaffold(
      appBar: AppBar(
        title: Text(title, style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        automaticallyImplyLeading: false,
      ),
      body: const Center(
        child: Text("Coming Soon", style: TextStyle(color: Colors.grey)),
      ),
    );
  }
}
