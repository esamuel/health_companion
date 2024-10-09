import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HealthTrackingScreen extends StatefulWidget {
  @override
  _HealthTrackingScreenState createState() => _HealthTrackingScreenState();
}

class _HealthTrackingScreenState extends State<HealthTrackingScreen> {
  TextEditingController bloodPressureController = TextEditingController();
  TextEditingController glucoseLevelController = TextEditingController();
  TextEditingController heartRateController = TextEditingController();
  TextEditingController temperatureController = TextEditingController();
  TextEditingController bloodOxygenController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadHealthData();
  }

  void _loadHealthData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      bloodPressureController.text = prefs.getString('bloodPressure') ?? '';
      glucoseLevelController.text = prefs.getString('glucoseLevel') ?? '';
      heartRateController.text = prefs.getString('heartRate') ?? '';
      temperatureController.text = prefs.getString('temperature') ?? '';
      bloodOxygenController.text = prefs.getString('bloodOxygen') ?? '';
    });
  }

  void _saveData() async {
    // Dismiss the keyboard
    FocusScope.of(context).unfocus();

    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('bloodPressure', bloodPressureController.text);
    await prefs.setString('glucoseLevel', glucoseLevelController.text);
    await prefs.setString('heartRate', heartRateController.text);
    await prefs.setString('temperature', temperatureController.text);
    await prefs.setString('bloodOxygen', bloodOxygenController.text);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Data Saved:\n'
          'Blood Pressure: ${bloodPressureController.text}\n'
          'Glucose Level: ${glucoseLevelController.text} mg/dL\n'
          'Heart Rate: ${heartRateController.text} BPM\n'
          'Body Temperature: ${temperatureController.text} °C/°F\n'
          'Blood Oxygen Level: ${bloodOxygenController.text} %',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Health Tracking'),
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView(
            children: [
              // Blood Pressure Input
              TextField(
                controller: bloodPressureController,
                decoration: InputDecoration(
                  labelText: 'Blood Pressure (e.g., 120/80)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.text,
              ),
              SizedBox(height: 16),
              // Glucose Level Input
              TextField(
                controller: glucoseLevelController,
                decoration: InputDecoration(
                  labelText: 'Glucose Level (mg/dL)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
              ),
              SizedBox(height: 16),
              // Heart Rate Input
              TextField(
                controller: heartRateController,
                decoration: InputDecoration(
                  labelText: 'Heart Rate (BPM)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 16),
              // Body Temperature Input
              TextField(
                controller: temperatureController,
                decoration: InputDecoration(
                  labelText: 'Body Temperature (°C or °F)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
              ),
              SizedBox(height: 16),
              // Blood Oxygen Level Input
              TextField(
                controller: bloodOxygenController,
                decoration: InputDecoration(
                  labelText: 'Blood Oxygen Level (SpO2 %)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: _saveData,
                child: Text('Save Data'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    bloodPressureController.dispose();
    glucoseLevelController.dispose();
    heartRateController.dispose();
    temperatureController.dispose();
    bloodOxygenController.dispose();
    super.dispose();
  }
}
