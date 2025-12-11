import 'package:car_rental_app/core/gen/assets.gen.dart';
import 'package:car_rental_app/core/theme/colors.dart';
import 'package:car_rental_app/core/theme/dimens.dart';
import 'package:car_rental_app/core/utils/app_navigator.dart';
import 'package:car_rental_app/core/widgets/app_button.dart';
import 'package:car_rental_app/core/widgets/app_outlined_button.dart';
import 'package:car_rental_app/core/widgets/app_space.dart';
import 'package:car_rental_app/core/widgets/app_subtitle_text.dart';
import 'package:car_rental_app/core/widgets/app_svg_viewer.dart';
import 'package:car_rental_app/core/widgets/app_text_button.dart';
import 'package:car_rental_app/core/widgets/app_title_text.dart';
import 'package:car_rental_app/features/booking_feature/presentation/screens/booking_screen.dart';
import 'package:car_rental_app/features/car_feature/presentation/screens/car_details_screen.dart';
import 'package:car_rental_app/features/car_feature/presentation/screens/cars_list_screen.dart';
import 'package:car_rental_app/features/home_feature/data/data_source/local/sample_data.dart';
import 'package:flutter/material.dart';

class HomeScreenCarsList extends StatelessWidget {
  const HomeScreenCarsList({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: theTitleOfTheListOfCars.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (final context, final categoryIndex) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.all(
                    Dimens.largePadding,
                  ),
                  child: AppTitleText(
                    theTitleOfTheListOfCars[categoryIndex],
                    fontSize: 16.0,
                  ),
                ),
                AppTextButton(
                  child: Row(
                    spacing: Dimens.padding,
                    children: [
                      const Text(
                        'See all',
                        style: TextStyle(
                          color: AppColors.primaryColor,
                        ),
                      ),
                      AppSvgViewer(
                        Assets.icons.arrowRight1,
                        color: AppColors.primaryColor,
                        width: 14.0,
                      ),
                    ],
                  ),
                  onPressed: () {
                    push(context, const CarsListScreen());
                  },
                )
              ],
            ),
            SizedBox(
              height: 130.0,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: carsList.length,
                shrinkWrap: true,
                itemBuilder: (final context, final carIndex) {
                  final car = carsList[carIndex];
                  return Padding(
                    padding: const EdgeInsets.only(
                      left: Dimens.largePadding,
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.cardColor,
                        borderRadius: BorderRadius.circular(
                          Dimens.corners,
                        ),
                      ),
                      child: Column(
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const AppHSpace(),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: Dimens.largePadding,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  spacing: Dimens.padding,
                                  children: [
                                    Text(
                                      '${car['brand']} ${car['name']}',
                                      style: const TextStyle(
                                        color: AppColors.whiteColor,
                                      ),
                                    ),
                                    Row(
                                      spacing: Dimens.smallPadding,
                                      children: [
                                        AppTitleText(
                                          '\$ ${car['price']}',
                                          fontSize: 16.0,
                                        ),
                                        const AppSubtitleText('per day'),
                                      ],
                                    )
                                  ],
                                ),
                              ),
                              const AppHSpace(),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: Dimens.padding,
                                ),
                                child: SizedBox(
                                  height: 64.0,
                                  child: Image.asset(
                                    (car['images'] as List).isNotEmpty
                                        ? car['images'][0]
                                        : Assets.images.banner1.path,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Row(
                            spacing: Dimens.largePadding,
                            children: [
                              SizedBox(
                                width: 128.0,
                                height: 34.0,
                                child: AppButton(
                                  margin: EdgeInsets.zero,
                                  borderRadius: Dimens.smallCorners,
                                  title: 'Book now',
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            BookingScreen(carData: car),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              SizedBox(
                                width: 128.0,
                                height: 34.0,
                                child: AppOutlinedButton(
                                  margin: EdgeInsets.zero,
                                  borderRadius: Dimens.smallCorners,
                                  title: 'Details',
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => CarDetailsScreen(
                                          carData: car,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
