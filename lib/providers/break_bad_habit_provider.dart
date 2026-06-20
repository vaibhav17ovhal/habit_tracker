import 'package:flutter/cupertino.dart';

import '../models/habit_category_model.dart';

class BreakBadHabitProvider extends ChangeNotifier{
  final List<HabitCategoryModel> habitCategories = [
    HabitCategoryModel(
      title: "Stop Smoking",
      image: "assets/break_habit_icon/stop_smoking_icon.svg",
      color: Color(0xFF80DEEA), // strong aqua
    ),
    HabitCategoryModel(
      title: "Stop Drinking",
      image: "assets/break_habit_icon/stop_drinking_icon.svg",
      color: Color(0xFF64B5F6), // solid sky blue
    ),
    HabitCategoryModel(
      title: "Limit Junk Food",
      image: "assets/break_habit_icon/limit_junk_food_icon.svg",
      color: Color(0xFFFFB74D), // bold pastel orange
    ),
    HabitCategoryModel(
      title: "Limit Overeating",
      image: "assets/break_habit_icon/limit_overeating_icon.svg",
      color: Color(0xFFBA68C8), // rich pastel purple
    ),
    HabitCategoryModel(
      title: "Limit Screen Time",
      image: "assets/habit_icon/Workout-rafiki.svg",
      color: Color(0xFF7986CB), // strong indigo pastel
    ),
    HabitCategoryModel(
      title: "Limit Video Games",
      image: "assets/habit_icon/Hydratation-rafiki.svg",
      color: Color(0xFF4FC3F7), // vibrant pastel blue
    ),
    HabitCategoryModel(
      title: "Limit Shopping",
      image: "assets/habit_icon/Dog walking-pana.svg",
      color: Color(0xFFFFD54F), // golden pastel yellow
    ),
    HabitCategoryModel(
      title: "Limit Time Sitting",
      image: "assets/habit_icon/Road cycling-rafiki.svg",
      color: Color(0xFFEF5350), // strong pastel red
    ),
    HabitCategoryModel(
      title: "Stop Skipping Meal",
      image: "assets/habit_icon/Yoga practice-bro.svg",
      color: Color(0xFFF06292), // bold pastel pink
    ),
    HabitCategoryModel(
      title: "Stop Staying Up Late",
      image: "assets/habit_icon/Book lover-amico.svg",
      color: Color(0xFF81C784), // solid pastel green
    ),
  ];
}