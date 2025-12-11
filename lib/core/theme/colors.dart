import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const primaryColor = Color.fromARGB(255, 164, 179, 33);
  static const veryLightPrimaryColor = Color.fromARGB(255, 217, 226, 138);
  static const whiteColor = Color(0xffffffff);
  static const blackColor = Color(0xff000000);
  static const borderColor = Color(0xffDADBE1);
  static const backgroundColor = Color(0xff222222);
  static const grayColor = Color(0xff757575);
  static const lightGrayColor = Color(0xffD9D9D9);
  static const cardColor = Color(0xff373737);

  // --- NEW GRADIENT DEFINITIONS ---

  // Start: Slightly lighter than background (Use Card Color for cohesion)
  //static const gradientStart = Color(0xff373737);

  // End: Darker than background (Approaching Black)
  //static const gradientEnd = Color(0xff111111);

  //Option 2: If you want a subtle tint of your green brand in the background
  static const gradientStart =
      Color.fromARGB(255, 54, 59, 40); // Dark Greenish Grey
  static const gradientEnd = Color(0xff1A1C1E); // Dark Grey
}
