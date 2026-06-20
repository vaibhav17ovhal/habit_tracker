import 'package:flutter/cupertino.dart';

import '../models/habit_category_model.dart';

class BuildAHabitProvider extends ChangeNotifier{
  final List<HabitCategoryModel> habitCategories = [
    HabitCategoryModel(
      title: "Meditate",
      image: "assets/habit_icon/Meditation-bro.svg",
      color: Color(0xFF80DEEA), // strong aqua
    ),
    HabitCategoryModel(
      title: "Running",
      image: "assets/habit_icon/Cross country race-pana.svg",
      color: Color(0xFF64B5F6), // solid sky blue
    ),
    HabitCategoryModel(
      title: "Read Books",
      image: "assets/habit_icon/Book lover-amico.svg",
      color: Color(0xFFFFB74D), // bold pastel orange
    ),
    HabitCategoryModel(
      title: "Journal",
      image: "assets/habit_icon/Checklist-pana.svg",
      color: Color(0xFFBA68C8), // rich pastel purple
    ),
    HabitCategoryModel(
      title: "Hit The Gym",
      image: "assets/habit_icon/Workout-rafiki.svg",
      color: Color(0xFF7986CB), // strong indigo pastel
    ),
    HabitCategoryModel(
      title: "Drink Water",
      image: "assets/habit_icon/Hydratation-rafiki.svg",
      color: Color(0xFF4FC3F7), // vibrant pastel blue
    ),
    HabitCategoryModel(
      title: "Walk",
      image: "assets/habit_icon/Dog walking-pana.svg",
      color: Color(0xFFFFD54F), // golden pastel yellow
    ),
    HabitCategoryModel(
      title: "Cycling",
      image: "assets/habit_icon/Road cycling-rafiki.svg",
      color: Color(0xFFEF5350), // strong pastel red
    ),
    HabitCategoryModel(
      title: "Yoga",
      image: "assets/habit_icon/Yoga practice-bro.svg",
      color: Color(0xFFF06292), // bold pastel pink
    ),
    HabitCategoryModel(
      title: "Study",
      image: "assets/habit_icon/Book lover-amico.svg",
      color: Color(0xFF81C784), // solid pastel green
    ),
    HabitCategoryModel(
      title: "Taking a Shower",
      image: "assets/habit_icon/Taking a shower-rafiki.svg",
      color: Color(0xFF9575CD), // deep pastel violet
    ),
    HabitCategoryModel(
      title: "Skipping Rope",
      image: "assets/habit_icon/Skipping rope-amico.svg",
      color: Color(0xFFFFF176), // bold pastel lemon
    ),
    HabitCategoryModel(
      title: "Swimming",
      image: "assets/habit_icon/paralympic swimming-rafiki.svg",
      color: Color(0xFF4DB6AC), // strong teal pastel
    ),
    HabitCategoryModel(
      title: "Listening Music",
      image: "assets/habit_icon/Lo-fi concept-bro.svg",
      color: Color(0xFF7986CB), // indigo pastel (musical vibe)
    ),
    HabitCategoryModel(
      title: "Sleeping Early",
      image: "assets/habit_icon/Insomnia-amico.svg",
      color: Color(0xFF81C784), // calming pastel green
    ),


  ];
}