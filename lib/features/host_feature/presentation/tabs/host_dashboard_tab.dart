import 'package:car_rental_app/core/theme/colors.dart';
import 'package:car_rental_app/core/theme/dimens.dart';
import 'package:car_rental_app/core/widgets/app_title_text.dart';
import 'package:car_rental_app/features/booking_feature/data/models/booking_model.dart';
import 'package:car_rental_app/features/booking_feature/data/repositories/booking_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class HostDashboardTab extends StatefulWidget {
  const HostDashboardTab({super.key});

  @override
  State<HostDashboardTab> createState() => _HostDashboardTabState();
}

class _HostDashboardTabState extends State<HostDashboardTab> {
  final BookingRepository _bookingRepo = BookingRepository();
  String _hostName = '';

  @override
  void initState() {
    super.initState();
    _loadHostName();
  }

  Future<void> _loadHostName() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();
      if (doc.exists && mounted) {
        setState(() {
          _hostName = doc.data()?['full_name'] ?? '';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Host Dashboard",
            style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        automaticallyImplyLeading: false,
      ),
      body: _hostName.isEmpty
          ? _buildShimmer()
          : StreamBuilder<List<BookingModel>>(
              stream: _bookingRepo.getHostBookings(_hostName),
              builder: (context, snapshot) {
                final bookings = snapshot.data ?? [];
                final activeBookings = bookings
                    .where((b) =>
                        b.status == 'Active' || b.status == 'Confirmed')
                    .toList();
                final completedBookings = bookings
                    .where((b) => b.status == 'Completed')
                    .toList();
                final totalEarnings = completedBookings.fold<double>(
                    0.0, (total, b) => total + b.totalPrice);
                final thisMonthEarnings = completedBookings
                    .where((b) =>
                        b.endDate.month == DateTime.now().month &&
                        b.endDate.year == DateTime.now().year)
                    .fold<double>(0.0, (total, b) => total + b.totalPrice);

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(Dimens.largePadding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 1. Earnings Card
                      _buildEarningsCard(totalEarnings, thisMonthEarnings),
                      const SizedBox(height: 24),

                      const AppTitleText("Overview", fontSize: 18),
                      const SizedBox(height: 16),

                      // 2. Stats Grid
                      Row(
                        children: [
                          _buildStatCard("Active", "${activeBookings.length}",
                              Icons.directions_car, AppColors.primaryColor),
                          const SizedBox(width: 16),
                          _buildStatCard(
                              "Completed",
                              "${completedBookings.length}",
                              Icons.check_circle,
                              Colors.greenAccent),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          _buildStatCard("Total", "${bookings.length}",
                              Icons.receipt_long, AppColors.primaryColor),
                          const SizedBox(width: 16),
                          _buildStatCard(
                              "Pending",
                              "${bookings.where((b) => b.status == 'Active').length}",
                              Icons.pending_actions,
                              Colors.orangeAccent),
                        ],
                      ),

                      const SizedBox(height: 24),
                      const AppTitleText("Recent Activity", fontSize: 18),
                      const SizedBox(height: 12),

                      // 3. Recent Bookings List
                      if (bookings.isEmpty)
                        _buildEmptyState()
                      else
                        ...bookings.take(5).map((b) => _buildActivityTile(b)),
                    ],
                  ),
                );
              },
            ),
    );
  }

  Widget _buildEarningsCard(double totalEarnings, double thisMonth) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primaryColor,
            AppColors.primaryColor.withValues(alpha: 0.7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: AppColors.primaryColor.withValues(alpha: 0.3),
              blurRadius: 10,
              offset: const Offset(0, 5)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Total Earnings",
              style: TextStyle(color: Colors.white70)),
          const SizedBox(height: 8),
          Text("₹ ${totalEarnings.toStringAsFixed(0)}",
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text("This Month: ₹${thisMonth.toStringAsFixed(0)}",
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.white60)),
              ),
              const Icon(Icons.trending_up, color: Colors.greenAccent),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 12),
            Text(value,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold)),
            Text(title,
                style: const TextStyle(color: Colors.grey, fontSize: 13)),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityTile(BookingModel booking) {
    Color statusColor;
    switch (booking.status) {
      case 'Active':
        statusColor = Colors.orangeAccent;
        break;
      case 'Confirmed':
        statusColor = Colors.greenAccent;
        break;
      case 'Completed':
        statusColor = AppColors.primaryColor;
        break;
      case 'Cancelled':
        statusColor = Colors.redAccent;
        break;
      default:
        statusColor = Colors.grey;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10)),
            child: Icon(Icons.receipt_long, color: statusColor, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "${booking.carBrand} ${booking.carName}",
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w600),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  "${booking.startDate.day}/${booking.startDate.month} - ${booking.endDate.day}/${booking.endDate.month} • \$${booking.totalPrice.toStringAsFixed(0)}",
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              booking.status,
              style: TextStyle(
                  color: statusColor,
                  fontSize: 11,
                  fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(40),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.inbox_outlined,
                size: 60, color: Colors.grey.shade700),
            const SizedBox(height: 16),
            Text("No bookings yet",
                style: TextStyle(color: Colors.grey.shade500, fontSize: 16)),
            const SizedBox(height: 8),
            Text("Bookings for your cars will appear here",
                style: TextStyle(color: Colors.grey.shade700, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmer() {
    return Padding(
      padding: const EdgeInsets.all(Dimens.largePadding),
      child: Column(
        children: List.generate(
          3,
          (index) => Shimmer.fromColors(
            baseColor: Colors.grey.shade800,
            highlightColor: Colors.grey.shade700,
            child: Container(
              height: index == 0 ? 150 : 80,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: AppColors.cardColor,
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
