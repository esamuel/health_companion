import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  final Function(bool) onThemeChanged;

  SettingsScreen({required this.onThemeChanged});

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool isDarkMode = false;
  bool useMetricUnits = true;
  TextEditingController nameController = TextEditingController();
  TextEditingController ageController = TextEditingController();
  TextEditingController weightController = TextEditingController();
  TextEditingController heightController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      isDarkMode = prefs.getBool('isDarkMode') ?? false;
      useMetricUnits = prefs.getBool('useMetricUnits') ?? true;
      nameController.text = prefs.getString('name') ?? '';
      ageController.text = prefs.getString('age') ?? '';
      weightController.text = prefs.getString('weight') ?? '';
      heightController.text = prefs.getString('height') ?? '';
    });
  }

  _saveUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', isDarkMode);
    await prefs.setBool('useMetricUnits', useMetricUnits);
    await prefs.setString('name', nameController.text);
    await prefs.setString('age', ageController.text);
    await prefs.setString('weight', weightController.text);
    await prefs.setString('height', heightController.text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Theme Toggle
          SwitchListTile(
            title: Text('Dark Mode'),
            value: isDarkMode,
            onChanged: (value) {
              setState(() {
                isDarkMode = value;
              });
              widget.onThemeChanged(isDarkMode);
              _saveUserData();
            },
          ),
          SizedBox(height: 16),
          // User Information Form
          TextField(
            controller: nameController,
            decoration: InputDecoration(
              labelText: 'Name',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.text, // Universal keyboard
          ),
          SizedBox(height: 16),
          TextField(
            controller: ageController,
            decoration: InputDecoration(
              labelText: 'Age',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.text, // Universal keyboard
          ),
          SizedBox(height: 16),
          // Units Toggle
          SwitchListTile(
            title: Text('Use Metric Units'),
            subtitle: Text(useMetricUnits ? 'kg / cm' : 'lb / inch'),
            value: useMetricUnits,
            onChanged: (value) {
              setState(() {
                useMetricUnits = value;
              });
              _saveUserData();
            },
          ),
          SizedBox(height: 16),
          // Weight Field
          TextField(
            controller: weightController,
            decoration: InputDecoration(
              labelText: 'Weight (${useMetricUnits ? 'kg' : 'lb'})',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.text, // Universal keyboard
          ),
          SizedBox(height: 16),
          // Height Field
          TextField(
            controller: heightController,
            decoration: InputDecoration(
              labelText: 'Height (${useMetricUnits ? 'cm' : 'inch'})',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.text, // Universal keyboard
          ),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: () async {
              await _saveUserData();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Data Saved Successfully'),
                ),
              );
            },
            child: Text('Save Information'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    ageController.dispose();
    weightController.dispose();
    heightController.dispose();
    super.dispose();
  }
}