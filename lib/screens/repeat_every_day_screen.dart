import 'package:Demo/custom_widgets/custom_scaffold.dart';
import 'package:Demo/providers/save_good_habit_provider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../custom_widgets/custom_colors.dart';
import '../custom_widgets/custom_font_family.dart';

class RepeatSection extends StatelessWidget {
  const RepeatSection({super.key});

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
              Text(
                "Repeat Every Day",
                style: TextStyle(
                  color: MyColors.kBlackColor,
                  fontFamily: FontFamily.sfProMedium,
                  fontSize: 17,
                ),
              ),

              // Radio buttons for Weekly / Interval / Monthly
              RadioListTile<String>(
                title: Text("Weekly"),
                value: "Weekly",
                groupValue: habitProvider.repeatType,
                onChanged: (val) => habitProvider.setRepeatType(val!),
              ),
              RadioListTile<String>(
                title: Text("Interval"),
                value: "Interval",
                groupValue: habitProvider.repeatType,
                onChanged: (val) => habitProvider.setRepeatType(val!),
              ),
              RadioListTile<String>(
                title: Text("Monthly"),
                value: "Monthly",
                groupValue: habitProvider.repeatType,
                onChanged: (val) => habitProvider.setRepeatType(val!),
              ),

              SizedBox(
                height: 10,
              ),
              Divider(),

              // Show corresponding widget
              if (habitProvider.repeatType == "Weekly")
                _buildWeeklyRepeat(habitProvider),
              if (habitProvider.repeatType == "Interval")
                _buildIntervalRepeat(habitProvider),
              if (habitProvider.repeatType == "Monthly")
                _buildMonthlyRepeat(habitProvider),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWeeklyRepeat(SaveGoodHabitProvider habitProvider) {
    List<String> days = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Text above the list
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Text(
            "Select the days you want this habit to repeat:",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),

        // The list of checkboxes
        Column(
          children: List.generate(7, (i) {
            return CheckboxListTile(
              title: Text(days[i]),
              value: habitProvider.weeklyDays[i],
              onChanged: (val) => habitProvider.toggleWeeklyDay(i, val!),
              controlAffinity: ListTileControlAffinity.leading,
            );
          }),
        ),

        // Text below the list
        Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Text(
            "Tip: You can select all days for a daily habit, or customize as needed.",
            style: TextStyle(fontSize: 14, color: Colors.grey[700]),
          ),
        ),
      ],
    );
  }

  Widget _buildIntervalRepeat(SaveGoodHabitProvider habitProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Customize your interval repetition:",
          style: TextStyle(
            fontFamily: FontFamily.sfProMedium,
            fontSize: 16,
            color: MyColors.kBlackColor,
          ),
        ),
        SizedBox(height: 12),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Repeat Every...",
              style: TextStyle(
                color: MyColors.kBlackColor,
                fontFamily: FontFamily.sfProRegular,
                fontSize: 15,
              ),
            ),
            Row(
              children: [
                ConstrainedBox(
                  constraints: const BoxConstraints(
                    minWidth: 80,
                    maxWidth: 90,
                    minHeight: 36,
                  ),

                  child: IntrinsicWidth(
                    child: TextField(
                      keyboardType: TextInputType.number,

                      textAlign: TextAlign.center,

                      onChanged: (value) {
                        habitProvider.setIntervalDays(int.tryParse(value) ?? 1);
                      },

                      style: TextStyle(
                        fontFamily: FontFamily.sfProSemiBold,
                        fontSize: 14,
                        color: MyColors.kPureBlackColor,
                      ),

                      decoration: InputDecoration(
                        hintText: "2",

                        hintStyle: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade400,
                        ),

                        isDense: true,

                        /// REMOVE DEFAULT PADDING
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 8,
                        ),

                        filled: true,
                        fillColor: Colors.grey.shade100,

                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),

                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),

                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 5),
                Text(
                  "days",
                  style: TextStyle(
                    color: MyColors.kBlackColor,
                    fontFamily: FontFamily.sfProRegular,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ],
        ),
        SizedBox(height: 10),
        Divider(),
        SizedBox(height: 20),
        Text(
          "Upcoming Dates:",
          style: TextStyle(
            color: MyColors.kBlackColor,
            fontFamily: FontFamily.sfProMedium,
            fontSize: 17,
          ),
        ),
        SizedBox(height: 20),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: habitProvider.upcomingDates.map((date) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Text(
                    DateFormat.E().add_yMMMd().format(date),
                    style: TextStyle(
                      fontFamily: FontFamily.sfProMedium,
                      color: MyColors.kBlackColor,
                      fontSize: 15,
                    ),
                  ),
                ),
                Divider(thickness: 1, color: Colors.grey.shade300),
              ],
            );
          }).toList(),
        ),

        SizedBox(height: 20),

        // Text at the end of the column
        Text(
          "Tip: Adjust the interval to see how upcoming dates change dynamically.",
          style: TextStyle(
            fontFamily: FontFamily.sfProRegular,
            fontSize: 14,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildMonthlyRepeat(SaveGoodHabitProvider habitProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

      // Text at the start of the column
      Text(
      "Choose specific dates of the month:",
      style: TextStyle(
        fontFamily: FontFamily.sfProMedium,
        fontSize: 16,
        color: MyColors.kBlackColor,
      ),
    ),
    SizedBox(height: 12),
    CheckboxListTile(
          title: Text("Select All Dates"),
          value: habitProvider.selectAllDates,
          onChanged: (val) => habitProvider.toggleSelectAllDates(val!),
        ),
        Wrap(
          spacing: 6,
          children: List.generate(31, (i) {
            int day = i + 1;
            return ChoiceChip(
              label: Text("$day"),
              selected: habitProvider.selectedDates.contains(day),
              onSelected: (val) => habitProvider.toggleMonthlyDate(day, val),
            );
          }),
        ),

        SizedBox(height: 20),

        // Text at the end of the column
        Text(
          "Note: If a selected date doesn’t exist in a month (e.g., 31st in February), it will be skipped automatically.",
          style: TextStyle(
            fontFamily: FontFamily.sfProRegular,
            fontSize: 14,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }
}
