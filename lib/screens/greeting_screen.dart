import 'package:Demo/custom_widgets/custom_colors.dart';
import 'package:Demo/custom_widgets/custom_font_family.dart';
import 'package:Demo/custom_widgets/custom_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../models/greeting_model.dart';
import '../providers/home_provider.dart';
import 'build_a_habit_screen.dart';

// make sure this import exists
// import your provider/model file where GreetingData is defined

class GreetingScreen extends StatefulWidget {
  final GreetingData greeting;

  const GreetingScreen({super.key, required this.greeting});

  @override
  State<GreetingScreen> createState() => _GreetingScreenState();
}

class _GreetingScreenState extends State<GreetingScreen> {

  ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<HomeProvider>();

      provider.resetToToday();
      _centerToday();
    });
  }

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Image.asset("assets/images/home_welcome_boy_img.png"),
            SizedBox(height: 15),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal.shade500,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadiusGeometry.circular(15),
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                    ),
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => BuildAHabitScreen(),));
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SvgPicture.asset(
                          "assets/icons/build_a_habit_icon.svg",
                          height: 25,
                          color: Colors.white,
                        ),
                        SizedBox(width: 10),
                        Text(
                          "Build a Habit",
                          style: TextStyle(
                            color: MyColors.kWhiteColor,
                            fontSize: 17,
                            fontFamily: FontFamily.sfProSemiBold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade500,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadiusGeometry.circular(15),
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                    ),
                    onPressed: () {},
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SvgPicture.asset(
                          "assets/icons/break_bad_habit_icon.svg",
                          height: 25,
                          color: Colors.white,
                        ),
                        SizedBox(width: 10),
                        Text(
                          "Break Bad Habit",
                          style: TextStyle(
                            color: MyColors.kWhiteColor,
                            fontSize: 17,
                            fontFamily: FontFamily.sfProSemiBold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Text(
                "Join millions building better habits with Habit Tracker",
                style: TextStyle(
                  fontFamily: FontFamily.sfProMedium,
                  fontSize: 15,
                  color: Colors.black38,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: 15),
            Consumer<HomeProvider>(
              builder: (context, provider, child) {
                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Today’s Progress",
                        style: TextStyle(
                          fontSize: 16,
                          fontFamily: FontFamily.sfProSemiBold,
                        ),
                      ),

                      SizedBox(height: 10),

                      Container(
                        padding: EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(color: Colors.black12, blurRadius: 10),
                          ],
                        ),
                        child: Column(
                          children: [
                            Container(
                              height: 12,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade300,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Stack(
                                children: [
                                  // Background track
                                  Container(
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade300,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                  ),

                                  // Progress fill (FULLY rounded)
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: LayoutBuilder(
                                      builder: (context, constraints) {
                                        return Container(
                                          width:
                                              constraints.maxWidth *
                                              provider.getProgress(),
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(
                                              20,
                                            ), // 👈 key fix
                                            gradient: LinearGradient(
                                              colors: [
                                                Colors.teal.shade200,
                                                Colors.teal.shade700,
                                              ],
                                              begin: Alignment.centerLeft,
                                              end: Alignment.centerRight,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            SizedBox(height: 10),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  provider.getProgressText(),
                                  style: TextStyle(fontSize: 13),
                                ),
                                Text(
                                  "${(provider.getProgress() * 100).toInt()}%",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.teal,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            SizedBox(height: 10),

            Padding(
              padding: const EdgeInsets.only(right: 0),
              child: Consumer<HomeProvider>(
                builder: (context, provider, child) {
                  DateTime now = DateTime.now();
                  int currentWeekday = now.weekday;
                  DateTime monday = now.subtract(
                    Duration(days: currentWeekday - 1),
                  );

                  List<DateTime> week = List.generate(
                    7,
                    (i) => monday.add(Duration(days: i)),
                  );

                  List<String> labels = [
                    "Mon",
                    "Tue",
                    "Wed",
                    "Thu",
                    "Fri",
                    "Sat",
                    "Sun",
                  ];

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 70,
                            child: ListView.builder(
                              controller: _scrollController,
                              scrollDirection: Axis.horizontal,
                              itemCount: 7,
                              itemBuilder: (context, index) {
                                final date = week[index];
                                final isSelected =
                                    provider.selectedDate.day == date.day &&
                                    provider.selectedDate.month == date.month;

                                return GestureDetector(
                                  onTap: () => provider.changeDate(date),
                                  child: Container(
                                    width: 55,
                                    margin: EdgeInsets.only(right: 8),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(15),
                                      color: isSelected
                                          ? Colors.teal.shade600
                                          : Colors.grey.shade200,
                                    ),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          labels[index],
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: isSelected
                                                ? Colors.white
                                                : Colors.black54,
                                          ),
                                        ),
                                        SizedBox(height: 5),
                                        Text(
                                          "${date.day}",
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: isSelected
                                                ? Colors.white
                                                : Colors.black,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  void _centerToday() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;

      DateTime now = DateTime.now();
      int weekday = now.weekday;

      double itemWidth = 63;

      double screenWidth = MediaQuery.of(context).size.width;

      double offset =
          (weekday - 1) * itemWidth - (screenWidth / 2) + (itemWidth / 2);

      _scrollController.animateTo(
        offset.clamp(0.0, _scrollController.position.maxScrollExtent),
        duration: Duration(milliseconds: 500),
        curve: Curves.easeOut,
      );
    });
  }
}
