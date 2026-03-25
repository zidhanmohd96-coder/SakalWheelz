import 'package:car_rental_app/core/theme/colors.dart';
import 'package:car_rental_app/core/widgets/app_button.dart';
import 'package:flutter/material.dart';

class DeliveryTrackingScreen extends StatelessWidget {
  final Map<String, dynamic> carData;

  const DeliveryTrackingScreen({super.key, required this.carData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Track Delivery'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // 1. Mock Map Background
          Positioned.fill(
            child: Image.network(
              'https://miro.medium.com/v2/resize:fit:1400/1*qYUvhHzk0KGaXv58S-C_Mw.png',
              fit: BoxFit.cover,
              color: Colors.black54, // Darken for dark theme
              colorBlendMode: BlendMode.darken,
            ),
          ),
          
          // 2. Animated Pulse for Car Marker
          Center(
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primaryColor.withOpacity(0.3),
              ),
              child: Center(
                child: Container(
                  width: 30,
                  height: 30,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primaryColor,
                  ),
                  child: const Icon(Icons.directions_car, color: Colors.black, size: 16),
                ),
              ),
            ),
          ),

          // 3. Driver Status Card
          Positioned(
            bottom: 40,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.cardColor,
                borderRadius: BorderRadius.circular(24),
                boxShadow: const [BoxShadow(color: Colors.black54, blurRadius: 20)],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text("Driver is arriving in 12 mins", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const CircleAvatar(
                        radius: 25,
                        backgroundImage: NetworkImage('https://randomuser.me/api/portraits/men/32.jpg'),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("James Carter", style: TextStyle(color: Colors.white, fontSize: 16)),
                            Text("Delivery Agent • 4.9 ★", style: TextStyle(color: Colors.grey.shade400, fontSize: 12)),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(color: Colors.green.withOpacity(0.2), shape: BoxShape.circle),
                        child: const Icon(Icons.phone, color: Colors.green),
                      )
                    ],
                  ),
                  const SizedBox(height: 16),
                  Divider(color: Colors.grey.shade800),
                  const SizedBox(height: 16),
                  Text("${carData['brand']} ${carData['name']} • ${carData['color'] ?? 'Black'}", style: const TextStyle(color: Colors.white)),
                  const SizedBox(height: 16),
                  AppButton(
                    title: "Back to Home",
                    onPressed: () {
                      Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
                    },
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
