// screens/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool isEditing = false;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _bloodPressureController = TextEditingController();
  final TextEditingController _saturationController = TextEditingController();
  final TextEditingController _heartRateController = TextEditingController();

  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _nameController.text = prefs.getString('name') ?? '';
      _dobController.text = prefs.getString('dob') ?? '';
      _emailController.text = prefs.getString('email') ?? '';
      _phoneController.text = prefs.getString('phone') ?? '';
      _weightController.text = prefs.getString('weight') ?? '';
      _heightController.text = prefs.getString('height') ?? '';
      _bloodPressureController.text = prefs.getString('bloodPressure') ?? '';
      _saturationController.text = prefs.getString('saturation') ?? '';
      _heartRateController.text = prefs.getString('heartRate') ?? '';
    });
  }

  Future<void> _saveUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('name', _nameController.text);
    await prefs.setString('dob', _dobController.text);
    await prefs.setString('email', _emailController.text);
    await prefs.setString('phone', _phoneController.text);
    await prefs.setString('weight', _weightController.text);
    await prefs.setString('height', _heightController.text);
    await prefs.setString('bloodPressure', _bloodPressureController.text);
    await prefs.setString('saturation', _saturationController.text);
    await prefs.setString('heartRate', _heartRateController.text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile', style: TextStyle(fontSize: 16, color: Colors.black)),
        actions: [
          IconButton(
            icon: Icon(isEditing ? Icons.check : Icons.edit),
            onPressed: () {
              setState(() {
                if (isEditing) {
                  _saveUserData(); // Save data when switching from edit to view
                }
                isEditing = !isEditing;
              });
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            _buildProfileSection(),
            SizedBox(height: 20),
            _buildHealthMetricsSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileSection() {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Personal Information', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black)),
            SizedBox(height: 10),
            _buildTextField('Name', _nameController),
            SizedBox(height: 10),
            _buildDateField('Date of Birth', _dobController),
            SizedBox(height: 10),
            _buildTextField('Email', _emailController, keyboardType: TextInputType.emailAddress),
            SizedBox(height: 10),
            _buildTextField('Phone', _phoneController, keyboardType: TextInputType.phone),
            SizedBox(height: 10),
           _buildTextField('Weight (kg) - Optional', _weightController, keyboardType: TextInputType.numberWithOptions(decimal: true)),
            SizedBox(height: 10),
            _buildTextField('Height (cm) - Optional', _heightController, keyboardType: TextInputType.number),
          ],
        ),
      ),
    );
  }

  Widget _buildHealthMetricsSection() {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Health Metrics', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black)),
            SizedBox(height: 10),
            _buildTextField('Blood Pressure (e.g., 120/80)', _bloodPressureController),
            SizedBox(height: 10),
            _buildTextField('Saturation (SpO2 %)', _saturationController, keyboardType: TextInputType.number),
            SizedBox(height: 10),
            _buildTextField('Heart Rate (BPM)', _heartRateController, keyboardType: TextInputType.number),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, {TextInputType keyboardType = TextInputType.text}) {
    return TextField(
      controller: controller,
      enabled: isEditing,
      keyboardType: keyboardType,
      style: TextStyle(fontSize: 16, color: Colors.black),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(fontSize: 16, color: Colors.black),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
      ),
    );
  }

  Widget _buildDateField(String label, TextEditingController controller) {
    return GestureDetector(
      onTap: isEditing ? () => _selectDate(context) : null,
      child: AbsorbPointer(
        child: TextField(
          controller: controller,
          enabled: isEditing,
          style: TextStyle(fontSize: 16, color: Colors.black),
          decoration: InputDecoration(
            labelText: label,
            labelStyle: TextStyle(fontSize: 16, color: Colors.black),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _dobController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }
}
