import 'package:car_rental_app/core/theme/colors.dart';
import 'package:car_rental_app/core/widgets/base_layout.dart';
import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _darkMode = false;

  @override
  Widget build(BuildContext context) {
    return BaseLayout(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text("Settings",
            style: TextStyle(color: AppColors.whiteColor)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.whiteColor),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      child: Container(
        color: Colors.transparent,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildSectionHeader("App Preferences"),
            SwitchListTile(
              title: const Text("Push Notifications"),
              subtitle: const Text("Receive updates about your bookings"),
              value: _notificationsEnabled,
              activeThumbColor: AppColors.primaryColor,
              onChanged: (val) => setState(() => _notificationsEnabled = val),
            ),
            SwitchListTile(
              title: const Text("Dark Mode"),
              subtitle: const Text("Switch app theme"),
              value: _darkMode,
              activeThumbColor: AppColors.primaryColor,
              onChanged: (val) => setState(() => _darkMode = val),
            ),
            const Divider(),
            _buildSectionHeader("Legal"),
            ListTile(
              title: const Text("Privacy Policy"),
              trailing: const Icon(Icons.arrow_forward_ios, size: 14),
              onTap: () {}, // TODO: Link to privacy policy
            ),
            ListTile(
              title: const Text("Terms & Conditions"),
              trailing: const Icon(Icons.arrow_forward_ios, size: 14),
              onTap: () {}, // TODO: Link to T&C
            ),
            const SizedBox(height: 20),
            const Center(
              child: Text(
                "App Version 1.0.0",
                style: TextStyle(color: Colors.grey),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Text(
        title,
        style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.primaryColor),
      ),
    );
  }
}
