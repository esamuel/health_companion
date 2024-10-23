// lib/screens/settings_screen.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import '../config/app_theme.dart';

class SettingsScreen extends StatefulWidget {
  final Function(bool) onThemeChanged;

  const SettingsScreen({Key? key, required this.onThemeChanged}) : super(key: key);

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // Theme and Accessibility Settings
  bool isDarkMode = false;
  bool useMetricUnits = true;
  bool isHighContrast = false;
  double currentFontSize = AppTheme.defaultFontSize;

  // Personal Information Controllers
  final TextEditingController nameController = TextEditingController();
  final TextEditingController dobController = TextEditingController();
  final TextEditingController weightController = TextEditingController();
  final TextEditingController heightController = TextEditingController();
  
  // Medical Information Controllers
  final TextEditingController bloodPressureController = TextEditingController();
  final TextEditingController heartRateController = TextEditingController();
  final TextEditingController glucoseLevelController = TextEditingController();

  // Other State Variables
  String gender = 'Not Specified';
  DateTime? selectedDate;
  bool showPassword = false;

  final List<String> genderOptions = [
    'Not Specified',
    'Male',
    'Female',
    'Other'
  ];

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      setState(() {
        // Load Theme Settings
        isDarkMode = prefs.getBool('isDarkMode') ?? false;
        useMetricUnits = prefs.getBool('useMetricUnits') ?? true;
        isHighContrast = prefs.getBool('highContrast') ?? false;
        currentFontSize = prefs.getDouble('fontSize') ?? AppTheme.defaultFontSize;
        
        // Load Personal Information
        nameController.text = prefs.getString('name') ?? '';
        gender = prefs.getString('gender') ?? 'Not Specified';
        
        String? dobString = prefs.getString('dob');
        if (dobString != null) {
          selectedDate = DateTime.parse(dobString);
          dobController.text = DateFormat('yyyy-MM-dd').format(selectedDate!);
        }
        
        // Load Medical Information
        weightController.text = prefs.getString('weight') ?? '';
        heightController.text = prefs.getString('height') ?? '';
        bloodPressureController.text = prefs.getString('bloodPressure') ?? '';
        heartRateController.text = prefs.getString('heartRate') ?? '';
        glucoseLevelController.text = prefs.getString('glucoseLevel') ?? '';
      });
    } catch (e) {
      print('Error loading settings: $e');
      // Show error message to user
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading settings. Please try again.')),
        );
      }
    }
  }

  Future<void> _saveSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Save Theme Settings
      await prefs.setBool('isDarkMode', isDarkMode);
      await prefs.setBool('useMetricUnits', useMetricUnits);
      await prefs.setBool('highContrast', isHighContrast);
      await prefs.setDouble('fontSize', currentFontSize);
      
      // Save Personal Information
      await prefs.setString('name', nameController.text);
      await prefs.setString('gender', gender);
      if (selectedDate != null) {
        await prefs.setString('dob', selectedDate!.toIso8601String());
      }
      
      // Save Medical Information
      await prefs.setString('weight', weightController.text);
      await prefs.setString('height', heightController.text);
      await prefs.setString('bloodPressure', bloodPressureController.text);
      await prefs.setString('heartRate', heartRateController.text);
      await prefs.setString('glucoseLevel', glucoseLevelController.text);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Settings saved successfully')),
        );
      }
    } catch (e) {
      print('Error saving settings: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving settings. Please try again.')),
        );
      }
    }
  }

  Widget _buildAccessibilitySettings() {
    return Card(
      margin: EdgeInsets.all(8.0),
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Accessibility Settings',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontSize: currentFontSize * 1.2,
              ),
            ),
            SizedBox(height: 16),
            
            // Font Size Controls
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Text Size',
                  style: TextStyle(fontSize: currentFontSize),
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    Text('A', style: TextStyle(fontSize: 14)),
                    Expanded(
                      child: Slider(
                        value: currentFontSize,
                        min: AppTheme.minFontSize,
                        max: AppTheme.maxFontSize,
                        divisions: 7,
                        label: currentFontSize.round().toString(),
                        onChanged: (value) {
                          setState(() {
                            currentFontSize = value;
                          });
                        },
                      ),
                    ),
                    Text('A', style: TextStyle(fontSize: 28)),
                  ],
                ),
                // Preview Text
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'Preview Text - This is how text will appear',
                    style: TextStyle(fontSize: currentFontSize),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            
            // High Contrast Mode
            SwitchListTile(
              title: Text(
                'High Contrast Mode',
                style: TextStyle(fontSize: currentFontSize),
              ),
              subtitle: Text(
                'Increases contrast for better visibility',
                style: TextStyle(fontSize: currentFontSize * 0.8),
              ),
              value: isHighContrast,
              onChanged: (bool value) {
                setState(() {
                  isHighContrast = value;
                });
              },
            ),

            // Dark Mode
            SwitchListTile(
              title: Text(
                'Dark Mode',
                style: TextStyle(fontSize: currentFontSize),
              ),
              subtitle: Text(
                'Use dark theme for reduced eye strain',
                style: TextStyle(fontSize: currentFontSize * 0.8),
              ),
              value: isDarkMode,
              onChanged: (bool value) {
                setState(() {
                  isDarkMode = value;
                });
                widget.onThemeChanged(value);
              },
            ),

            // Measurement Units
            SwitchListTile(
              title: Text(
                'Use Metric Units',
                style: TextStyle(fontSize: currentFontSize),
              ),
              subtitle: Text(
                useMetricUnits ? 'Using: kg / cm' : 'Using: lb / inch',
                style: TextStyle(fontSize: currentFontSize * 0.8),
              ),
              value: useMetricUnits,
              onChanged: (bool value) {
                setState(() {
                  useMetricUnits = value;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPersonalInformationSettings() {
    return Card(
      margin: EdgeInsets.all(8.0),
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Personal Information',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontSize: currentFontSize * 1.2,
              ),
            ),
            SizedBox(height: 16),

            // Name Field
            _buildTextField(
              controller: nameController,
              label: 'Full Name',
              icon: Icons.person,
            ),
            SizedBox(height: 16),

            // Date of Birth Field
            GestureDetector(
              onTap: () => _selectDate(context),
              child: AbsorbPointer(
                child: _buildTextField(
                  controller: dobController,
                  label: 'Date of Birth',
                  icon: Icons.calendar_today,
                ),
              ),
            ),
            SizedBox(height: 16),

            // Gender Selection
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: 'Gender',
                labelStyle: TextStyle(fontSize: currentFontSize),
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.people),
                contentPadding: EdgeInsets.all(16),
              ),
              value: gender,
              style: TextStyle(fontSize: currentFontSize, color: Theme.of(context).textTheme.bodyLarge?.color),
              items: genderOptions.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() {
                    gender = newValue;
                  });
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      style: TextStyle(fontSize: currentFontSize),
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(fontSize: currentFontSize),
        border: OutlineInputBorder(),
        prefixIcon: Icon(icon),
        contentPadding: EdgeInsets.all(16),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            textTheme: TextTheme(
              bodyLarge: TextStyle(fontSize: currentFontSize),
              bodyMedium: TextStyle(fontSize: currentFontSize),
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
        dobController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  } 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings', style: TextStyle(fontSize: currentFontSize)),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildAccessibilitySettings(),
              SizedBox(height: 16),
              _buildPersonalInformationSettings(),
              SizedBox(height: 16),
              ElevatedButton(
                child: Text('Save Settings', style: TextStyle(fontSize: currentFontSize)),
                onPressed: _saveSettings,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
