import 'dart:async';
import 'package:car_rental_app/core/gen/assets.gen.dart';
import 'package:car_rental_app/core/managers/role_manager.dart';
import 'package:car_rental_app/core/providers/mode_provider.dart';
import 'package:car_rental_app/features/home_feature/presentation/screens/home_screen.dart';
import 'package:car_rental_app/features/host_feature/presentation/screens/host_home_screen.dart';
import 'package:car_rental_app/features/host_feature/presentation/tabs/host_dashboard_tab.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:car_rental_app/features/onboarding_feature/presentation/screen/onboarding_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );
    _animationController.forward();
    _initializeApp();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _initializeApp() async {
    // ⏱️ Simulating app loading (checking token, configs, etc.)
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      // 2. CHECK LOGIN STATUS HERE
      User? user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        // ✅ User is Logged In - Fetch Roles from Firestore
        try {
          DocumentSnapshot userDoc = await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .get();

          if (userDoc.exists) {
            final data = userDoc.data() as Map<String, dynamic>;

            // Debug Print to check what's coming from Firebase
            print("🔥 FIREBASE DATA: $data");

            // Safely get booleans (handling nulls)
            bool isDriver = data['is_driver_verified'] == true;
            bool isHost = data['is_host_verified'] == true;

            // ⚡ UPDATE THE MANAGER
            RoleManager().setRoles(isDriver: isDriver, isHost: isHost);
            print("✅ RoleManager Updated: Driver=$isDriver, Host=$isHost");
          }
        } catch (e) {
          print("⚠️ Error fetching user roles: $e");
        }

        // 3. Navigate to MAIN WRAPPER (Not HomeScreen)
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HomeScreen()),
          );
        }
      } else {
        // ❌ No User - Go to Onboarding
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const OnboardingScreen()),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1C1E), // Carbon Black
      body: FadeTransition(
        opacity: _animation,
        child: Center(
          child: Image.asset(
            Assets.images.splashLogo.path,
            fit: BoxFit.contain,
            width: MediaQuery.of(context).size.width * 0.6,
          ),
        ),
      ),
    );
  }
}
