import 'package:car_rental_app/core/theme/dimens.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:car_rental_app/core/theme/colors.dart';

class UserProfileImageWidget extends StatelessWidget {
  const UserProfileImageWidget({
    super.key,
    this.width,
    this.height,
  });

  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;
    final String? photoUrl = user?.photoURL;
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: Dimens.padding,
      ),
      child: SizedBox(
        width: width ?? 48.0,
        height: height ?? 48.0,
        child: ClipOval(
          child: Container(
            color: AppColors.veryLightPrimaryColor,
            child: (photoUrl != null && photoUrl.isNotEmpty) 
              ? Image.network(
                  photoUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => const Icon(Icons.person, color: AppColors.primaryColor)
                )
              : const Icon(Icons.person, color: AppColors.primaryColor),
          ),
        ),
      ),
    );
  }
}
