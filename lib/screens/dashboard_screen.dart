import 'package:Demo/custom_widgets/custom_colors.dart';
import 'package:Demo/screens/habit_creation_screen.dart';
import 'package:Demo/screens/dashboard_home_screen.dart';
import 'package:Demo/screens/profile_screen.dart';
import 'package:Demo/screens/progress_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../providers/dashboard_provider.dart';
import 'badges_and_rewards_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<DashboardProvider>(context);

    final List<Widget> screens = [
      const DashboardHomeScreen(),
      const ProgressScreen(),
      const BadgesAndRewardsScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      backgroundColor: MyColors.neutralGray,
      body: screens[provider.currentIndex],
      floatingActionButton: provider.currentIndex == 0
          ? FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const HabitCreationScreen(),
                  ),
                );
              },
              backgroundColor: MyColors.primaryBlue,
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.add, color: Colors.white, size: 28),
            )
          : null,
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: MyColors.kWhiteColor,
        selectedItemColor: MyColors.primaryBlue,
        unselectedItemColor: MyColors.kDescriptionColor,
        selectedLabelStyle: GoogleFonts.poppins(
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
        unselectedLabelStyle: GoogleFonts.poppins(
          fontWeight: FontWeight.w500,
          fontSize: 12,
        ),
        currentIndex: provider.currentIndex,
        type: BottomNavigationBarType.fixed,
        onTap: provider.changeIndex,
        items: [
          BottomNavigationBarItem(
            icon: SvgPicture.asset(
              provider.currentIndex == 0
                  ? 'assets/icons/home_selected_icon.svg'
                  : 'assets/icons/home_unselected_icon.svg',
              height: 22,
              color: provider.currentIndex == 0
                  ? MyColors.primaryBlue
                  : MyColors.kDescriptionColor,
            ),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: SvgPicture.asset(
              provider.currentIndex == 1
                  ? 'assets/icons/progress_selected_icon.svg'
                  : 'assets/icons/progress_unselected_icon.svg',
              height: 22,
              color: provider.currentIndex == 1
                  ? MyColors.primaryBlue
                  : MyColors.kDescriptionColor,
            ),
            label: 'Progress',
          ),
          BottomNavigationBarItem(
            icon: SvgPicture.asset(
              provider.currentIndex == 2
                  ? 'assets/icons/badges_and_rewards_selected_icon.svg'
                  : 'assets/icons/badges_and_rewards_unselected_icon.svg',
              height: 22,
              color: provider.currentIndex == 2
                  ? MyColors.primaryBlue
                  : MyColors.kDescriptionColor,
            ),
            label: 'Rewards',
          ),
          BottomNavigationBarItem(
            icon: SvgPicture.asset(
              provider.currentIndex == 3
                  ? 'assets/icons/profile_selected_icon.svg'
                  : 'assets/icons/profile_unselected_icon.svg',
              height: 22,
              color: provider.currentIndex == 3
                  ? MyColors.primaryBlue
                  : MyColors.kDescriptionColor,
            ),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
