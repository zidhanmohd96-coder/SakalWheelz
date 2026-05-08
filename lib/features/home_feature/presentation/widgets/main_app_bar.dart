import 'package:car_rental_app/core/gen/assets.gen.dart';
import 'package:car_rental_app/core/theme/dimens.dart';
import 'package:car_rental_app/features/home_feature/presentation/widgets/user_location_widget.dart';
import 'package:car_rental_app/features/home_feature/presentation/widgets/user_profile_image_widget.dart';
import 'package:car_rental_app/features/home_feature/presentation/screens/features_screens/notifications_screen.dart';
import 'package:flutter/material.dart';

class MainAppBar extends StatelessWidget implements PreferredSizeWidget {
  const MainAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      actions: [
        Stack(
          alignment: Alignment.center,
          children: [
            IconButton(
              icon: const Icon(Icons.notifications_none, color: Colors.white, size: 28),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const NotificationsScreen()),
                );
              },
            ),
            Positioned(
              right: 12,
              top: 12,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                constraints: const BoxConstraints(minWidth: 10, minHeight: 10),
              ),
            ),
          ],
        ),
        const SizedBox(width: 8),
        const UserProfileImageWidget(),
      ],
      title: const Column(
        spacing: Dimens.padding,
        children: [
          UserLocationWidget(),
        ],
      ),
      leading: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: Dimens.largePadding,
        ),
        child: Image.asset(
          Assets.images.textLogo,
          alignment: Alignment.center,
          fit: BoxFit.contain,
        ),
      ),
      leadingWidth: 150.0,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(
        AppBar().preferredSize.height + 16.0,
      );
}
