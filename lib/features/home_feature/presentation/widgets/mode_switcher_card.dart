import 'package:car_rental_app/core/managers/role_manager.dart';
import 'package:car_rental_app/core/theme/colors.dart';
import 'package:car_rental_app/core/theme/dimens.dart';
import 'package:car_rental_app/core/widgets/app_title_text.dart';
import 'package:flutter/material.dart';

class ModeSwitcherCard extends StatelessWidget {
  const ModeSwitcherCard({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: RoleManager(),
      builder: (context, child) {
        final roleManager = RoleManager();

        // 1. Hide if user is only a basic customer (no roles yet)
        if (!roleManager.isDriver && !roleManager.isHost) {
          return const SizedBox.shrink();
        }

        // 2. Determine Current Status
        final bool isCustomerMode = roleManager.currentMode == AppMode.customer;
        final bool hasMultipleRoles =
            roleManager.isDriver && roleManager.isHost;

        // 3. Define UI Content based on state
        String title;
        String subtitle;
        IconData icon;
        Color color;
        VoidCallback onTap;

        if (isCustomerMode) {
          // --- CASE A: Currently Customer ---
          if (hasMultipleRoles) {
            // User is BOTH -> Generic "Switch Mode" that opens a selector
            title = "Switch Professional Mode";
            subtitle = "Access Driver or Host dashboard";
            icon = Icons.swap_vertical_circle;
            color = Colors.purpleAccent;
            onTap = () => _showModeSelector(context, roleManager);
          } else if (roleManager.isDriver) {
            // User is ONLY Driver
            title = "Switch to Driver Mode";
            subtitle = "Manage trips & earnings";
            icon = Icons.drive_eta;
            color = Colors.orangeAccent;
            onTap = () => _switch(context, roleManager, AppMode.driver);
          } else {
            // User is ONLY Host
            title = "Switch to Host Mode";
            subtitle = "List cars & manage rentals";
            icon = Icons.garage;
            color = Colors.blueAccent;
            onTap = () => _switch(context, roleManager, AppMode.host);
          }
        } else {
          // --- CASE B: Currently Driver or Host ---
          // Always switch back to Customer
          title = "Switch to Customer Mode";
          subtitle = "Find cars to rent";
          icon = Icons.search;
          color = AppColors.primaryColor;
          onTap = () => _switch(context, roleManager, AppMode.customer);
        }

        // 4. Render the Card
        return Container(
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: Dimens.largePadding),
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [color.withOpacity(0.8), color.withOpacity(0.3)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.cardColor,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: onTap,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(icon, color: color, size: 24),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AppTitleText(title, fontSize: 16),
                            const SizedBox(height: 4),
                            Text(
                              subtitle,
                              style: const TextStyle(
                                  color: Colors.grey, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.swap_horiz, color: Colors.white70),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // --- Helper: Perform Switch with Feedback ---
  void _switch(BuildContext context, RoleManager manager, AppMode mode) {
    manager.switchMode(mode);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Switched to ${mode.name.toUpperCase()} Mode"),
        duration: const Duration(milliseconds: 800),
        backgroundColor: AppColors.whiteColor.withOpacity(0.9),
      ),
    );
  }

  // --- Helper: Bottom Sheet for Users with Multiple Roles ---
  void _showModeSelector(BuildContext context, RoleManager manager) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const AppTitleText("Select Mode", fontSize: 18),
              const SizedBox(height: 24),
              // Driver Option
              if (manager.isDriver)
                ListTile(
                  leading:
                      const Icon(Icons.drive_eta, color: Colors.orangeAccent),
                  title: const Text("Driver Mode",
                      style: TextStyle(color: Colors.white)),
                  subtitle: const Text("Accept trips & earn",
                      style: TextStyle(color: Colors.grey)),
                  onTap: () {
                    Navigator.pop(context);
                    _switch(context, manager, AppMode.driver);
                  },
                ),
              // Host Option
              if (manager.isHost)
                ListTile(
                  leading: const Icon(Icons.garage, color: Colors.blueAccent),
                  title: const Text("Host Mode",
                      style: TextStyle(color: Colors.white)),
                  subtitle: const Text("Rent out your car",
                      style: TextStyle(color: Colors.grey)),
                  onTap: () {
                    Navigator.pop(context);
                    _switch(context, manager, AppMode.host);
                  },
                ),
            ],
          ),
        );
      },
    );
  }
}
