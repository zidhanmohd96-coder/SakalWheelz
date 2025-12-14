import 'package:car_rental_app/core/gen/assets.gen.dart';
import 'package:car_rental_app/core/theme/colors.dart';
import 'package:car_rental_app/core/theme/dimens.dart';
import 'package:car_rental_app/core/widgets/app_svg_viewer.dart';
import 'package:car_rental_app/features/home_feature/presentation/bloc/bottom_navigation_cubit.dart';
import 'package:car_rental_app/features/home_feature/presentation/widgets/main_app_bar.dart';
import 'package:car_rental_app/features/home_feature/presentation/widgets/tabs/bookings_tab.dart';
import 'package:car_rental_app/features/home_feature/presentation/widgets/tabs/chat_tab.dart';
import 'package:car_rental_app/features/home_feature/presentation/widgets/tabs/home_tab.dart';
import 'package:car_rental_app/features/home_feature/presentation/widgets/tabs/profile_tab.dart';
import 'package:car_rental_app/features/home_feature/presentation/widgets/tabs/search_tab.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomeScreen extends StatefulWidget {
  final int initialIndex;

  // Ensure default is 0
  const HomeScreen({super.key, this.initialIndex = 0});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider<BottomNavigationCubit>(
      // FIX: Initialize the Cubit and immediately update it with the passed index
      create: (context) =>
          BottomNavigationCubit()..onItemTap(index: widget.initialIndex),
      child: const _HomeScreenContent(),
    );
  }
}

class _HomeScreenContent extends StatelessWidget {
  const _HomeScreenContent();

  @override
  Widget build(BuildContext context) {
    // Watch state to update UI
    final state = context.watch<BottomNavigationCubit>().state;
    // Read cubit to trigger events
    final read = context.read<BottomNavigationCubit>();

    final List<Widget> tabs = [
      const HomeTab(),
      const SearchTab(),
      const BookingTab(), // Make sure this is const or remove const if it has params
      const ChatTab(),
      const ProfileTab(),
    ];

    // Safety check: Ensure index doesn't go out of bounds
    final int safeIndex =
        state.selectedIndex >= tabs.length ? 0 : state.selectedIndex;

    return Scaffold(
      // Only show MainAppBar on Home Tab
      appBar: safeIndex == 0
          ? const PreferredSize(
              preferredSize: Size.fromHeight(80.0),
              child: MainAppBar(),
            )
          : null,
      body: tabs[safeIndex],
      bottomNavigationBar: ColoredBox(
        color: Colors.transparent,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(Dimens.corners * 2),
          child: BottomNavigationBar(
            backgroundColor: AppColors.cardColor.withOpacity(0.8),
            currentIndex: safeIndex,
            onTap: (final int index) {
              read.onItemTap(index: index);
            },
            type: BottomNavigationBarType.fixed,
            selectedItemColor: AppColors.primaryColor,
            unselectedItemColor: AppColors.whiteColor,
            items: <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: _buildIcon(Assets.icons.home, safeIndex == 0),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: _buildIcon(Assets.icons.search, safeIndex == 1),
                label: 'Search',
              ),
              BottomNavigationBarItem(
                icon: _buildIcon(Assets.icons.calendar, safeIndex == 2),
                label: 'Bookings',
              ),
              BottomNavigationBarItem(
                icon: _buildIcon(Assets.icons.mail, safeIndex == 3),
                label: 'Chat',
              ),
              BottomNavigationBarItem(
                icon: _buildIcon(Assets.icons.user, safeIndex == 4),
                label: 'Profile',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIcon(String assetPath, bool isSelected) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Dimens.padding),
      child: AppSvgViewer(
        assetPath,
        color: isSelected ? AppColors.primaryColor : AppColors.whiteColor,
      ),
    );
  }
}
