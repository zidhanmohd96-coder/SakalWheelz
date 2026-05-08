import 'package:car_rental_app/core/theme/colors.dart';
import 'package:car_rental_app/core/widgets/app_scaffold.dart';
import 'package:car_rental_app/core/widgets/app_title_text.dart';
import 'package:flutter/material.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock notifications data
    final notifications = [
      {
        'title': 'Booking Confirmed!',
        'message': 'Your Toyota Camry booking for tomorrow is confirmed.',
        'time': '2 mins ago',
        'isRead': false,
        'icon': Icons.check_circle,
        'color': Colors.green,
      },
      {
        'title': 'New Message',
        'message': 'Host Mike sent you a message regarding your trip.',
        'time': '1 hour ago',
        'isRead': false,
        'icon': Icons.chat,
        'color': AppColors.primaryColor,
      },
      {
        'title': 'Payment Successful',
        'message': '\$120.00 was deducted for your recent booking.',
        'time': 'Yesterday',
        'isRead': true,
        'icon': Icons.payment,
        'color': Colors.blue,
      },
      {
        'title': 'Trip Completed',
        'message': 'Hope you enjoyed your ride! Please rate your experience.',
        'time': '2 days ago',
        'isRead': true,
        'icon': Icons.star,
        'color': Colors.amber,
      },
      {
        'title': 'Special Offer',
        'message': 'Get 20% off on your next weekend getaway. Use code WKND20.',
        'time': '1 week ago',
        'isRead': true,
        'icon': Icons.local_offer,
        'color': Colors.purple,
      },
    ];

    return AppScaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text("Notifications", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton(
            onPressed: () {
              // Mark all as read logic
            },
            child: const Text("Clear All", style: TextStyle(color: AppColors.primaryColor)),
          )
        ],
      ),
      body: notifications.isEmpty
          ? _buildEmptyState()
          : ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              itemCount: notifications.length,
              separatorBuilder: (context, index) => const Divider(color: Colors.white10, height: 1),
              itemBuilder: (context, index) {
                final notif = notifications[index];
                return _buildNotificationTile(notif);
              },
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications_off_outlined, size: 80, color: Colors.grey.shade700),
          const SizedBox(height: 16),
          const AppTitleText("No Notifications", fontSize: 20),
          const SizedBox(height: 8),
          Text("You have no new notifications right now.", style: TextStyle(color: Colors.grey.shade500)),
        ],
      ),
    );
  }

  Widget _buildNotificationTile(Map<String, dynamic> notif) {
    final bool isRead = notif['isRead'] as bool;
    
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      color: isRead ? Colors.transparent : AppColors.primaryColor.withOpacity(0.05),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: (notif['color'] as Color).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(notif['icon'] as IconData, color: notif['color'] as Color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        notif['title'] as String,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: isRead ? FontWeight.w500 : FontWeight.bold,
                        ),
                      ),
                    ),
                    Text(
                      notif['time'] as String,
                      style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  notif['message'] as String,
                  style: TextStyle(
                    color: isRead ? Colors.grey.shade400 : Colors.grey.shade300,
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          if (!isRead) ...[
            const SizedBox(width: 12),
            Container(
              margin: const EdgeInsets.only(top: 6),
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: AppColors.primaryColor,
                shape: BoxShape.circle,
              ),
            ),
          ]
        ],
      ),
    );
  }
}
