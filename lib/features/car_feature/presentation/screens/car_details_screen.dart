import 'package:car_rental_app/core/theme/colors.dart';
import 'package:car_rental_app/core/theme/dimens.dart';
import 'package:car_rental_app/core/widgets/app_button.dart';
import 'package:car_rental_app/core/widgets/app_scaffold.dart';
import 'package:car_rental_app/core/widgets/app_space.dart';
import 'package:car_rental_app/core/widgets/app_title_text.dart';
import 'package:car_rental_app/features/booking_feature/presentation/screens/booking_screen.dart';
import 'package:car_rental_app/features/car_feature/presentation/widgets/cars_details_app_bar.dart';
import 'package:car_rental_app/features/car_feature/presentation/widgets/price_widget.dart';
import 'package:car_rental_app/features/car_feature/presentation/widgets/rate_widget.dart';
import 'package:car_rental_app/features/home_feature/data/data_source/local/sample_data.dart'; // Ensure this imports the NEW sample_data
import 'package:flutter/material.dart';

class CarDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> carData;

  const CarDetailsScreen({
    super.key,
    this.carData = const {},
  });

  @override
  State<CarDetailsScreen> createState() => _CarDetailsScreenState();
}

class _CarDetailsScreenState extends State<CarDetailsScreen> {
  late Map<String, dynamic> car;
  int _currentImageIndex = 0;

  @override
  void initState() {
    super.initState();
    // Logic: Use passed data. If empty, fallback to the first car in the list to prevent crash.
    if (widget.carData.isNotEmpty) {
      car = widget.carData;
    } else {
      car = carsList[0];
    }
  }

  @override
  Widget build(BuildContext context) {
    // --- Safe Data Extraction ---
    final List<dynamic> rawImages = car['images'] ?? [];
    // Convert to List<String> and handle empty case
    final List<String> images = rawImages.isEmpty
        ? ['assets/images/banner1.png'] // Fallback image if list is empty
        : rawImages.map((e) => e.toString()).toList();

    final List<dynamic> rawFeatures = car['features'] ?? [];
    final List<String> features = rawFeatures.map((e) => e.toString()).toList();

    final Map<String, dynamic> host = (car['host'] is Map<String, dynamic>)
        ? car['host']
        : {
            'name': 'Car Host',
            'trips': '0',
            'image': 'https://randomuser.me/api/portraits/men/1.jpg',
            'phone': '',
          };
    // ----------------------------

    return AppScaffold(
      appBar: const CarsDetailsAppBar(),
      padding: EdgeInsets.zero,
      // Pass the updated Bottom Sheet here
      bottomSheet: _buildBottomBookingBar(),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Swipeable Image Viewer
            SizedBox(
              height: 250,
              child: PageView.builder(
                itemCount: images.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentImageIndex = index;
                  });
                },
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: Dimens.mediumPadding),
                    child: Image.asset(
                      images[index],
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) => const Icon(
                          Icons.car_repair,
                          size: 100,
                          color: Colors.grey),
                    ),
                  );
                },
              ),
            ),
            // Dots Indicator
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(images.length, (index) {
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  height: 6,
                  width: _currentImageIndex == index ? 20 : 6,
                  decoration: BoxDecoration(
                    color: _currentImageIndex == index
                        ? AppColors.primaryColor
                        : Colors.grey.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(3),
                  ),
                );
              }),
            ),

            const AppVSpace(space: Dimens.largePadding),

            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: Dimens.largePadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: Dimens.largePadding,
                children: [
                  // 2. Name & Location
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: AppTitleText(
                              "${car['brand']} ${car['name']}",
                              fontSize: 24.0,
                            ),
                          ),
                          RateWidget(
                            rate: (car['rating'] is num)
                                ? (car['rating'] as num).toDouble()
                                : 4.5,
                            textColor: AppColors.whiteColor,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.location_on,
                              size: 16, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text(
                            car['location'] ?? 'Unknown Location',
                            style: const TextStyle(
                                color: Colors.grey, fontSize: 14),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        car['description'] ?? '',
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.grey,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),

                  // 3. Technical Specifications
                  const AppTitleText('Specifications', fontSize: 18.0),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E1E1E),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white10),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildMiniSpecItem(Icons.settings, "Trans.",
                                car['transmission'] ?? 'Auto'),
                            _buildMiniSpecItem(Icons.local_gas_station, "Fuel",
                                car['fuel'] ?? 'Petrol'),
                            _buildMiniSpecItem(Icons.event_seat, "Seats",
                                "${car['seats'] ?? 4} Seats"),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildMiniSpecItem(Icons.calendar_today, "Model",
                                car['model'] ?? '2024'),
                            _buildMiniSpecItem(Icons.directions_car, "Type",
                                car['type'] ?? 'Sedan'),
                            _buildMiniSpecItem(
                                Icons.speed, "Speed", "290 km/h"),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // 4. Features
                  if (features.isNotEmpty) ...[
                    const AppTitleText('Features', fontSize: 18.0),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: features.map((feature) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 10),
                          decoration: BoxDecoration(
                            color: AppColors.cardColor,
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(
                                color: AppColors.primaryColor.withOpacity(0.3)),
                          ),
                          child: Text(
                            feature,
                            style: const TextStyle(
                                color: Colors.white, fontSize: 12),
                          ),
                        );
                      }).toList(),
                    ),
                  ],

                  // 5. Host Details
                  const AppTitleText('Car Host', fontSize: 18.0),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.cardColor,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 26,
                          backgroundImage: NetworkImage(host['image']),
                          onBackgroundImageError: (_, __) {},
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                host['name'] ?? 'Host',
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold),
                              ),
                              Text(
                                "${host['trips']} Trips completed",
                                style: const TextStyle(
                                    color: Colors.grey, fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                        _buildCircleButton(Icons.phone, Colors.green),
                        const SizedBox(width: 10),
                        _buildCircleButton(Icons.message, Colors.blue),
                      ],
                    ),
                  ),

                  // EXTRA PADDING AT BOTTOM TO PREVENT OVERLAP
                  const AppVSpace(space: 160.0),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- UPDATED BOTTOM SHEET ---
  Widget _buildBottomBookingBar() {
    return Container(
      height: 137,
      decoration: BoxDecoration(
        color: AppColors.cardColor,
        borderRadius: BorderRadius.circular(
          Dimens.corners * 2,
        ),
      ),
      margin: const EdgeInsets.all(Dimens.largePadding),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(
              Dimens.largePadding,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Daily Rate'),
                PriceWidget(price: (car['price'] as num).toDouble()),
              ],
            ),
          ),
          AppButton(
              title: 'Book Now',
              onPressed: () {
                // 1. Push to Booking Screen and pass the 'carData'
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BookingScreen(carData: car),
                  ),
                );
              }),
        ],
      ),
    );
  }

  // --- Helpers ---

  Widget _buildMiniSpecItem(IconData icon, String label, String value) {
    return SizedBox(
      width: 80,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.primaryColor, size: 20),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(color: Colors.grey.shade500, fontSize: 10),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
                color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildCircleButton(IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: color, size: 20),
    );
  }
}
