import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'dart:convert';

class SettingsScreen extends StatefulWidget {
  final Function(bool) onThemeChanged;

  SettingsScreen({required this.onThemeChanged});

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool isDarkMode = false;
  bool useMetricUnits = true;
  String gender = 'Not Specified';
  TextEditingController nameController = TextEditingController();
  TextEditingController dobController = TextEditingController();
  TextEditingController weightController = TextEditingController();
  TextEditingController heightController = TextEditingController();
  TextEditingController bloodPressureController = TextEditingController();
  TextEditingController heartRateController = TextEditingController();
  TextEditingController glucoseLevelController = TextEditingController();

  DateTime? selectedDate;

  final List<String> genderOptions = [
    'Not Specified',
    'Male',
    'Female',
    'Other'
  ];

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      setState(() {
        isDarkMode = prefs.getBool('isDarkMode') ?? false;
        useMetricUnits = prefs.getBool('useMetricUnits') ?? true;
        gender = prefs.getString('gender') ?? 'Not Specified';
        if (!genderOptions.contains(gender)) {
          gender = 'Not Specified';
        }
        nameController.text = prefs.getString('name') ?? '';
        String? dobString = prefs.getString('dob');
        if (dobString != null) {
          selectedDate = DateTime.parse(dobString);
          dobController.text = DateFormat('yyyy-MM-dd').format(selectedDate!);
        }
        weightController.text = prefs.getString('weight') ?? '';
        heightController.text = prefs.getString('height') ?? '';
        bloodPressureController.text = prefs.getString('bloodPressure') ?? '';
        heartRateController.text = prefs.getString('heartRate') ?? '';
        glucoseLevelController.text = prefs.getString('glucoseLevel') ?? '';
      });
    } catch (e) {
      print('Error loading user data: $e');
    }
  }

  Future<void> _saveUserData() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isDarkMode', isDarkMode);
      await prefs.setBool('useMetricUnits', useMetricUnits);
      await prefs.setString('gender', gender);
      await prefs.setString('name', nameController.text);
      if (selectedDate != null) {
        await prefs.setString('dob', selectedDate!.toIso8601String());
      }
      await prefs.setString('weight', weightController.text);
      await prefs.setString('height', heightController.text);
      await prefs.setString('bloodPressure', bloodPressureController.text);
      await prefs.setString('heartRate', heartRateController.text);
      await prefs.setString('glucoseLevel', glucoseLevelController.text);

      // Calculate and save BMI
      if (weightController.text.isNotEmpty &&
          heightController.text.isNotEmpty) {
        double? weight = double.tryParse(weightController.text);
        double? height = double.tryParse(heightController.text);
        if (weight != null && height != null) {
          if (!useMetricUnits) {
            // Convert pounds to kg and inches to meters
            weight = weight * 0.453592;
            height = height * 0.0254;
          } else {
            // Convert cm to meters
            height = height / 100;
          }
          double bmi = weight / (height * height);
          await prefs.setDouble('bmi', bmi);

          // Save BMI history
          List<String> bmiHistory = prefs.getStringList('bmiHistory') ?? [];
          bmiHistory.add(bmi.toStringAsFixed(1));
          await prefs.setStringList('bmiHistory', bmiHistory);
        }
      }

      // Save vital signs history
      await _saveVitalSignsHistory(prefs);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Settings saved successfully')),
      );
    } catch (e) {
      print('Error saving user data: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving settings. Please try again.')),
      );
    }
  }

 Future<void> _saveVitalSignsHistory(SharedPreferences prefs) async {
    String bloodPressure = bloodPressureController.text;
    String heartRate = heartRateController.text;
    String bloodGlucose = glucoseLevelController.text;

    // Get the last saved values
    String lastBloodPressure = prefs.getString('lastBloodPressure') ?? '';
    String lastHeartRate = prefs.getString('lastHeartRate') ?? '';
    String lastBloodGlucose = prefs.getString('lastBloodGlucose') ?? '';

    // Check if any of the values have changed
    bool hasChanged = bloodPressure != lastBloodPressure ||
                      heartRate != lastHeartRate ||
                      bloodGlucose != lastBloodGlucose;

    print('Has vital signs changed: $hasChanged'); // Debug print

    if (hasChanged) {
      List<Map<String, dynamic>> history = List<Map<String, dynamic>>.from(
        json.decode(prefs.getString('vitalSignsHistory') ?? '[]')
      );

      Map<String, dynamic> newEntry = {
        'date': DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now()),
        'bloodPressure': bloodPressure,
        'heartRate': heartRate,
        'bloodGlucose': bloodGlucose,
      };

      history.add(newEntry);

      print('New vital signs entry: $newEntry'); // Debug print
      print('Updated history: $history'); // Debug print

      await prefs.setString('vitalSignsHistory', json.encode(history));

      // Update the last saved values
      await prefs.setString('lastBloodPressure', bloodPressure);
      await prefs.setString('lastHeartRate', heartRate);
      await prefs.setString('lastBloodGlucose', bloodGlucose);

      print('Vital signs history saved successfully'); // Debug print
    } else {
      print('No changes in vital signs, history not updated'); // Debug print
    }
  }
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
        dobController.text = DateFormat('yyyy-MM-dd').format(selectedDate!);
      });
    }
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
          _buildSwitchTile(
            title: 'Dark Mode',
            value: isDarkMode,
            onChanged: (value) {
              setState(() {
                isDarkMode = value;
              });
              widget.onThemeChanged(isDarkMode);
            },
          ),
          _buildSwitchTile(
            title: 'Use Metric Units',
            subtitle: useMetricUnits ? 'kg / cm' : 'lb / inch',
            value: useMetricUnits,
            onChanged: (value) {
              setState(() {
                useMetricUnits = value;
              });
            },
          ),
          _buildInputField(
            controller: nameController,
            label: 'Name',
          ),
          _buildDateField(
            controller: dobController,
            label: 'Date of Birth',
            onTap: () => _selectDate(context),
          ),
          _buildDropdownField(
            label: 'Gender',
            value: gender,
            items: genderOptions,
            onChanged: (String? newValue) {
              if (newValue != null) {
                setState(() {
                  gender = newValue;
                });
              }
            },
          ),
          _buildInputField(
            controller: weightController,
            label: 'Weight (${useMetricUnits ? 'kg' : 'lb'})',
            keyboardType: TextInputType.number,
          ),
          _buildInputField(
            controller: heightController,
            label: 'Height (${useMetricUnits ? 'cm' : 'inch'})',
            keyboardType: TextInputType.number,
          ),
          _buildInputField(
            controller: bloodPressureController,
            label: 'Blood Pressure (e.g., 120/80)',
          ),
          _buildInputField(
            controller: heartRateController,
            label: 'Heart Rate (BPM)',
            keyboardType: TextInputType.number,
          ),
          _buildInputField(
            controller: glucoseLevelController,
            label: 'Blood Glucose (mg/dL)',
            keyboardType: TextInputType.number,
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: _saveUserData,
            child: Text('Save Settings'),
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    String? subtitle,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return Card(
      child: SwitchListTile(
        title: Text(title),
        subtitle: subtitle != null ? Text(subtitle) : null,
        value: value,
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: TextField(
          controller: controller,
          decoration: InputDecoration(
            labelText: label,
            border: OutlineInputBorder(),
          ),
          keyboardType: keyboardType,
        ),
      ),
    );
  }

  Widget _buildDateField({
    required TextEditingController controller,
    required String label,
    required VoidCallback onTap,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: TextField(
          controller: controller,
          decoration: InputDecoration(
            labelText: label,
            border: OutlineInputBorder(),
            suffixIcon: Icon(Icons.calendar_today),
          ),
          readOnly: true,
          onTap: onTap,
        ),
      ),
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: DropdownButtonFormField<String>(
          decoration: InputDecoration(
            labelText: label,
            border: OutlineInputBorder(),
          ),
          value: value,
          items: items.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(item),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    dobController.dispose();
    weightController.dispose();
    heightController.dispose();
    bloodPressureController.dispose();
    heartRateController.dispose();
    glucoseLevelController.dispose();
    super.dispose();
  }
}
