import 'package:Demo/custom_widgets/custom_scaffold.dart';
import 'package:flutter/cupertino.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  @override
  Widget build(BuildContext context) {
    return CustomScaffold(body: Column(children: []));
  }
}
