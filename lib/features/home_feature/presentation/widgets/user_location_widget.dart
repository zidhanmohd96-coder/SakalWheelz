import 'package:car_rental_app/core/gen/assets.gen.dart';
import 'package:car_rental_app/core/theme/colors.dart'; // Import for Text Color
import 'package:car_rental_app/core/theme/dimens.dart';
import 'package:car_rental_app/core/widgets/app_svg_viewer.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // 1. Add Firestore
import 'package:firebase_auth/firebase_auth.dart'; // 2. Add Auth
import 'package:flutter/material.dart';

class UserLocationWidget extends StatelessWidget {
  const UserLocationWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    // If no user is logged in, show default
    if (user == null) {
      return _buildLocationRow("Kerala, India");
    }

    // 3. StreamBuilder listens to database changes
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .snapshots(),
      builder: (context, snapshot) {
        String locationText = "Kerala, India"; // Default fallback

        if (snapshot.hasData &&
            snapshot.data != null &&
            snapshot.data!.exists) {
          final data = snapshot.data!.data() as Map<String, dynamic>;

          String city = data['location'] ?? '';
          String state = data['state'] ?? '';

          // Logic to construct string: "City, State" or just "City"
          if (city.isNotEmpty && state.isNotEmpty) {
            locationText = "$city, $state";
          } else if (city.isNotEmpty) {
            locationText = city;
          } else if (state.isNotEmpty) {
            locationText = state;
          }
        }

        return _buildLocationRow(locationText);
      },
    );
  }

  Widget _buildLocationRow(String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      // spacing: Dimens.padding, // Note: 'spacing' property in Row requires Flutter 3.24+. If using older flutter, use SizedBox.
      children: [
        AppSvgViewer(Assets.icons.location),
        const SizedBox(width: Dimens.padding), // Safe spacing
        Flexible(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 16.0,
              fontWeight: FontWeight.w500,
              color: AppColors.whiteColor, // Ensure text is visible
              overflow: TextOverflow
                  .ellipsis, // Prevent crash if location is too long
            ),
            maxLines: 1,
          ),
        ),
      ],
    );
  }
}
