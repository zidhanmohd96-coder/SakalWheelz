import 'package:car_rental_app/core/theme/colors.dart';
import 'package:car_rental_app/core/theme/dimens.dart';
import 'package:car_rental_app/core/widgets/app_title_text.dart';
import 'package:flutter/material.dart';

class HostDashboardTab extends StatelessWidget {
  const HostDashboardTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            const Text("Host Dashboard", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      drawer: const ModeDrawer(), // Allows switching back to Customer
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(Dimens.largePadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Earnings Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF2E63F7), Color(0xFF1A237E)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                      color: Colors.blueAccent.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 5)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text("Total Earnings",
                      style: TextStyle(color: Colors.white70)),
                  SizedBox(height: 8),
                  Text("₹ 45,200",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.bold)),
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("This Month: ₹12,500",
                          style: TextStyle(color: Colors.white60)),
                      Icon(Icons.trending_up, color: Colors.greenAccent),
                    ],
                  )
                ],
              ),
            ),

            const SizedBox(height: 24),
            const AppTitleText("Overview", fontSize: 18),
            const SizedBox(height: 16),

            // 2. Stats Grid
            Row(
              children: [
                _buildStatCard(
                    "Active Cars", "3", Icons.directions_car, Colors.orange),
                const SizedBox(width: 16),
                _buildStatCard(
                    "Pending", "2", Icons.pending_actions, Colors.redAccent),
              ],
            ),

            const SizedBox(height: 24),
            const AppTitleText("Recent Activity", fontSize: 18),

            // 3. Simple List
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 3,
              itemBuilder: (context, index) {
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(
                    backgroundColor: Colors.grey[800],
                    child: const Icon(Icons.person, color: Colors.white),
                  ),
                  title: const Text("New Booking Request",
                      style: TextStyle(color: Colors.white)),
                  subtitle: const Text("Toyota Innova • 24 Oct - 26 Oct",
                      style: TextStyle(color: Colors.grey)),
                  trailing: const Text("2m ago",
                      style: TextStyle(color: Colors.grey, fontSize: 12)),
                );
              },
            ),
          ],
        ),
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
            Text(title, style: const TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}

class ModeDrawer extends StatelessWidget {
  const ModeDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(),
    );
  }
}
