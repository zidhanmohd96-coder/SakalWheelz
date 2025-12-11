import 'package:car_rental_app/core/services/auth_gate_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/material.dart';

class AuthService {
  // 1. Google Sign In

  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final GoogleSignIn _googleSignIn = GoogleSignIn();

  static Future<UserCredential?> signInWithGoogle(BuildContext context) async {
    try {
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await GoogleSignIn(
        clientId:
            "332266405888-gdp92g5nffv22jdpkcaavmbgqg9aoush.apps.googleusercontent.com",
      ).signIn();

      if (googleUser == null) return null; // User canceled the sign-in

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Create a new credential
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Once signed in, return the UserCredential
      final UserCredential userCredential =
          await _auth.signInWithCredential(credential);
      final User? user = userCredential.user;

      if (user != null) {
        // 🚀 CALL THE SAME AUTH GATE SERVICE
        // This will see it's Google, auto-save to DB, and go to Home.
        await AuthGateService.checkUserAndNavigate(context, user);
      }
    } catch (e) {
      print(e);
    }
    return null;
  }

  // 2. Logout
  static Future<void> signOut() async {
    try {
      // 1. Sign out from Google (Crucial for account switching)
      await _googleSignIn.signOut();

      // 2. Sign out from Firebase
      await _auth.signOut();
    } catch (e) {
      debugPrint("Error signing out: $e");
    }
  }
}
