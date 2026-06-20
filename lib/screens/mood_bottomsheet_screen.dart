import 'package:Demo/custom_widgets/custom_colors.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/mood_provider.dart';

class MoodBottomSheet extends StatelessWidget {
  const MoodBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<MoodProvider>(
      builder: (context, provider, child) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            decoration: BoxDecoration(
              color: MyColors.kWhiteColor,
              borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20))
            ),
            height: MediaQuery.of(context).size.height * 0.75,
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "How do you feel right now?",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                SizedBox(height: 15),

                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: provider.moods.map((mood) {
                    final isSelected = provider.selectedMood == mood["label"];

                    return GestureDetector(
                      onTap: () => provider.selectMood(mood["label"]),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // 🎯 ICON WITH SELECTED BACKGROUND
                          AnimatedContainer(
                            duration: Duration(milliseconds: 200),
                            padding: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(15),
                              border: Border.all(
                                color: isSelected
                                    ? Colors.teal
                                    : Colors.grey.shade300,
                                width: 1.5,
                              ),
                              boxShadow: isSelected
                                  ? [
                                BoxShadow(
                                  color: Colors.teal.withOpacity(0.2),
                                  blurRadius: 10,
                                  offset: Offset(0, 4),
                                )
                              ]
                                  : [],
                            ),
                            child: Image.asset(
                              mood["emoji"],
                              height: 40,
                              width: 40,
                              fit: BoxFit.contain,
                              gaplessPlayback: true,
                            ),
                          ),

                          SizedBox(height: 8),

                          // 🏷 LABEL
                          Text(
                            mood["label"],
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: isSelected ? Colors.teal : Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),

                SizedBox(height: 20),

                Text(
                  "What have you been up to?",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                SizedBox(height: 10),

                // ================= ACTIVITIES =================
                Wrap(
                  spacing: 10,
                  children: provider.activities.map((item) {
                    final isSelected =
                    provider.selectedActivities.contains(item);

                    return FilterChip(
                      label: Text(item),
                      selected: isSelected,
                      selectedColor: Colors.teal.shade200,
                      onSelected: (_) =>
                          provider.toggleActivity(item),
                    );
                  }).toList(),
                ),

                SizedBox(height: 20),

                Text(
                  "Additional context",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                SizedBox(height: 10),

                TextField(
                  controller: provider.noteController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: "Write something...",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),

                Spacer(),

                // ================= SAVE BUTTON =================
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      padding: EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      provider.saveMood();
                      Navigator.pop(context);
                    },
                    child: Text(
                      "Save Mood",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}