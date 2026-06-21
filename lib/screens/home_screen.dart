import 'package:Demo/custom_widgets/custom_font_family.dart';
import 'package:Demo/custom_widgets/custom_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../custom_widgets/custom_colors.dart';
import '../providers/home_provider.dart';
import '../providers/mood_provider.dart';
import 'all_habits_screen.dart';
import 'greeting_screen.dart';
import 'mood_bottomsheet_screen.dart';
import 'new_areas_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<HomeProvider>(context);
    final greeting = provider.getGreeting();

    return CustomScaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            Image.asset('assets/images/login_top_logo_img.png', height: 65),
            // your Habit Tracker logo
            const SizedBox(width: 8),
            const Text(
              'Habit Hero',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A3D7C), // dark blue
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications_none, color: Color(0xFF4CAF50)),
            // green accent
            onPressed: () {},
          ),
          CircleAvatar(
            backgroundImage: AssetImage(
              'assets/images/mahdi-chaghari-3xTP_gWUlrg-unsplash.jpg',
            ),
            radius: 18,
          ),
          const SizedBox(width: 12),
        ],
      ),

      body: DefaultTabController(
        length: 3,
        initialIndex: provider.selectedTabIndex,
        child: Column(
          children: [
            TabBar(
              padding: EdgeInsets.symmetric(horizontal: 2),
              onTap: provider.changeTab,
              dividerColor: Colors.transparent,

              indicator: BoxDecoration(
                color: MyColors.cAppThemeTealGreen,
                borderRadius: BorderRadius.circular(30),
              ),

              indicatorSize: TabBarIndicatorSize.tab,

              labelColor: Colors.white,
              unselectedLabelColor: MyColors.darkNavyBlue,

              labelStyle: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),

              tabs: [
                Tab(
                  child: Row(
                    children: [
                      SvgPicture.asset(
                        "assets/icons/habits_icon.svg",
                        height: 22,
                        color: provider.selectedTabIndex == 0
                            ? Colors.white
                            : Colors.black,
                      ),
                      SizedBox(width: 5),
                      Text("All Habits"),
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(greeting.icon, size: 18),
                      const SizedBox(width: 5),
                      Flexible(
                        child: Text(
                          greeting.text,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    mainAxisSize: MainAxisSize.min, // 👈 IMPORTANT FIX
                    children: [
                      Icon(Icons.add, size: 22),
                      const SizedBox(width: 5),
                      Flexible(
                        child: Text(
                          "New Areas",
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Divider(),
            Expanded(
              child: TabBarView(
                children: [
                  AllHabitsScreen(),
                  GreetingScreen(greeting: provider.getGreeting()),
                  NewAreasScreen(),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: // ➕ BUTTON
      GestureDetector(
        onTap: () => _openBottomSheet(context),
        child: Container(
          height: 45,
          width: 45,
          decoration: BoxDecoration(
            color: Colors.teal,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }

  void _openBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Wrap(
          children: [
            ListTile(
              leading: Icon(Icons.track_changes, color: Colors.teal, size: 35,),
              title: Text(
                "Create Good Habit",
                style: TextStyle(
                  color: MyColors.darkNavyBlue,
                  fontSize: 20,
                  fontFamily: FontFamily.sfProMedium,
                ),
              ),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: Icon(Icons.remove_circle, color: Colors.red, size: 35,),
              title: Text("Break Bad Habit",  style: TextStyle(
                color: MyColors.darkNavyBlue,
                fontSize: 20,
                fontFamily: FontFamily.sfProMedium,
              ),),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: Icon(Icons.mood, color: Colors.orange, size: 35,),
              title: Text("Log Mood",  style: TextStyle(
                color: MyColors.darkNavyBlue,
                fontSize: 20,
                fontFamily: FontFamily.sfProMedium,
              ),),
                onTap: () {
                  Navigator.pop(context);
                  _openMoodBottomSheet(context);
                }
            ),
          ],
        );
      },
    );
  }

  void _openMoodBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return MoodBottomSheet();
      },
    ).whenComplete(() {});
  }
}
