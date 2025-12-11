import 'dart:async';
import 'package:car_rental_app/core/gen/assets.gen.dart';
import 'package:car_rental_app/features/home_feature/presentation/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

// ✅ IMPORT YOUR ONBOARDING SCREEN HERE
// Ensure the path matches where you saved the file
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
        // ✅ User is ALREADY logged in -> Go to Home
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => const HomeScreen()), // Your Home Page
        );
      } else {
        // ❌ User is NOT logged in -> Go to Login/Onboarding
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const OnboardingScreen()),
        );
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
