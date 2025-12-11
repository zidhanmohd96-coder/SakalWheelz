// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:car_rental_app/core/gen/assets.gen.dart';
import 'package:car_rental_app/core/services/auth_gate_service.dart';
import 'package:car_rental_app/core/services/auth_service.dart';
import 'package:car_rental_app/core/theme/colors.dart';
import 'package:car_rental_app/features/authentication_feature/presentation/screens/mobile_login_screen.dart';
import 'package:flutter/material.dart';
import 'package:car_rental_app/core/widgets/base_layout.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Using media query for responsive sizing
    final size = MediaQuery.of(context).size;

    return BaseLayout(
      // We don't need an AppBar for this full-screen immersive experience
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Spacer to push content down slightly
              const Spacer(flex: 1),

              // 1. BRANDING SECTION
              // Replace with your actual branding image widget
              Image.asset(
                Assets.images.textLogo, // Use the logo from image_14.png
                height: 80, // Adjust height as needed
                fit: BoxFit.contain,
              ),

              const SizedBox(height: 40),

              // 2. WELCOME TEXT
              Text(
                "Let's Get Started",
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: AppColors.whiteColor,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 12),
              Text(
                "Sign up or log in to book your ride in minutes.",
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColors.lightGrayColor,
                    ),
              ),

              const Spacer(flex: 1),
              Image.asset(Assets.images.loginImage.path),

              // 3. MAIN ACTION BUTTONS

              // --- Option A: Continue with Phone (Primary Action) ---
              ElevatedButton(
                onPressed: () {
                  // TODO: Navigate to Phone OTP Screen
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const MobileLoginScreen(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  foregroundColor:
                      AppColors.blackColor, // Text color on primary button
                  minimumSize: Size(size.width, 56), // Full width, tall button
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 4,
                  shadowColor: AppColors.primaryColor.withOpacity(0.4),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.phone_android_rounded),
                    SizedBox(width: 12),
                    Text(
                      "Continue with Phone Number",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // --- Divider ---
              Row(
                children: [
                  const Expanded(child: Divider(color: AppColors.grayColor)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      "Or connect with",
                      style: TextStyle(color: AppColors.grayColor),
                    ),
                  ),
                  const Expanded(child: Divider(color: AppColors.grayColor)),
                ],
              ),

              const SizedBox(height: 24),

              // --- Option B: Continue with Google (Secondary Action) ---
              // Using an OutlinedButton style for secondary emphasis against the dark bg
              OutlinedButton(
                onPressed: () async {
                  // 1. Trigger Google Sign In
                  final userCredential =
                      await AuthService.signInWithGoogle(context);

                  // 2. If successful, Pass to Gate Service
                  if (userCredential != null && userCredential.user != null) {
                    await AuthGateService.checkUserAndNavigate(
                        context, userCredential.user!);
                  }
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.whiteColor,
                  minimumSize: Size(size.width, 56),
                  side:
                      BorderSide(color: AppColors.borderColor.withOpacity(0.5)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  backgroundColor: AppColors.cardColor
                      .withOpacity(0.3), // Slight glass effect
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Ensure you have the google_logo.png asset
                    Image.asset(
                      Assets.icons.googleLogo,
                      height: 24,
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      "Continue with Google",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(flex: 1),

              // 4. TERMS DISCLAIMER
              Padding(
                padding: const EdgeInsets.only(bottom: 24.0),
                child: RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: TextStyle(color: AppColors.grayColor, fontSize: 12),
                    children: [
                      const TextSpan(text: "By continuing, you agree to our "),
                      TextSpan(
                        text: "Terms of Service",
                        style: TextStyle(
                          color: AppColors.primaryColor,
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline,
                        ),
                        // Add tap handler later
                      ),
                      const TextSpan(text: " and "),
                      TextSpan(
                        text: "Privacy Policy",
                        style: TextStyle(
                          color: AppColors.primaryColor,
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline,
                        ),
                        // Add tap handler later
                      ),
                      const TextSpan(text: "."),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
