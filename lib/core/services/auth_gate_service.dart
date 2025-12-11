import 'package:car_rental_app/features/authentication_feature/presentation/screens/user_registration_screen.dart';
import 'package:car_rental_app/features/home_feature/presentation/screens/home_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthGateService {
  /// Main function to check user status and route them correctly
  static Future<void> checkUserAndNavigate(
      BuildContext context, User user) async {
    try {
      // 1. Check if user document exists in Firestore
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      // 2. Check if the profile is "Complete" (Has a name)
      if (userDoc.exists &&
          userDoc.data() != null &&
          userDoc.data()!.containsKey('full_name') &&
          userDoc.get('full_name') != null &&
          (userDoc.get('full_name') as String).isNotEmpty) {
        // ✅ EXISTING USER: Go to Home
        debugPrint("User exists. Navigating to Home.");
        _navigateToHome(context);
      } else {
        // 🆕 NEW or INCOMPLETE USER
        debugPrint("New user detected. Checking provider...");

        // 3. Check Login Provider
        if (user.providerData.any((info) => info.providerId == 'google.com')) {
          // 🔵 GOOGLE: Auto-register using Google data
          await _autoRegisterGoogleUser(user);
          _navigateToHome(context);
        } else {
          // 🟡 PHONE: Must manually register
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => const UserRegistrationScreen()),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Login Error: $e")));
    }
  }

  /// Helper to save Google User data automatically
  static Future<void> _autoRegisterGoogleUser(User user) async {
    await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
      'uid': user.uid,
      'full_name': user.displayName ?? "User",
      'email': user.email ?? "",
      'phone_number': user.phoneNumber ?? "",
      'profile_pic': user.photoURL ?? "",
      'role': 'customer',
      'created_at': FieldValue.serverTimestamp(),
      'is_host_verified': false,
      'is_driver_verified': false,
    }, SetOptions(merge: true));
  }

  static void _navigateToHome(BuildContext context) {
    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
        (route) => false);
  }
}
