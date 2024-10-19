import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HealthTrackingScreen extends StatefulWidget {
  const HealthTrackingScreen({super.key});

  @override
  _HealthTrackingScreenState createState() => _HealthTrackingScreenState();
}

class _HealthTrackingScreenState extends State<HealthTrackingScreen> {
  final _formKey = GlobalKey<FormState>();
  Map<String, TextEditingController> controllers = {
    'weight': TextEditingController(),
    'bloodPressure': TextEditingController(),
    'glucoseLevel': TextEditingController(),
    'heartRate': TextEditingController(),
    'temperature': TextEditingController(),
    'bloodOxygen': TextEditingController(),
    'cholesterol': TextEditingController(),
    'boneMinDensity': TextEditingController(),
    'hydration': TextEditingController(),
    'sleepDuration': TextEditingController(),
  };

  @override
  void initState() {
    super.initState();
    _loadHealthData();
  }

  void _loadHealthData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      controllers.forEach((key, controller) {
        controller.text = prefs.getString(key) ?? '';
      });
    });
  }

  void _saveData() async {
    if (_formKey.currentState!.validate()) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      controllers.forEach((key, controller) {
        prefs.setString(key, controller.text);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Health data saved successfully')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Health Tracking')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(16),
          children: [
            ...controllers.entries.map((entry) => _buildInputField(entry.key, entry.value)),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveData,
              child: Text('Save Health Data'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField(String label, TextEditingController controller) {
    String hint = '';
    String? Function(String?)? validator;

    switch (label) {
      case 'weight':
        hint = 'Enter weight in kg';
        validator = (value) => value!.isEmpty ? 'Please enter weight' : null;
        break;
      case 'bloodPressure':
        hint = 'Enter blood pressure (e.g., 120/80)';
        validator = (value) {
          if (value!.isEmpty) return 'Please enter blood pressure';
          if (!value.contains('/')) return 'Use format: systolic/diastolic';
          return null;
        };
        break;
      // Add cases for other fields...
    }

    return Padding(
      padding: EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label.replaceFirst(label[0], label[0].toUpperCase()),
          hintText: hint,
          border: OutlineInputBorder(),
        ),
        validator: validator,
      ),
    );
  }

  @override
  void dispose() {
    for (var controller in controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }
}