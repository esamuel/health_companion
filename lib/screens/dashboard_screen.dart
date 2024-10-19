import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'bmi_tracking_screen.dart';
import 'vital_signs_history_screen.dart';

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  Map<String, String> healthData = {};
  List<Map<String, String>> medications = [];
  String? gender;
  DateTime? dateOfBirth;

  @override
  void initState() {
    super.initState();
    _loadHealthData();
    _loadMedications();
  }

  Future<void> _loadHealthData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool useMetricUnits = prefs.getBool('useMetricUnits') ?? true;
    double? bmi = prefs.getDouble('bmi');
    gender = prefs.getString('gender');
    String? dobString = prefs.getString('dob');
    if (dobString != null) {
      dateOfBirth = DateTime.parse(dobString);
    }
    
    setState(() {
      healthData = {
        'Name': prefs.getString('name') ?? 'Not set',
        'Age': _calculateAge(dateOfBirth),
        'Gender': gender ?? 'Not set',
        'Weight': '${prefs.getString('weight') ?? 'Not set'} ${useMetricUnits ? 'kg' : 'lb'}',
        'Height': '${prefs.getString('height') ?? 'Not set'} ${useMetricUnits ? 'cm' : 'inch'}',
        'BMI': bmi != null ? bmi.toStringAsFixed(1) : 'Not calculated',
        'Blood Pressure': prefs.getString('bloodPressure') ?? 'Not set',
        'Heart Rate': '${prefs.getString('heartRate') ?? 'Not set'} BPM',
        'Blood Glucose': '${prefs.getString('glucoseLevel') ?? 'Not set'} mg/dL',
        'Sleep Duration': '${prefs.getString('sleepDuration') ?? 'Not set'} hours',
      };
    });
  }

  Future<void> _loadMedications() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      medications = (prefs.getStringList('medications') ?? [])
          .map((item) => Map<String, String>.from(json.decode(item)))
          .toList();
    });
  }

  String _calculateAge(DateTime? dob) {
    if (dob == null) return 'Not set';
    DateTime currentDate = DateTime.now();
    int years = currentDate.year - dob.year;
    int months = currentDate.month - dob.month;
    int days = currentDate.day - dob.day;

    if (days < 0) {
      months--;
      days += DateTime(currentDate.year, currentDate.month - 1, 0).day;
    }

    if (months < 0) {
      years--;
      months += 12;
    }

    String yearString = years == 1 ? 'year' : 'years';
    String monthString = months == 1 ? 'month' : 'months';

    if (years == 0) {
      return '$months $monthString';
    } else if (months == 0) {
      return '$years $yearString';
    } else {
      return '$years $yearString, $months $monthString';
    }
  }

  String _getBMICategory(String bmiString) {
    double? bmi = double.tryParse(bmiString);
    if (bmi == null) return 'Unknown';
    if (bmi < 18.5) return 'Underweight';
    if (bmi < 25) return 'Normal';
    if (bmi < 30) return 'Overweight';
    return 'Obese';
  }

  String _getGenderSpecificRecommendation() {
    int? age = int.tryParse(healthData['Age']?.split(' ')[0] ?? '');
    if (gender == 'Male' && age != null && age >= 50) {
      return 'Remember to schedule your prostate exam. It\'s recommended annually for men over 50.';
    } else if (gender == 'Female' && age != null && age >= 50) {
      return 'Don\'t forget your mammogram. It\'s recommended every 1-2 years for women over 50.';
    } else {
      return 'Regular check-ups are important for maintaining good health.';
    }
  }

  List<String> _getPersonalizedRecommendations() {
    List<String> recommendations = [];

    if (healthData['BMI'] != null && healthData['BMI'] != 'Not calculated') {
      double? bmi = double.tryParse(healthData['BMI']!);
      if (bmi != null) {
        if (bmi < 18.5) {
          recommendations.add('Your BMI indicates you\'re underweight. Consider consulting a nutritionist to develop a healthy weight gain plan.');
        } else if (bmi >= 25) {
          recommendations.add('Your BMI indicates you\'re overweight. Try to incorporate more physical activity into your daily routine and focus on a balanced diet.');
        }
      }
    }

    if (healthData['Blood Pressure'] != null && healthData['Blood Pressure'] != 'Not set') {
      List<String> bpValues = healthData['Blood Pressure']!.split('/');
      if (bpValues.length == 2) {
        int? systolic = int.tryParse(bpValues[0]);
        int? diastolic = int.tryParse(bpValues[1]);
        if (systolic != null && diastolic != null && (systolic >= 130 || diastolic >= 80)) {
          recommendations.add('Your blood pressure is elevated. Consider reducing sodium intake and increasing physical activity.');
        }
      }
    }

    if (healthData['Heart Rate'] != null && healthData['Heart Rate'] != 'Not set') {
      int? heartRate = int.tryParse(healthData['Heart Rate']!.split(' ')[0]);
      if (heartRate != null && heartRate > 100) {
        recommendations.add('Your resting heart rate is high. Consider discussing this with your doctor and ways to improve cardiovascular health.');
      }
    }

    if (healthData['Blood Glucose'] != null && healthData['Blood Glucose'] != 'Not set') {
      int? glucoseLevel = int.tryParse(healthData['Blood Glucose']!.split(' ')[0]);
      if (glucoseLevel != null && glucoseLevel > 100) {
        recommendations.add('Your fasting blood glucose level is elevated. Consider discussing diabetes risk with your doctor and ways to improve blood sugar control.');
      }
    }

    if (healthData['Sleep Duration'] != null && healthData['Sleep Duration'] != 'Not set') {
      double? sleepHours = double.tryParse(healthData['Sleep Duration']!.split(' ')[0]);
      if (sleepHours != null && sleepHours < 7) {
        recommendations.add('You\'re not getting enough sleep. Aim for 7-9 hours of sleep per night for optimal health.');
      }
    }

    recommendations.add('Stay hydrated by drinking at least 8 glasses of water daily.');
    recommendations.add('Incorporate a variety of fruits and vegetables into your diet for essential nutrients.');
    recommendations.add('Engage in at least 150 minutes of moderate-intensity aerobic activity or 75 minutes of vigorous-intensity aerobic activity weekly.');

    return recommendations;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Health Dashboard'),
        actions: [
          IconButton(
            icon: Icon(Icons.show_chart),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => BMITrackingScreen()),
              );
            },
            tooltip: 'BMI Tracking',
          ),
          IconButton(
            icon: Icon(Icons.history),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => VitalSignsHistoryScreen()),
              );
            },
            tooltip: 'Vital Signs History',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await _loadHealthData();
          await _loadMedications();
        },
        child: ListView(
          padding: EdgeInsets.all(16),
          children: [
            _buildSection('Personal Information', ['Name', 'Age', 'Gender']),
            _buildSection('Body Measurements', ['Weight', 'Height', 'BMI']),
            _buildMedicationCard(),
            _buildSection('Vital Signs', ['Blood Pressure', 'Heart Rate', 'Blood Glucose']),
            _buildSection('Lifestyle', ['Sleep Duration']),
            _buildRecommendationCard('Health Recommendation', _getGenderSpecificRecommendation()),
            _buildRecommendationCard('Personalized Recommendations', _getPersonalizedRecommendations()),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<String> items) {
    return Card(
      margin: EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            SizedBox(height: 8),
            ...items.map((item) => Padding(
              padding: EdgeInsets.symmetric(vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Tooltip(
                    message: _getTooltip(item),
                    child: Text(item, style: Theme.of(context).textTheme.titleMedium),
                  ),
                  Text(
                    healthData[item] ?? 'Not available',
                    style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                      color: item == 'BMI' ? _getBMIColor(healthData[item]) : null,
                    ),
                  ),
                ],
              ),
            )),
            if (items.contains('BMI') && healthData['BMI'] != null && healthData['BMI'] != 'Not calculated')
              Padding(
                padding: EdgeInsets.only(top: 4),
                child: Text(
                  'Category: ${_getBMICategory(healthData['BMI']!)}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMedicationCard() {
    return Card(
      margin: EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Current Medications', style: Theme.of(context).textTheme.titleLarge),
            SizedBox(height: 8),
            if (medications.isEmpty)
              Text('No medications recorded', style: Theme.of(context).textTheme.bodyMedium)
            else
              ...medications.map((medication) => Padding(
                padding: EdgeInsets.only(bottom: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      flex: 2,
                      child: Text(medication['name'] ?? '', style: Theme.of(context).textTheme.bodyLarge),
                    ),
                    Expanded(
                      flex: 1,
                      child: Text(medication['dosage'] ?? '', style: Theme.of(context).textTheme.bodyMedium),
                    ),
                    Expanded(
                      flex: 1,
                      child: Text(medication['time'] ?? '', style: Theme.of(context).textTheme.bodyMedium),
                    ),
                  ],
                ),
              )),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendationCard(String title, dynamic recommendations) {
    return Card(
      margin: EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            SizedBox(height: 8),
            if (recommendations is String)
              Text(recommendations, style: Theme.of(context).textTheme.bodyMedium)
            else if (recommendations is List<String>)
              ...recommendations.map((recommendation) => Padding(
                padding: EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('• ', style: Theme.of(context).textTheme.bodyMedium),
                    Expanded(
                      child: Text(recommendation, style: Theme.of(context).textTheme.bodyMedium),
                    ),
                  ],
                ),
              )),
          ],
        ),
      ),
    );
  }

  String _getTooltip(String item) {
    switch (item) {
      case 'BMI':
        return 'Body Mass Index (BMI) is a measure of body fat based on height and weight. A healthy BMI range is 18.5-24.9.';
      case 'Blood Pressure':
        return 'Blood pressure is measured in mmHg. Normal range is less than 120/80 mmHg.';
      case 'Heart Rate':
        return 'Normal resting heart rate for adults is 60-100 beats per minute.';
      case 'Blood Glucose':
        return 'Fasting blood glucose levels should be below 100 mg/dL. Levels between 100-125 mg/dL indicate prediabetes.';
      case 'Sleep Duration':
        return 'Adults should aim for 7-9 hours of sleep per night for optimal health.';
      default:
        return '';
    }
  }

  Color _getBMIColor(String? bmiString) {
    if (bmiString == null || bmiString == 'Not calculated') return Colors.grey;
    double? bmi = double.tryParse(bmiString);
    if (bmi == null) return Colors.grey;
    if (bmi < 18.5) return Colors.blue;
    if (bmi < 25) return Colors.green;
    if (bmi < 30) return Colors.orange;
    return Colors.red;
  }
}