import 'package:flutter/material.dart';
import 'package:car_rental_app/core/theme/colors.dart'; // Import your colors

class BaseLayout extends StatelessWidget {
  final Widget child;
  final AppBar? appBar;
  final Widget? bottomNavigationBar;
  final Widget? bottomSheet;
  final bool extendBody;

  const BaseLayout({
    super.key,
    required this.child,
    this.appBar,
    this.bottomNavigationBar,
    this.bottomSheet,
    this.extendBody = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      // 🎨 THIS IS WHERE THE GRADIENT MAGIC HAPPENS
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.gradientStart, // #373737
            AppColors.backgroundColor, // #222222 (Middle stop for smoothness)
            AppColors.gradientEnd, // #111111
          ],
          // This creates a smooth transition
          stops: [0.0, 0.5, 1.0],
        ),
      ),
      child: Scaffold(
        // ⚠️ IMPORTANT: Make Scaffold transparent so gradient shows through
        backgroundColor: Colors.transparent,
        appBar: appBar,
        bottomNavigationBar: bottomNavigationBar,
        bottomSheet: bottomSheet,
        extendBody: extendBody,
        body: child,
      ),
    );
  }
}
