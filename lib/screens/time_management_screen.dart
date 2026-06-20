import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/save_good_habit_provider.dart';

class TimeManagementScreen extends StatelessWidget {
  final List<String> units = ["secs", "mins", "hours"];
  final List<String> frequencies = [
    "per day",
    "per week",
    "per month",
    "per year",
  ];

  @override
  Widget build(BuildContext context) {
    final habitProvider = Provider.of<SaveGoodHabitProvider>(context);
    final maxNumber = habitProvider.getMaxValue();
    return Scaffold(
      appBar: AppBar(title: Text("Time Management")),
      body: Center(
        child: Container(
          color: Colors.grey.shade200,
          height: 500,
          child: Column(
            children: [
              Expanded(
                child: Row(
                  children: [
                    // ===========================
                    // Number Wheel
                    // ===========================
                    Expanded(
                      child: ListWheelScrollView.useDelegate(
                        key: ValueKey(
                          "${habitProvider.durationUnit}_${habitProvider.frequencyUnit}",
                        ),
                        controller: FixedExtentScrollController(
                          initialItem: (habitProvider.durationValue - 1).clamp(
                            0,
                            maxNumber - 1,
                          ),
                        ),
                        itemExtent: 50,
                        diameterRatio: 1.5,
                        physics: const FixedExtentScrollPhysics(),
                        onSelectedItemChanged: (index) {
                          habitProvider.setDurationValue(index + 1);
                        },
                        childDelegate: ListWheelChildBuilderDelegate(
                          childCount: maxNumber,
                          builder: (context, index) {
                            final value = index + 1;

                            final isSelected = habitProvider.durationValue == value;

                            return Center(
                              child: AnimatedDefaultTextStyle(
                                duration: const Duration(milliseconds: 200),
                                style: TextStyle(
                                  fontSize: isSelected ? 22 : 18,
                                  fontWeight: FontWeight.w600,
                                  color: isSelected ? Colors.blue : Colors.black54,
                                ),
                                child: Text("$value"),
                              ),
                            );
                          },
                        ),
                      ),
                    ),

                    Container(
                      width: 1,
                      color: Colors.grey.shade300,
                      margin: const EdgeInsets.symmetric(vertical: 20),
                    ),

                    // ===========================
                    // Unit Wheel
                    // ===========================
                    Expanded(
                      child: ListWheelScrollView.useDelegate(
                        controller: FixedExtentScrollController(
                          initialItem: units.indexOf(habitProvider.durationUnit),
                        ),
                        itemExtent: 50,
                        diameterRatio: 1.5,
                        physics: const FixedExtentScrollPhysics(),
                        onSelectedItemChanged: (index) {
                          habitProvider.setDurationUnit(units[index]);
                        },
                        childDelegate: ListWheelChildBuilderDelegate(
                          childCount: units.length,
                          builder: (context, index) {
                            final unit = units[index];

                            final isSelected = habitProvider.durationUnit == unit;

                            return Center(
                              child: AnimatedDefaultTextStyle(
                                duration: const Duration(milliseconds: 200),
                                style: TextStyle(
                                  fontSize: isSelected ? 22 : 18,
                                  fontWeight: FontWeight.w600,
                                  color: isSelected ? Colors.blue : Colors.black54,
                                ),
                                child: Text(unit),
                              ),
                            );
                          },
                        ),
                      ),
                    ),

                    Container(
                      width: 1,
                      color: Colors.grey.shade300,
                      margin: const EdgeInsets.symmetric(vertical: 20),
                    ),

                    // ===========================
                    // Frequency Wheel
                    // ===========================
                    Expanded(
                      child: ListWheelScrollView.useDelegate(
                        controller: FixedExtentScrollController(
                          initialItem: frequencies.indexOf(
                            habitProvider.frequencyUnit,
                          ),
                        ),
                        itemExtent: 50,
                        diameterRatio: 1.5,
                        physics: const FixedExtentScrollPhysics(),
                        onSelectedItemChanged: (index) {
                          habitProvider.setFrequencyUnit(frequencies[index]);
                        },
                        childDelegate: ListWheelChildBuilderDelegate(
                          childCount: frequencies.length,
                          builder: (context, index) {
                            final freq = frequencies[index];

                            final isSelected = habitProvider.frequencyUnit == freq;

                            return Center(
                              child: AnimatedDefaultTextStyle(
                                duration: const Duration(milliseconds: 200),
                                style: TextStyle(
                                  fontSize: isSelected ? 22 : 18,
                                  fontWeight: FontWeight.w600,
                                  color: isSelected ? Colors.blue : Colors.black54,
                                ),
                                child: Text(freq, textAlign: TextAlign.center),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              Text(
                "You've set ${habitProvider.durationText}",
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),

              const SizedBox(height: 20),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Save"),
                  ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
