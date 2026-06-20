import 'package:Demo/custom_widgets/custom_colors.dart';
import 'package:Demo/custom_widgets/custom_font_family.dart';
import 'package:Demo/custom_widgets/custom_scaffold.dart';
import 'package:Demo/providers/save_good_habit_provider.dart';
import 'package:Demo/screens/repeat_every_day_screen.dart';
import 'package:Demo/screens/time_management_screen.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class SaveHabitScreen extends StatelessWidget {
  const SaveHabitScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final habitProvider = Provider.of<SaveGoodHabitProvider>(context);

    return CustomScaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: Text("Save Habit"), backgroundColor: Colors.white),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Repeat Section
              GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => RepeatSection()),
                  );
                },
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(width: 1, color: Colors.black),
                  ),
                  child: Text(
                    "Repeat Every Day",
                    style: TextStyle(
                      color: MyColors.kBlackColor,
                      fontFamily: FontFamily.sfProMedium,
                      fontSize: 17,
                    ),
                  ),
                ),
              ),

              SizedBox(height: 20),

              // Time Management
              GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TimeManagementScreen(),
                    ),
                  );
                },
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(width: 1, color: Colors.black),
                  ),
                  child: Text(
                    "Time Management",
                    style: TextStyle(
                      color: MyColors.kBlackColor,
                      fontFamily: FontFamily.sfProMedium,
                      fontSize: 17,
                    ),
                  ),
                ),
              ),

              SizedBox(height: 20),

              // Reminders
              Container(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(width: 1, color: Colors.black),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Remind Me At",
                      style: TextStyle(
                        color: MyColors.kBlackColor,
                        fontFamily: FontFamily.sfProMedium,
                        fontSize: 17,
                      ),
                    ),
                    SizedBox(height: 5),
                    Divider(),
                    SizedBox(height: 5),
                    Column(
                      children: habitProvider.reminders.map((reminder) {
                        return ListTile(
                          contentPadding: EdgeInsets.symmetric(horizontal: 10),
                          title: Text(reminder.format(context)),
                          trailing: IconButton(
                            icon: Icon(Icons.delete, color: Colors.redAccent),
                            onPressed: () {
                              habitProvider.removeReminder(reminder);
                            },
                          ),
                        );
                      }).toList(),
                    ),
                    Align(
                      alignment: AlignmentGeometry.centerEnd,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadiusGeometry.circular(10),
                            side: BorderSide(
                              width: 1,
                              color: MyColors.kBlackColor,
                            ),
                          ),
                          backgroundColor: Colors.blue.shade300,
                        ),
                        child: Text(
                          "Add Reminder",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontFamily: FontFamily.sfProMedium,
                          ),
                        ),
                        onPressed: () async {
                          TimeOfDay? picked = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.now(),
                          );
                          if (picked != null) habitProvider.addReminder(picked);
                        },
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 20),

              // Start Date
              Container(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(width: 1, color: Colors.black),
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(15),
                  onTap: () async {
                    DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2100),
                    );
                    if (picked != null) habitProvider.setStartDate(picked);
                  },
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              "Starts From",
                              style: TextStyle(
                                color: MyColors.kBlackColor,
                                fontFamily: FontFamily.sfProMedium,
                                fontSize: 17,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              habitProvider.startDate == null
                                  ? "Not selected"
                                  : DateFormat.yMMMd().format(
                                      habitProvider.startDate!,
                                    ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.calendar_today),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 20),

              // End Date
              Container(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(width: 1, color: Colors.black),
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(15),
                  onTap: () async {
                    DateTime firstDate =
                        habitProvider.startDate ?? DateTime.now();
                    DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: firstDate,
                      firstDate: firstDate, // restrict to startDate or later
                      lastDate: DateTime(2100),
                    );
                    if (picked != null) habitProvider.setEndDate(picked);
                  },
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              "End Date",
                              style: TextStyle(
                                color: MyColors.kBlackColor,
                                fontFamily: FontFamily.sfProMedium,
                                fontSize: 17,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              habitProvider.endDate == null
                                  ? "Not selected"
                                  : DateFormat.yMMMd().format(
                                      habitProvider.endDate!,
                                    ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.calendar_today),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
