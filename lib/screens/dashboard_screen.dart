import 'package:Demo/custom_widgets/custom_colors.dart';
import 'package:Demo/screens/profile_screen.dart';
import 'package:Demo/screens/progress_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../custom_widgets/custom_font_family.dart';
import '../providers/dashboard_provider.dart';
import 'badges_and_rewards_screen.dart';
import 'home_screen.dart';
import 'leaderboard_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<DashboardProvider>(context);

    final List<Widget> screens = [
      const HomeScreen(),
      const ProgressScreen(),
      const BadgesAndRewardsScreen(),
      const LeaderboardScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      body: screens[provider.currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: MyColors.kWhiteColor,
        selectedItemColor: MyColors.cAppThemeTealGreen,
        unselectedItemColor: Colors.black45,
        selectedLabelStyle: TextStyle(
          fontFamily: FontFamily.sfProSemiBold,
          color: MyColors.kAppThemeColor,
          fontSize: 14,
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: 14,
          // color: MyColors.kMaroonColor,
          color: Colors.red,
          fontFamily: FontFamily.sfProMedium,
        ),
        currentIndex: provider.currentIndex,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          provider.changeIndex(index);
        },
        items: [
          BottomNavigationBarItem(
            icon: SvgPicture.asset(
              provider.currentIndex == 0
                  ? "assets/icons/home_selected_icon.svg"
                  : "assets/icons/home_unselected_icon.svg",
              height: 22,
              color: provider.currentIndex == 0 ? MyColors.cAppThemeTealGreen : Colors.black45,
            ),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: SvgPicture.asset(
              provider.currentIndex == 1
                  ? "assets/icons/progress_selected_icon.svg"
                  : "assets/icons/progress_unselected_icon.svg",
              height: 22,
              color: provider.currentIndex == 1 ? MyColors.cAppThemeTealGreen : Colors.black45,
            ),
            label: "Progress",
          ),
          BottomNavigationBarItem(
            icon: SvgPicture.asset(
              provider.currentIndex == 2
                  ? "assets/icons/badges_and_rewards_selected_icon.svg"
                  : "assets/icons/badges_and_rewards_unselected_icon.svg",
              height: 22,
              color: provider.currentIndex == 2 ? MyColors.cAppThemeTealGreen : Colors.black45,
            ),
            label: "Badges", // No text for center
          ),
          BottomNavigationBarItem(
            icon: SvgPicture.asset(
              provider.currentIndex == 3
                  ? "assets/icons/leaderboard_selected_icon.svg"
                  : "assets/icons/leaderboard_unselected_icon.svg",
              height: 22,
              color: provider.currentIndex == 3 ? null : Colors.black45,
            ),
            label: "Leaderboard",
          ),
          BottomNavigationBarItem(
            icon: SvgPicture.asset(
              provider.currentIndex == 4
                  ? "assets/icons/profile_selected_icon.svg"
                  : "assets/icons/profile_unselected_icon.svg",
              height: 22,
              color: provider.currentIndex == 4 ? MyColors.cAppThemeTealGreen : Colors.black45,
            ),
            label: "Profile",
          ),
        ],
      ),
    );
  }
}
