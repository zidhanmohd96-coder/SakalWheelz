import 'package:car_rental_app/core/theme/colors.dart';
import 'package:car_rental_app/features/home_feature/presentation/widgets/tabs/profile_tab.dart';
import 'package:car_rental_app/features/host_feature/presentation/tabs/host_bookings_tab.dart';
import 'package:car_rental_app/features/host_feature/presentation/tabs/host_dashboard_tab.dart';
import 'package:car_rental_app/features/host_feature/presentation/tabs/host_vehicles_tab.dart';
import 'package:flutter/material.dart';

class HostMainScreen extends StatefulWidget {
  const HostMainScreen({super.key});

  @override
  State<HostMainScreen> createState() => _HostMainScreenState();
}

class _HostMainScreenState extends State<HostMainScreen> {
  int _currentIndex = 0;

  final List<Widget> _tabs = [
    const HostDashboardTab(), // Home -> Earnings & Overview
    const HostVehiclesTab(), // Search -> My Vehicles
    const HostBookingsTab(), // Bookings -> Accept/Reject
    const ProfileTab(), // Profile -> Same as Customer
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: _tabs[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: AppColors.cardColor,
        selectedItemColor: Colors.blueAccent, // Host Theme Color
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.directions_car_outlined),
            activeIcon: Icon(Icons.directions_car),
            label: 'My Cars',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications_active_outlined),
            activeIcon: Icon(Icons.notifications_active),
            label: 'Requests',
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
}
