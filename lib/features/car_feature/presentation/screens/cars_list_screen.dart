import 'package:animate_do/animate_do.dart';
import 'package:car_rental_app/core/gen/assets.gen.dart';
import 'package:car_rental_app/core/theme/colors.dart';
import 'package:car_rental_app/core/theme/dimens.dart';
import 'package:car_rental_app/core/widgets/app_scaffold.dart';
import 'package:car_rental_app/core/widgets/app_subtitle_text.dart';
import 'package:car_rental_app/core/widgets/app_svg_viewer.dart';
import 'package:car_rental_app/core/widgets/app_title_text.dart';
import 'package:car_rental_app/features/car_feature/presentation/bloc/car_cubit.dart';
import 'package:car_rental_app/features/car_feature/presentation/screens/car_details_screen.dart';
import 'package:car_rental_app/features/car_feature/presentation/widgets/car_list_card_painter.dart';
import 'package:car_rental_app/features/car_feature/presentation/widgets/cars_list_app_bar.dart';
import 'package:car_rental_app/features/car_feature/presentation/widgets/price_widget.dart';
import 'package:car_rental_app/features/car_feature/presentation/widgets/rate_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shimmer/shimmer.dart';

class CarsListScreen extends StatelessWidget {
  const CarsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: const CarsListAppBar(),
      body: FadeInDown(
        child: BlocBuilder<CarCubit, CarState>(
          builder: (context, state) {
            if (state is CarLoading) {
              return ListView.builder(
                itemCount: 5,
                itemBuilder: (context, index) => Padding(
                  padding: const EdgeInsets.only(top: Dimens.largePadding),
                  child: Shimmer.fromColors(
                    baseColor: AppColors.cardColor,
                    highlightColor: Colors.grey.withValues(alpha: 0.2),
                    child: Container(
                      height: 176.0,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                ),
              );
            } else if (state is CarError) {
              return Center(
                child: Text("Error: ${state.message}",
                    style: const TextStyle(color: Colors.red)),
              );
            } else if (state is CarLoaded) {
              final cars = state.cars;

              if (cars.isEmpty) {
                return const Center(
                  child: Text("No cars available right now.",
                      style: TextStyle(color: Colors.white)),
                );
              }

              return ListView.builder(
                itemCount: cars.length,
                itemBuilder: (final context, final index) {
                  final car = cars[index];
                  final isAsset = car.images.isNotEmpty &&
                      !car.images[0].startsWith('http');

                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CarDetailsScreen(
                            carData: car.toJson(),
                          ),
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(top: Dimens.largePadding),
                      child: Stack(
                        children: [
                          CustomPaint(
                            painter: CarListCardPainter(),
                            child: SizedBox(
                              height: 176.0,
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: Dimens.largePadding,
                                          ),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                  vertical: Dimens.largePadding,
                                                ),
                                                child: RateWidget(
                                                    rate: car.rating),
                                              ),
                                              const SizedBox(
                                                  height: Dimens.padding),
                                              AppTitleText(
                                                car.brand,
                                                fontSize: 14.0,
                                                color: AppColors.primaryColor,
                                              ),
                                              const SizedBox(
                                                  height: Dimens.padding),
                                              AppSubtitleText(
                                                car.name,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(
                                          top: Dimens.smallPadding,
                                          right: Dimens.largePadding,
                                        ),
                                        child: SizedBox(
                                          height: 105,
                                          width: 150,
                                          child: car.images.isNotEmpty
                                              ? (isAsset
                                                  ? Image.asset(car.images[0],
                                                      fit: BoxFit.contain)
                                                  : Image.network(car.images[0],
                                                      fit: BoxFit.contain))
                                              : const Icon(Icons.directions_car,
                                                  size: 50, color: Colors.grey),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(
                                        Dimens.largePadding),
                                    child: PriceWidget(
                                      price: car.price,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Positioned(
                            right: 10,
                            bottom: 1,
                            child: CircleAvatar(
                              radius: 28,
                              backgroundColor: AppColors.primaryColor,
                              child: AppSvgViewer(
                                Assets.icons.arrowRight,
                                color: AppColors.backgroundColor,
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  );
                },
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}
