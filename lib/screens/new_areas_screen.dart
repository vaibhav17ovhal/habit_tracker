import 'package:Demo/custom_widgets/custom_scaffold.dart';
import 'package:flutter/material.dart';

class NewAreasScreen extends StatefulWidget {
  const NewAreasScreen({super.key});

  @override
  State<NewAreasScreen> createState() => _NewAreasScreenState();
}

class _NewAreasScreenState extends State<NewAreasScreen> {
  @override
  Widget build(BuildContext context) {
    return CustomScaffold(body: Column(children: []));
  }
}
