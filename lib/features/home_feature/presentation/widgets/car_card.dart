import 'package:car_rental_app/core/theme/colors.dart';
import 'package:car_rental_app/features/car_feature/presentation/screens/car_details_screen.dart';
import 'package:flutter/material.dart';

class CarCard extends StatelessWidget {
  // Receive the full car data object directly
  final Map<String, dynamic> carData;

  const CarCard({
    super.key,
    required this.carData,
  });

  @override
  Widget build(BuildContext context) {
    // 1. Extract data safely for display
    final String carName = "${carData['brand']} ${carData['name']}";
    final String price = "\$${carData['price']}";

    // Get first image safely, or use a fallback
    final List<dynamic> images = carData['images'] ?? [];
    final String imageUrl = images.isNotEmpty
        ? images[0].toString()
        : 'assets/images/banner1.png'; // Fallback if image missing

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primaryColor.withOpacity(0.9)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 2. IMAGE AREA
          Container(
            height: 140,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Stack(
              children: [
                Center(
                  child: Image.asset(
                    imageUrl,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => const Icon(
                        Icons.directions_car,
                        size: 60,
                        color: Colors.grey),
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: AppColors.primaryColor,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.favorite_border, size: 18),
                  ),
                )
              ],
            ),
          ),

          const SizedBox(height: 12),

          // 3. TITLE
          Text(
            carName,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.whiteColor,
            ),
          ),

          const SizedBox(height: 8),

          // 4. FEATURES TAGS (Static for now, or use carData['transmission'])
          Row(
            children: [
              _buildFeatureTag(Icons.speed, carData['transmission'] ?? "Auto"),
              const SizedBox(width: 10),
              _buildFeatureTag(
                  Icons.local_gas_station, carData['fuel'] ?? "Petrol"),
            ],
          ),

          const SizedBox(height: 16),

          // 5. PRICE & ACTION
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    price,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: AppColors.primaryColor,
                    ),
                  ),
                  const Text(
                    "per day",
                    style: TextStyle(color: AppColors.grayColor, fontSize: 12),
                  ),
                ],
              ),
              ElevatedButton(
                onPressed: () {
                  // ✅ FIX: Use the carData passed to this widget
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CarDetailsScreen(
                        carData: carData, // Pass the data directly
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  elevation: 0,
                ),
                child: const Text(
                  "Details",
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildFeatureTag(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 14, color: Colors.white),
        const SizedBox(width: 4),
        Text(text,
            style: const TextStyle(color: AppColors.whiteColor, fontSize: 12)),
      ],
    );
  }
}
