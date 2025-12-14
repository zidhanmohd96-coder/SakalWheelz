import 'package:car_rental_app/core/gen/assets.gen.dart';
import 'package:car_rental_app/core/theme/colors.dart';
import 'package:car_rental_app/core/theme/dimens.dart';
import 'package:car_rental_app/core/widgets/app_svg_viewer.dart';
import 'package:car_rental_app/core/widgets/app_title_text.dart';
import 'package:car_rental_app/features/driver_feature/presentation/screens/driver_details_screen.dart'; // Import Details Screen
import 'package:car_rental_app/features/driver_feature/presentation/screens/drivers_list_screen.dart';
import 'package:car_rental_app/features/home_feature/data/data_source/local/sample_data.dart'; // Ensure sampleDrivers is here
import 'package:flutter/material.dart';

class HireDriversSection extends StatelessWidget {
  const HireDriversSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: Dimens.largePadding),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    AppTitleText("Hire Professional Drivers", fontSize: 18),
                    SizedBox(height: 4),
                    Text(
                      "Verified drivers for any occasion",
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const DriversListScreen()),
                  );
                },
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Row(
                  children: [
                    const Text("See all",
                        style: TextStyle(color: AppColors.primaryColor)),
                    const SizedBox(width: 6),
                    AppSvgViewer(
                      Assets.icons.arrowRight1,
                      color: AppColors.primaryColor,
                      width: 14.0,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // --- Driver Horizontal List ---
        Container(
          height: 90,
          margin: const EdgeInsets.only(top: 16),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding:
                const EdgeInsets.symmetric(horizontal: Dimens.largePadding),
            // Use the shared sampleDrivers list
            itemCount: sampleDrivers.length,
            itemBuilder: (context, index) {
              final driver = sampleDrivers[index];

              return GestureDetector(
                onTap: () {
                  // --- NAVIGATION LOGIC ---
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DriverDetailsScreen(driver: driver),
                    ),
                  );
                },
                child: Container(
                  width: 280,
                  margin: const EdgeInsets.only(right: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.cardColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.withOpacity(0.1)),
                  ),
                  child: Row(
                    children: [
                      // Driver Image
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.grey[800],
                          shape: BoxShape.circle,
                          image: DecorationImage(
                            image: NetworkImage(driver['image']),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Driver Details
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              driver['name'],
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "${driver['category']} • ₹${driver['price']}/day",
                              style: TextStyle(
                                  color: Colors.grey[400], fontSize: 12),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        )
      ],
    );
  }
}
