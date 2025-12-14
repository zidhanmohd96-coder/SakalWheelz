import 'package:car_rental_app/core/theme/dimens.dart';
import 'package:car_rental_app/core/widgets/app_space.dart';
import 'package:car_rental_app/features/home_feature/presentation/screens/features_screens/hire_drivers_section.dart';
import 'package:car_rental_app/features/home_feature/presentation/widgets/banner_slider_widget.dart';
import 'package:car_rental_app/features/home_feature/presentation/widgets/home_screen_cars_list.dart';
import 'package:car_rental_app/features/home_feature/presentation/widgets/ready_to_earn_widget.dart'; // New Import
import 'package:car_rental_app/features/home_feature/presentation/widgets/top_brands_widget.dart';
import 'package:flutter/material.dart';

class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const SafeArea(
      child: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            AppVSpace(space: Dimens.largePadding),

            // 1. Banner Slider
            BannerSliderWidget(),
            AppVSpace(space: Dimens.largePadding),

            // 2. Top Brands
            TopBrandsWidget(),

            // 3. Car Lists (Existing Logic)
            HomeScreenCarsList(),
            AppVSpace(space: Dimens.largePadding),

            // 4. Hire Drivers (New Feature)
            HireDriversSection(),
            AppVSpace(space: Dimens.largePadding),

            // 5. Ready to Earn Banner (New Feature)
            ReadyToEarnWidget(),

            AppVSpace(space: 40.0), // Extra space at bottom
          ],
        ),
      ),
    );
  }
}
