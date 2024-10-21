// health_education_screen.dart
import 'package:flutter/material.dart';

class HealthEducationScreen extends StatefulWidget {
  @override
  _HealthEducationScreenState createState() => _HealthEducationScreenState();
}

class _HealthEducationScreenState extends State<HealthEducationScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My AI Advisor'), // Updated title
      ),
      body: Center(child: Text('Health Education Resources Coming Soon')),
    );
  }
}

