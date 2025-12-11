import 'package:car_rental_app/core/gen/assets.gen.dart'; // Make sure you have driver assets
import 'package:car_rental_app/core/theme/colors.dart';
import 'package:car_rental_app/core/theme/dimens.dart';
import 'package:car_rental_app/core/widgets/app_button.dart';
import 'package:car_rental_app/core/widgets/app_scaffold.dart';
import 'package:car_rental_app/core/widgets/app_space.dart';
import 'package:car_rental_app/core/widgets/app_title_text.dart';
// You might need to create a DriverDetailsAppBar or reuse the existing one
import 'package:car_rental_app/features/car_feature/presentation/widgets/cars_details_app_bar.dart';
import 'package:car_rental_app/features/car_feature/presentation/widgets/car_spec_widget.dart';
import 'package:car_rental_app/features/car_feature/presentation/widgets/price_widget.dart';
import 'package:car_rental_app/features/car_feature/presentation/widgets/rate_widget.dart';
import 'package:car_rental_app/features/home_feature/data/data_source/local/sample_data.dart';
import 'package:flutter/material.dart';

class DriverDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> driver;

  const DriverDetailsScreen({super.key, required this.driver});

  @override
  Widget build(BuildContext context) {
    // Safely cast languages, defaulting to empty list if null
    final List<String> languages = (driver['languages'] as List<String>?) ?? [];

    return AppScaffold(
      // You can rename CarsDetailsAppBar to CommonDetailsAppBar later
      appBar: const CarsDetailsAppBar(),
      padding: EdgeInsets.zero,
      body: SingleChildScrollView(
        child: Column(
          spacing: Dimens.largePadding,
          children: [
            // 1. Driver Image Section (Replaces App3dViewerWidget)
            _buildDriverImage(driver['image']),

            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: Dimens.largePadding,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: Dimens.largePadding,
                children: [
                  // 2. Driver Name & Description
                  Center(
                    child: AppTitleText(
                      driver['name'] ?? 'Driver Name',
                      fontSize: 35.0,
                      color: AppColors.primaryColor,
                    ),
                  ),
                  const AppTitleText(
                    'About the Driver',
                    fontSize: 16.0,
                    color: AppColors.veryLightPrimaryColor,
                  ),
                  Text(
                    driverDescriptionTemplate(
                      driver['name'] ?? 'The Driver',
                      driver['category'] ?? 'Taxi',
                      driver['experience'] ?? 'N/A',
                    ),
                    style: const TextStyle(
                      fontSize: 15,
                      color: AppColors.whiteColor,
                    ),
                  ),
                  const Divider(color: Colors.white24),

// 3. Title & Rating Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const AppTitleText(
                        'Driver Profile',
                        fontSize: 16.0,
                        color: AppColors.veryLightPrimaryColor,
                      ),
                      RateWidget(
                        rate: (driver['rating'] as num?)?.toDouble() ?? 0.0,
                        textColor: AppColors.whiteColor,
                      ),
                    ],
                  ),

// 4. Specs Row (Experience, Category, etc.)
                  Builder(
                    builder: (context) {
                      // Logic to determine the correct category icon
// Assuming driver['category'] contains strings like 'Heavy', 'Tourist', or 'Taxi'
                      String categoryIconPath;
                      final String category =
                          (driver['category'] ?? '').toString().toLowerCase();

                      if (category.contains('heavy')) {
                        categoryIconPath = Assets.images.heavyIcon.path;
                      } else if (category.contains('tourist')) {
                        categoryIconPath = Assets.images.touristIcon.path;
                      } else {
                        // Default to taxi if valid or unknown
                        categoryIconPath = Assets.images.taxiIcon.path;
                      }

                      return // 4. Specs Row (Experience, Category, Verified)
                          Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 16, horizontal: 12),
                        decoration: BoxDecoration(
                          color: AppColors.cardColor, // Subtle background color
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.primaryColor),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // 1. Experience
                            CarSpecWidget(
                              // Using steering wheel for experience (Skills)
                              imagePath: Assets.images.experienceIcon.path,
                              title: 'Experience',
                              value: driver['experience'] ?? 'N/A',
                            ),

                            // 2. Category (Dynamic Icon)
                            CarSpecWidget(
                              // Uses the logic defined above to pick Heavy, Tourist, or Taxi
                              imagePath: categoryIconPath,
                              title: 'Category',
                              value: driver['category'] ?? 'Taxi',
                            ),

                            // 3. Verified Status
                            CarSpecWidget(
                              // Explicit verified checkmark icon
                              imagePath: Assets.images.verifiedIcon.path,
                              title: 'Verified',
                              value: 'Yes',
                            ),
                          ],
                        ),
                      );
                    },
                  ),

                  const Divider(color: Colors.white24),

                  // 5. NEW: Languages Section
                  const AppTitleText(
                    'Languages Spoken',
                    fontSize: 14.0,
                  ),
                  Wrap(
                    spacing: 8.0,
                    runSpacing: 8.0,
                    children: languages.map((lang) {
                      return Chip(
                        label: Text(
                          lang,
                          style: const TextStyle(
                              fontSize: 12, color: AppColors.whiteColor),
                        ),
                        backgroundColor: AppColors.cardColor,
                        padding: const EdgeInsets.all(4),
                      );
                    }).toList(),
                  ),

                  const AppVSpace(
                    space: 150.0,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),

      // 6. Bottom Sheet (Price & Book)
      bottomSheet: Container(
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
                  PriceWidget(price: (driver['price'] as num).toDouble()),
                ],
              ),
            ),
            AppButton(
                title: 'Hire Driver',
                onPressed: () {
                  // Add booking logic here
                }),
          ],
        ),
      ),
    );
  }

  // Helper widget to render the image nicely
  Widget _buildDriverImage(String imageUrl) {
    return Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.primaryColor, width: 3),
        ),
        child: CircleAvatar(
          radius: 60,
          backgroundColor: AppColors.veryLightPrimaryColor.withOpacity(0.3),
          backgroundImage: NetworkImage(imageUrl),
          child: imageUrl.isEmpty
              ? const Icon(
                  Icons.person,
                  size: 60,
                  color: AppColors.whiteColor,
                )
              : null,
        ));
  }
}
