import 'package:car_rental_app/core/theme/colors.dart';
import 'package:car_rental_app/core/theme/dimens.dart';
import 'package:car_rental_app/core/widgets/app_button.dart';
import 'package:car_rental_app/core/widgets/app_scaffold.dart';
import 'package:car_rental_app/core/widgets/app_title_text.dart';
import 'package:car_rental_app/features/home_feature/presentation/screens/home_screen.dart'; // Ensure this points to your actual Home
import 'package:flutter/material.dart';

class BookingSuccessScreen extends StatelessWidget {
  final Map<String, dynamic> carData;
  final String bookingId;
  final DateTime startDate;
  final DateTime endDate;
  final double totalPrice;

  const BookingSuccessScreen({
    super.key,
    required this.carData,
    required this.bookingId,
    required this.startDate,
    required this.endDate,
    required this.totalPrice,
  });

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      // Prevent going back to the form
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        automaticallyImplyLeading: false,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () => _goToHome(context),
            icon: const Icon(Icons.close, color: Colors.white),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: Dimens.largePadding),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 1. Success Icon (Animated scale effect could be added here)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child:
                  const Icon(Icons.check_circle, color: Colors.green, size: 80),
            ),
            const SizedBox(height: 24),

            const AppTitleText("Booking Confirmed!", fontSize: 24),
            const SizedBox(height: 8),
            Text(
              "You are all set to drive the ${carData['brand']}.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade400, fontSize: 14),
            ),

            const SizedBox(height: 40),

            // 2. Receipt Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.cardColor,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white10),
              ),
              child: Column(
                children: [
                  _buildReceiptRow("Booking ID", bookingId, isBold: true),
                  const Divider(color: Colors.white10, height: 30),
                  _buildReceiptRow(
                      "Car", "${carData['brand']} ${carData['name']}"),
                  const SizedBox(height: 12),
                  _buildReceiptRow("Pickup",
                      "${startDate.day}/${startDate.month}/${startDate.year}"),
                  const SizedBox(height: 12),
                  _buildReceiptRow("Drop-off",
                      "${endDate.day}/${endDate.month}/${endDate.year}"),
                  const Divider(color: Colors.white10, height: 30),
                  _buildReceiptRow(
                      "Total Paid", "\$${totalPrice.toStringAsFixed(0)}",
                      isHighlight: true),
                ],
              ),
            ),

            const Spacer(),

            // 3. Action Button
            SizedBox(
              width: double.infinity,
              height: 94,
              child: AppButton(
                title: "Go to My Trips",
                onPressed: () => _goToHome(context),
              ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => _goToHome(context),
              child: const Text("Back to Home",
                  style: TextStyle(color: Colors.grey)),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildReceiptRow(String label, String value,
      {bool isBold = false, bool isHighlight = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: TextStyle(color: Colors.grey.shade500, fontSize: 14)),
        Text(
          value,
          style: TextStyle(
            color: isHighlight ? AppColors.primaryColor : Colors.white,
            fontWeight:
                (isBold || isHighlight) ? FontWeight.bold : FontWeight.normal,
            fontSize: isHighlight ? 18 : 14,
          ),
        ),
      ],
    );
  }

  void _goToHome(BuildContext context) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        // Index 2 = Bookings Tab
        builder: (context) => const HomeScreen(initialIndex: 2),
      ),
      (Route<dynamic> route) => false,
    );
  }
}
