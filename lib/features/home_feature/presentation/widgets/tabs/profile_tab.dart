import 'package:car_rental_app/features/home_feature/presentation/screens/features_screens/edit_profile_screen.dart';
import 'package:car_rental_app/features/home_feature/presentation/screens/features_screens/faq_screen.dart';
import 'package:car_rental_app/features/home_feature/presentation/screens/features_screens/feedback_screen.dart';
import 'package:car_rental_app/features/home_feature/presentation/screens/features_screens/my_documents_screen.dart';
import 'package:car_rental_app/features/home_feature/presentation/screens/features_screens/settings_screen.dart';
import 'package:car_rental_app/features/home_feature/presentation/screens/features_screens/become_host_screen.dart';
import 'package:car_rental_app/features/home_feature/presentation/screens/features_screens/become_driver_screen.dart';
import 'package:car_rental_app/features/home_feature/presentation/widgets/current_mode_badge.dart';
import 'package:car_rental_app/features/home_feature/presentation/widgets/mode_switcher_card.dart';
import 'package:car_rental_app/features/onboarding_feature/presentation/screen/onboarding_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:car_rental_app/core/theme/colors.dart';
import 'package:car_rental_app/core/services/auth_service.dart';

class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Column(
            children: [
              _buildProfileHeader(user),

              const SizedBox(height: 8),

              const CurrentModeBadge(),

              const SizedBox(height: 32),

              const ModeSwitcherCard(),

              const SizedBox(height: 30),

              // --- NEW: START EARNING SECTION (Inspired by Screenshot) ---
              const Align(
                alignment: Alignment.centerLeft,
                child: Text("Start Earning",
                    style: TextStyle(
                        color: AppColors.whiteColor,
                        fontSize: 18,
                        fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 15),

              // HOST CARD
              _buildEarningCard(
                context,
                title: "Host",
                subtitle: "List your vehicles and earn money",
                icon: Icons.business,
                features: [
                  "List unlimited vehicles",
                  "Set your own prices",
                  "Digital agreements"
                ],
                btnText: "List Your Car",
                color: Colors.blueAccent,
                onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (c) => const BecomeHostScreen())),
              ),

              const SizedBox(height: 16),

              // DRIVER CARD
              _buildEarningCard(
                context,
                title: "Driver",
                subtitle: "Offer your driving services",
                icon: Icons.work_outline,
                features: [
                  "Accept ride requests",
                  "Flexible working hours",
                  "Instant payouts"
                ],
                btnText: "Register as Driver",
                color: AppColors.primaryColor,
                onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (c) => const BecomeDriverScreen())),
              ),
              const SizedBox(height: 30),
              // ---------------------------------------------------------

              const Align(
                alignment: Alignment.centerLeft,
                child: Text("Account Settings",
                    style: TextStyle(
                        color: AppColors.whiteColor,
                        fontSize: 18,
                        fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 15),

              _buildMenuCard(
                  icon: Icons.person_outline,
                  title: "Edit Profile",
                  onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (c) => const EditProfileScreen()))),
              const SizedBox(height: 10),
              _buildMenuCard(
                  icon: Icons.assignment_ind_outlined,
                  title: "My Documents",
                  onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (c) => const MyDocumentsScreen()))),
              const SizedBox(height: 10),
              _buildMenuCard(
                  icon: Icons.settings_outlined,
                  title: "Settings",
                  onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (c) => const SettingsScreen()))),
              const SizedBox(height: 10),
              _buildMenuCard(
                  icon: Icons.mail_outline,
                  title: "Feedback",
                  onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (c) => const FeedbackScreen()))),
              const SizedBox(height: 10),
              _buildMenuCard(
                  icon: Icons.help_outline,
                  title: "FAQ",
                  onTap: () => Navigator.push(context,
                      MaterialPageRoute(builder: (c) => const FAQScreen()))),
              const SizedBox(height: 10),
              _buildLogoutButton(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEarningCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required List<String> features,
    required String btnText,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12)),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold)),
                  Text(subtitle,
                      style:
                          TextStyle(color: Colors.grey.shade400, fontSize: 12)),
                ],
              )
            ],
          ),
          const SizedBox(height: 16),
          ...features.map((f) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Icon(Icons.check_circle_outline, color: color, size: 16),
                    const SizedBox(width: 8),
                    Text(f,
                        style: const TextStyle(
                            color: Colors.white70, fontSize: 13)),
                  ],
                ),
              )),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 44,
            child: ElevatedButton(
              onPressed: onTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: color,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(btnText,
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  // ... (Keep existing _buildProfileHeader, _buildMenuCard, _buildLogoutButton)
  Widget _buildProfileHeader(User? user) {
    /* Copy previous code */
    if (user == null) return const SizedBox();
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .snapshots(),
      builder: (context, snapshot) {
        String displayName = "User";
        String emailOrPhone = user.email ?? "";
        String? photoUrl = user.photoURL;
        if (snapshot.hasData && snapshot.data!.exists) {
          final data = snapshot.data!.data() as Map<String, dynamic>;
          displayName = data['full_name'] ?? displayName;
          photoUrl = data['profile_pic'] ?? photoUrl;
        }
        return Column(
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.primaryColor, width: 2)),
              child: CircleAvatar(
                  radius: 50,
                  backgroundImage:
                      photoUrl != null ? NetworkImage(photoUrl) : null,
                  child: photoUrl == null
                      ? const Icon(Icons.person, size: 50)
                      : null),
            ),
            const SizedBox(height: 12),
            Text(displayName,
                style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white)),
            Text(emailOrPhone,
                style: const TextStyle(fontSize: 14, color: Colors.grey)),
          ],
        );
      },
    );
  }

  Widget _buildMenuCard(
      {required IconData icon,
      required String title,
      required VoidCallback onTap}) {
    return ListTile(
      tileColor: AppColors.cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      leading: Icon(icon, color: AppColors.primaryColor),
      title: Text(title, style: const TextStyle(color: Colors.white)),
      trailing:
          const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
      onTap: onTap,
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return ListTile(
      tileColor: AppColors.cardColor,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Colors.red.withOpacity(0.2))),
      leading: const Icon(Icons.logout, color: Colors.red),
      title: const Text("Logout",
          style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
      onTap: () => AuthService.signOut().then((_) =>
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const OnboardingScreen()),
              (r) => false)),
    );
  }
}
