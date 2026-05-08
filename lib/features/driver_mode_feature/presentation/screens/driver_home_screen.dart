import 'package:car_rental_app/core/theme/colors.dart';
import 'package:car_rental_app/core/theme/dimens.dart';
import 'package:car_rental_app/core/widgets/app_scaffold.dart';
import 'package:car_rental_app/core/widgets/app_title_text.dart';
import 'package:car_rental_app/features/booking_feature/data/models/booking_model.dart';
import 'package:car_rental_app/features/booking_feature/data/repositories/booking_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:car_rental_app/features/home_feature/presentation/widgets/tabs/profile_tab.dart';
import 'package:intl/intl.dart';

class DriverHomeScreen extends StatefulWidget {
  const DriverHomeScreen({super.key});

  @override
  State<DriverHomeScreen> createState() => _DriverHomeScreenState();
}

class _DriverHomeScreenState extends State<DriverHomeScreen> {
  int _currentIndex = 0;
  final BookingRepository _bookingRepo = BookingRepository();
  String _driverName = '';
  bool _isOnline = true;

  @override
  void initState() {
    super.initState();
    _loadDriverName();
  }

  Future<void> _loadDriverName() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      final doc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (doc.exists && mounted) {
        setState(() {
          _driverName = doc.data()?['full_name'] ?? '';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> tabs = [
      _buildConsoleTab(), // Driver Action Center
      _buildWalletTab(), // Earnings Center
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
          Row(
            children: [
              Text(_isOnline ? "Online" : "Offline",
                  style: const TextStyle(color: Colors.white)),
              Switch(
                  value: _isOnline,
                  onChanged: (val) {
                    setState(() {
                      _isOnline = val;
                    });
                  },
                  activeThumbColor: AppColors.primaryColor)
            ],
          )
        ],
      ),
      body: _driverName.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : StreamBuilder<List<BookingModel>>(
              stream: _bookingRepo.getDriverBookings(_driverName),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final allBookings = snapshot.data ?? [];
                final upcomingBookings = allBookings
                    .where((b) => [
                          'Active',
                          'Confirmed',
                          'En route',
                          'Arrived',
                          'Started'
                        ].contains(b.status))
                    .toList();

                return Column(
                  children: [
                    const SizedBox(height: 20),
                    if (upcomingBookings.isEmpty)
                      Expanded(
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: _isOnline
                                      ? AppColors.primaryColor
                                          .withValues(alpha: 0.1)
                                      : Colors.grey.withValues(alpha: 0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(Icons.wifi_tethering,
                                    size: 80,
                                    color: _isOnline
                                        ? AppColors.primaryColor
                                        : Colors.grey),
                              ),
                              const SizedBox(height: 20),
                              Text(
                                  _isOnline
                                      ? "You are Online"
                                      : "You are Offline",
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold)),
                              const SizedBox(height: 10),
                              Text(
                                  _isOnline
                                      ? "Waiting for trip requests..."
                                      : "Go online to receive requests",
                                  style: const TextStyle(color: Colors.grey)),
                            ],
                          ),
                        ),
                      )
                    else
                      Expanded(
                        child: ListView.builder(
                          padding: const EdgeInsets.all(Dimens.largePadding),
                          itemCount: upcomingBookings.length,
                          itemBuilder: (context, index) {
                            final booking = upcomingBookings[index];
                            return _buildTripRequestCard(booking);
                          },
                        ),
                      ),
                  ],
                );
              },
            ),
    );
  }

  Widget _buildTripRequestCard(BookingModel booking) {
    final dateFormat = DateFormat('MMM dd, yyyy');
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardColor,
        borderRadius: BorderRadius.circular(16),
        border:
            Border.all(color: AppColors.primaryColor.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Ride • ${dateFormat.format(booking.startDate)}",
                  style: const TextStyle(
                      color: AppColors.primaryColor,
                      fontWeight: FontWeight.bold)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.amber.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(booking.status,
                    style: const TextStyle(color: Colors.amber, fontSize: 12)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.my_location, color: Colors.green, size: 20),
              const SizedBox(width: 8),
              Expanded(
                  child: Text(booking.pickupLocation,
                      style: const TextStyle(color: Colors.white))),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(left: 9.0, top: 4, bottom: 4),
            child: Container(width: 2, height: 20, color: Colors.grey.shade700),
          ),
          Row(
            children: [
              const Icon(Icons.location_on, color: Colors.red, size: 20),
              const SizedBox(width: 8),
              Expanded(
                  child: Text(booking.dropoffLocation,
                      style: const TextStyle(color: Colors.white))),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Estimated Earnings",
                      style: TextStyle(color: Colors.grey, fontSize: 12)),
                  Text("₹${booking.driverCost}",
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold)),
                ],
              ),
              if (booking.status == 'Active') ...[
                Row(children: [
                  TextButton(
                    onPressed: () => _updateStatus(booking.id, 'Rejected'),
                    child: const Text("Reject",
                        style: TextStyle(color: Colors.red)),
                  ),
                  ElevatedButton(
                    onPressed: () => _updateStatus(booking.id, 'Confirmed'),
                    style:
                        ElevatedButton.styleFrom(backgroundColor: Colors.green),
                    child: const Text("Accept",
                        style: TextStyle(color: Colors.white)),
                  )
                ])
              ] else if (booking.status == 'Confirmed') ...[
                ElevatedButton(
                  onPressed: () => _updateStatus(booking.id, 'En route'),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor),
                  child: const Text("Start: En route",
                      style: TextStyle(color: Colors.white)),
                )
              ] else if (booking.status == 'En route') ...[
                ElevatedButton(
                  onPressed: () => _updateStatus(booking.id, 'Arrived'),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor),
                  child: const Text("Arrived",
                      style: TextStyle(color: Colors.white)),
                )
              ] else if (booking.status == 'Arrived') ...[
                ElevatedButton(
                  onPressed: () => _updateStatus(booking.id, 'Started'),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor),
                  child: const Text("Start Trip",
                      style: TextStyle(color: Colors.white)),
                )
              ] else if (booking.status == 'Started') ...[
                ElevatedButton(
                  onPressed: () => _updateStatus(booking.id, 'Completed'),
                  style:
                      ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  child: const Text("Complete Ride",
                      style: TextStyle(color: Colors.white)),
                )
              ]
            ],
          )
        ],
      ),
    );
  }

  Future<void> _updateStatus(String bookingId, String newStatus) async {
    await FirebaseFirestore.instance
        .collection('bookings')
        .doc(bookingId)
        .update({'status': newStatus});
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Status updated to $newStatus"),
          backgroundColor: Colors.green));
    }
  }

  Widget _buildWalletTab() {
    return AppScaffold(
      appBar: AppBar(
        title: const Text("Wallet & Earnings",
            style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        automaticallyImplyLeading: false,
      ),
      body: _driverName.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : StreamBuilder<List<BookingModel>>(
              stream: _bookingRepo.getDriverBookings(_driverName),
              builder: (context, snapshot) {
                final bookings = snapshot.data ?? [];
                final completedTrips =
                    bookings.where((b) => b.status == 'Completed').toList();
                final totalEarnings =
                    completedTrips.fold(0.0, (sum, b) => sum + b.driverCost);

                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [AppColors.primaryColor, Color(0xFF1E3C72)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("Total Earnings",
                                style: TextStyle(
                                    color: Colors.white70, fontSize: 16)),
                            const SizedBox(height: 8),
                            Text("₹${totalEarnings.toStringAsFixed(2)}",
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 36,
                                    fontWeight: FontWeight.bold)),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text("Completed Trips",
                                        style:
                                            TextStyle(color: Colors.white70)),
                                    Text("${completedTrips.length}",
                                        style: const TextStyle(
                                            color: Colors.white, fontSize: 18)),
                                  ],
                                ),
                                ElevatedButton(
                                  onPressed: () {},
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    foregroundColor: AppColors.primaryColor,
                                  ),
                                  child: const Text("Withdraw"),
                                )
                              ],
                            )
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      const AppTitleText("Recent Transactions", fontSize: 18),
                      const SizedBox(height: 16),
                      if (completedTrips.isEmpty)
                        const Center(
                            child: Text("No transactions yet.",
                                style: TextStyle(color: Colors.grey)))
                      else
                        Expanded(
                          child: ListView.builder(
                            itemCount: completedTrips.length,
                            itemBuilder: (context, index) {
                              final trip = completedTrips[index];
                              return ListTile(
                                leading: const CircleAvatar(
                                  backgroundColor: Colors.green,
                                  child: Icon(Icons.attach_money,
                                      color: Colors.white),
                                ),
                                title: Text(
                                    "Trip to ${trip.dropoffLocation.split(',').first}",
                                    style:
                                        const TextStyle(color: Colors.white)),
                                subtitle: Text(
                                    DateFormat('MMM dd, yyyy')
                                        .format(trip.endDate),
                                    style: const TextStyle(color: Colors.grey)),
                                trailing: Text("+₹${trip.driverCost}",
                                    style: const TextStyle(
                                        color: Colors.green,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16)),
                              );
                            },
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
