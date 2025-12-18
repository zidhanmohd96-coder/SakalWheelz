import 'package:car_rental_app/core/managers/role_manager.dart';
import 'package:car_rental_app/core/theme/colors.dart';
import 'package:flutter/material.dart';

class CurrentModeBadge extends StatelessWidget {
  const CurrentModeBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: RoleManager(),
      builder: (context, child) {
        final mode = RoleManager().currentMode;

        Color color;
        String label;
        IconData icon;

        switch (mode) {
          case AppMode.driver:
            color = Colors.greenAccent;
            label = "Driver Mode Active";
            icon = Icons.drive_eta;
            break;
          case AppMode.host:
            color = Colors.blueAccent;
            label = "Host Mode Active";
            icon = Icons.garage;
            break;
          case AppMode.customer:
          default:
            color = AppColors.primaryColor;
            label = "Customer Mode";
            icon = Icons.person_outline;
            break;
        }

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: color.withOpacity(0.4), width: 1),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 14, color: color),
              const SizedBox(width: 8),
              Text(
                label.toUpperCase(),
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(width: 4),
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(color: color.withOpacity(0.5), blurRadius: 4)
                    ]),
              )
            ],
          ),
        );
      },
    );
  }
}
