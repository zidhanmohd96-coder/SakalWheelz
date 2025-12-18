import 'package:animate_do/animate_do.dart';
import 'package:car_rental_app/core/gen/assets.gen.dart';
import 'package:car_rental_app/core/theme/colors.dart';
import 'package:car_rental_app/core/theme/dimens.dart';
import 'package:car_rental_app/core/widgets/app_bordered_icon_button.dart';
import 'package:car_rental_app/core/widgets/app_scaffold.dart';
import 'package:car_rental_app/core/widgets/app_subtitle_text.dart';
import 'package:car_rental_app/core/widgets/app_svg_viewer.dart';
import 'package:car_rental_app/core/widgets/app_title_text.dart';
import 'package:car_rental_app/features/car_feature/presentation/widgets/rate_widget.dart';
import 'package:car_rental_app/features/driver_feature/presentation/screens/driver_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:car_rental_app/features/home_feature/data/data_source/local/sample_data.dart';

// -- Mock Data for Drivers --

class DriversListScreen extends StatelessWidget {
  const DriversListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: Dimens.largePadding,
          ),
          child: AppBorderedIconButton(
            iconPath: Assets.icons.arrowLeft1,
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ),
        leadingWidth: 90.0,
        title: const AppTitleText("Available Drivers", fontSize: 20.0),
      ),
      body: FadeInUp(
        duration: const Duration(milliseconds: 600),
        child: ListView.builder(
          padding: const EdgeInsets.all(Dimens.largePadding),
          itemCount: sampleDrivers.length,
          itemBuilder: (final context, final index) {
            final driver = sampleDrivers[index];
            return _buildDriverCard(context, driver);
          },
        ),
      ),
    );
  }

  Widget _buildDriverCard(BuildContext context, Map<String, dynamic> driver) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DriverDetailsScreen(driver: driver),
          ),
        );
      },
      child: Container(
        height: 140,
        margin: const EdgeInsets.only(bottom: Dimens.largePadding),
        child: Stack(
          children: [
            // 1. Main Card Background
            Container(
              margin: const EdgeInsets.only(right: 12, bottom: 12),
              decoration: BoxDecoration(
                color: AppColors.cardColor,
                borderRadius: BorderRadius.circular(Dimens.corners),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(Dimens.padding),
              child: Row(
                children: [
                  // Profile Image
                  Container(
                    width: 90,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.grey[800],
                      borderRadius: BorderRadius.circular(20),
                      image: DecorationImage(
                        // Safely handle image path
                        image: NetworkImage(driver['image']),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(width: Dimens.largePadding),

                  // Info Section
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Name
                        Row(
                          children: [
                            Text(
                              driver['name'] ?? 'Unknown',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            // --- FIX IS HERE: Use '== true' ---
                            if (driver['isVerified'] == true) ...[
                              const SizedBox(width: 6),
                              const Icon(Icons.verified,
                                  color: Colors.blueAccent, size: 16)
                            ]
                          ],
                        ),
                        const SizedBox(height: 4),
                        AppSubtitleText(driver['category'] ?? ''),
                        const SizedBox(height: 8),

                        // Rating and Exp
                        Row(
                          children: [
                            RateWidget(rate: driver['rating'] ?? 0.0),
                            const SizedBox(width: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.primaryColor.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                driver['experience'] ?? '',
                                style: const TextStyle(
                                  color: AppColors.primaryColor,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            )
                          ],
                        ),
                        const SizedBox(height: 8),
                        // Price
                        RichText(
                          text: TextSpan(
                            children: [
                              const TextSpan(
                                text: "₹",
                                style: TextStyle(
                                    color: AppColors.primaryColor,
                                    fontWeight: FontWeight.bold),
                              ),
                              TextSpan(
                                text: "${driver['price']}",
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold),
                              ),
                              const TextSpan(
                                text: "/day",
                                style:
                                    TextStyle(color: Colors.grey, fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // 2. Floating Action Button
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: AppColors.backgroundColor,
                  shape: BoxShape.circle,
                ),
                child: CircleAvatar(
                  radius: 24,
                  backgroundColor: AppColors.primaryColor,
                  child: AppSvgViewer(
                    Assets.icons.arrowRight,
                    color: AppColors.backgroundColor,
                    width: 20,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
