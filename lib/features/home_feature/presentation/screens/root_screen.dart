import 'package:car_rental_app/core/managers/role_manager.dart';
import 'package:car_rental_app/features/home_feature/presentation/screens/home_screen.dart';
import 'package:car_rental_app/features/host_feature/presentation/screens/host_home_screen.dart';
import 'package:car_rental_app/features/driver_mode_feature/presentation/screens/driver_home_screen.dart';
import 'package:flutter/material.dart';

class RootScreen extends StatefulWidget {
  const RootScreen({super.key});

  @override
  State<RootScreen> createState() => _RootScreenState();
}

class _RootScreenState extends State<RootScreen> {
  final RoleManager _roleManager = RoleManager();

  @override
  void initState() {
    super.initState();
    _roleManager.addListener(_onRoleChanged);
  }

  @override
  void dispose() {
    _roleManager.removeListener(_onRoleChanged);
    super.dispose();
  }

  void _onRoleChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentMode = _roleManager.currentMode;

    Widget activeScreen;
    switch (currentMode) {
      case AppMode.host:
        activeScreen = const HostMainScreen(key: ValueKey("host_screen"));
        break;
      case AppMode.driver:
        activeScreen = const DriverHomeScreen(key: ValueKey("driver_screen"));
        break;
      case AppMode.customer:
      default:
        activeScreen = const HomeScreen(key: ValueKey("home_screen"));
        break;
    }

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 600),
      switchInCurve: Curves.easeInOut,
      switchOutCurve: Curves.easeInOut,
      transitionBuilder: (child, animation) {
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.05),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          ),
        );
      },
      child: activeScreen,
    );
  }
}
