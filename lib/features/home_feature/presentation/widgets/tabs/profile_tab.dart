import 'package:car_rental_app/features/home_feature/presentation/screens/features_screens/edit_profile_screen.dart';
import 'package:car_rental_app/features/home_feature/presentation/screens/features_screens/faq_screen.dart';
import 'package:car_rental_app/features/home_feature/presentation/screens/features_screens/feedback_screen.dart';
import 'package:car_rental_app/features/home_feature/presentation/screens/features_screens/my_documents_screen.dart';
import 'package:car_rental_app/features/home_feature/presentation/screens/features_screens/settings_screen.dart';
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

              const SizedBox(height: 30),

              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Account Settings",
                  style: TextStyle(
                    color: AppColors.whiteColor,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(height: 15),

              // ✅ NAVIGATION LOGIC IS HERE (Inside build)
              _buildMenuCard(
                icon: Icons.person_outline,
                title: "Edit Profile",
                onTap: () {
                  // context is available here because we are inside build()
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const EditProfileScreen()),
                  );
                },
              ),

              const SizedBox(height: 10),

              const SizedBox(height: 10),

// 2. NEW: My Documents
              _buildMenuCard(
                icon: Icons.assignment_ind_outlined, // ID Card Icon
                title: "My Documents",
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (c) => const MyDocumentsScreen()));
                },
              ),
              const SizedBox(height: 10),

              // 3. NEW: Settings
              _buildMenuCard(
                icon: Icons.settings_outlined,
                title: "Settings",
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (c) => const SettingsScreen()));
                },
              ),
              const SizedBox(height: 10),

// 4. NEW: Feedback
              _buildMenuCard(
                icon: Icons.mail_outline,
                title: "Feedback",
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (c) => const FeedbackScreen()));
                },
              ),
              const SizedBox(height: 10),

// 5. NEW: FAQ
              _buildMenuCard(
                icon: Icons.help_outline,
                title: "FAQ",
                onTap: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (c) => const FAQScreen()));
                },
              ),
              const SizedBox(height: 10),

              // We pass context to this helper method so it can show the dialog
              _buildLogoutButton(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader(User? user) {
    if (user == null) return const SizedBox();

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
              child: CircularProgressIndicator(color: AppColors.primaryColor));
        }

        String displayName = "Sakal User";
        String emailOrPhone = user.email ?? user.phoneNumber ?? "";
        String? photoUrl = user.photoURL;

        if (snapshot.hasData &&
            snapshot.data != null &&
            snapshot.data!.exists) {
          final data = snapshot.data!.data() as Map<String, dynamic>;
          if (data.containsKey('full_name')) {
            displayName = data['full_name'];
          }
          if (data.containsKey('profile_pic') && data['profile_pic'] != "") {
            photoUrl = data['profile_pic'];
          }
        }

        return Column(
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.primaryColor, width: 3),
              ),
              child: CircleAvatar(
                radius: 60,
                backgroundColor:
                    AppColors.veryLightPrimaryColor.withOpacity(0.3),
                backgroundImage:
                    photoUrl != null ? NetworkImage(photoUrl) : null,
                child: photoUrl == null
                    ? const Icon(Icons.person,
                        size: 60, color: AppColors.primaryColor)
                    : null,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              displayName,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.whiteColor,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              emailOrPhone,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.grayColor,
              ),
            ),
          ],
        );
      },
    );
  }

  // ✅ This method does NOT need context because it only sets up the UI
  // The 'onTap' logic is passed from the build method
  Widget _buildMenuCard({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: AppColors.primaryColor),
        ),
        title: Text(
          title,
          style: const TextStyle(
              fontWeight: FontWeight.w300, color: AppColors.whiteColor),
        ),
        trailing: const Icon(Icons.arrow_forward_ios,
            size: 14, color: AppColors.grayColor),
        onTap: onTap,
      ),
    );
  }

  // ✅ This method REQUIRES context to show the dialog, so we pass it in
  Widget _buildLogoutButton(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.red.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.red.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.red.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.logout, color: Colors.red),
        ),
        title: const Text(
          "Logout",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
        ),
        onTap: () => _showLogoutDialog(context),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Logout"),
        content: const Text("Are you sure you want to log out?"),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              await AuthService.signOut();

              // Check if context is still valid before using it
              if (context.mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const OnboardingScreen()),
                  (route) => false,
                );
              }
            },
            child: const Text("Logout"),
          ),
        ],
      ),
    );
  }
}
