import 'package:car_rental_app/core/theme/colors.dart';
import 'package:car_rental_app/core/theme/dimens.dart';
import 'package:car_rental_app/features/home_feature/presentation/screens/features_screens/become_driver_screen.dart';
import 'package:car_rental_app/features/home_feature/presentation/screens/features_screens/become_host_screen.dart';
import 'package:flutter/material.dart';

class ReadyToEarnWidget extends StatelessWidget {
  const ReadyToEarnWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: Dimens.largePadding),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        // Blue Gradient from screenshot
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primaryColor, AppColors.gradientStart],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryColor.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Ready to Earn?",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "List your vehicle or offer your driving services. Start earning today!",
            style: TextStyle(fontSize: 14, color: Colors.white70, height: 1.5),
          ),
          const SizedBox(height: 24),
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Become a Host Button (White)
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const BecomeHostScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: AppColors.primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: const Text("Become a Host",
                    style: TextStyle(fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 12),
              // Become a Driver Button (Translucent Blue)
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const BecomeDriverScreen()),
                  );
                },
                style: TextButton.styleFrom(
                  backgroundColor: Colors.white.withOpacity(0.2),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text("Become a Driver",
                    style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
