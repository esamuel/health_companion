import 'package:flutter/material.dart';
import 'screens/home_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(HealthCompanionApp());
}

class HealthCompanionApp extends StatefulWidget {
  @override
  _HealthCompanionAppState createState() => _HealthCompanionAppState();
}

class _HealthCompanionAppState extends State<HealthCompanionApp> {
  bool isDarkMode = false;

  @override
  void initState() {
    super.initState();
    _loadThemePreference();
  }

  Future<void> _loadThemePreference() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      isDarkMode = prefs.getBool('isDarkMode') ?? false;
    });
  }

  Future<void> _updateThemePreference(bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', value);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Health Companion',
      theme: isDarkMode ? ThemeData.dark() : ThemeData.light(),
      home: HomePage(
        onThemeChanged: (value) {
          setState(() {
            isDarkMode = value;
            _updateThemePreference(value);
          });
        },
      ),
    );
  }
}