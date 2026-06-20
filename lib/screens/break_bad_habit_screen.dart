import 'package:Demo/custom_widgets/custom_font_family.dart';
import 'package:Demo/custom_widgets/custom_scaffold.dart';
import 'package:Demo/screens/save_good_habit_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../providers/break_bad_habit_provider.dart';

class BreakBadHabitScreen extends StatefulWidget {
  const BreakBadHabitScreen({super.key});

  @override
  State<BreakBadHabitScreen> createState() => _BreakBadHabitScreenState();
}

class _BreakBadHabitScreenState extends State<BreakBadHabitScreen> {
  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          child: Column(
            children: [
              Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Icon(Icons.arrow_back, size: 30),
                  ),
                  SizedBox(width: 20),
                  Text(
                    "Break Bad Habit",
                    style: TextStyle(
                      color: Colors.black,
                      fontFamily: FontFamily.sfProMedium,
                      fontSize: 20,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 30),
              Consumer<BreakBadHabitProvider>(
                builder: (context, breakBadHabitProvider, child) {
                  return Expanded(
                    child: GridView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: breakBadHabitProvider.habitCategories.length,
                      gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 14,
                        mainAxisSpacing: 14,
                        childAspectRatio: 0.85,
                      ),
                      itemBuilder: (context, index) {
                        final habit = breakBadHabitProvider.habitCategories[index];

                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => SaveHabitScreen(),
                              ),
                            );
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: habit.color,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    habit.title,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),

                                  Expanded(
                                    child: Align(
                                      alignment: Alignment.bottomCenter,
                                      child: SvgPicture.asset(
                                        habit.image,
                                        height: 180,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
