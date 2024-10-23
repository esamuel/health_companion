// lib/screens/home_page.dart

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dashboard_screen.dart';
import 'health_tracking_screen.dart';
import 'medication_reminder_screen.dart';
import 'diet_nutrition_screen.dart';
import 'activity_tracking_screen.dart';
import 'appointment_scheduler_screen.dart';
import 'My_AI_Advisor.dart';
import 'emergency_contacts_screen.dart';
import 'settings_screen.dart';
import 'package:health_companion/config/app_settings.dart';

class HomePage extends StatefulWidget {
  final Function(bool)? onThemeChanged;
  final Function(double)? onFontSizeChanged;
  final Function(bool)? onHighContrastChanged;
  final double? currentFontSize;
  final bool? isHighContrast;
  final bool isSimplifiedMode;

  const HomePage({
    Key? key,
    this.onThemeChanged,
    this.onFontSizeChanged,
    this.onHighContrastChanged,
    this.currentFontSize,
    this.isHighContrast,
    this.isSimplifiedMode = false,
  }) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late bool _isSimplifiedMode;

  @override
  void initState() {
    super.initState();
    _isSimplifiedMode = widget.isSimplifiedMode;
    _loadInterfaceMode();
  }

  Future<void> _loadInterfaceMode() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isSimplifiedMode = prefs.getBool('simplified_mode') ?? widget.isSimplifiedMode;
    });
  }

  Future<void> _toggleInterfaceMode() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('simplified_mode', !_isSimplifiedMode);
    setState(() {
      _isSimplifiedMode = !_isSimplifiedMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Health Companion',
          style: TextStyle(fontSize: widget.currentFontSize ?? 20.0),
        ),
        actions: [
          IconButton(
            icon: Icon(_isSimplifiedMode ? Icons.view_module : Icons.view_comfortable),
            onPressed: _toggleInterfaceMode,
            tooltip: _isSimplifiedMode ? 'Switch to Standard Mode' : 'Switch to Simple Mode',
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SettingsScreen(
                    onThemeChanged: widget.onThemeChanged ?? (_) {},
                  ),
                ),
              );
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
              ),
              child: Text(
                'Menu',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: widget.currentFontSize ?? 24.0,
                ),
              ),
            ),
            ListTile(
              title: Text(
                'My AI Advisor',
                style: TextStyle(fontSize: widget.currentFontSize ?? 16.0),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MyAIAdvisorScreen()),
                );
              },
            ),
          ],
        ),
      ),
      body: _isSimplifiedMode ? _buildSimplifiedInterface() : _buildStandardInterface(),
    );
  }

  Widget _buildSimplifiedInterface() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Emergency Section
          _buildEmergencySection(),
          const SizedBox(height: 24),
          
          // Main Features
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              mainAxisSpacing: 20,
              crossAxisSpacing: 20,
              childAspectRatio: 0.85,
              children: [
                _buildLargeFeatureCard(
                  'Medications',
                  Icons.medical_services,
                  Colors.blue,
                  MedicationReminderScreen(),
                  'Take your\nmedicines',
                ),
                _buildLargeFeatureCard(
                  'Health Check',
                  Icons.favorite,
                  Colors.green,
                  HealthTrackingScreen(),
                  'Track your\nhealth',
                ),
                _buildLargeFeatureCard(
                  'Ask for Help',
                  Icons.question_answer,
                  Colors.purple,
                  MyAIAdvisorScreen(),
                  'Get answers',
                ),
                _buildLargeFeatureCard(
                  'Appointments',
                  Icons.calendar_today,
                  Colors.orange,
                  AppointmentSchedulerScreen(),
                  'Your schedule',
                ),
              ],
            ),
          ),
          
          // Quick Actions Footer
          _buildQuickActionsFooter(),
        ],
      ),
    );
  }

  Widget _buildStandardInterface() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? Theme.of(context).scaffoldBackgroundColor
            : Colors.grey[100],
      ),
      child: GridView.count(
        crossAxisCount: 2,
        padding: const EdgeInsets.all(16.0),
        childAspectRatio: 3 / 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        children: <Widget>[
          _buildFeatureButton(
            'Dashboard',
            Icons.dashboard,
            DashboardScreen(),
            Colors.blue,
          ),
          _buildFeatureButton(
            'Health Tracking',
            Icons.favorite,
            HealthTrackingScreen(),
            Colors.red,
          ),
          _buildFeatureButton(
            'Medications',
            Icons.medical_services,
            MedicationReminderScreen(),
            Colors.green,
          ),
          _buildFeatureButton(
            'Diet & Nutrition',
            Icons.restaurant_menu,
            DietNutritionScreen(),
            Colors.orange,
          ),
          _buildFeatureButton(
            'Activity',
            Icons.directions_run,
            ActivityTrackingScreen(),
            Colors.purple,
          ),
          _buildFeatureButton(
            'Appointments',
            Icons.event,
            AppointmentSchedulerScreen(),
            Colors.brown,
          ),
          _buildFeatureButton(
            'My AI Advisor',
            Icons.school,
            MyAIAdvisorScreen(),
            Colors.cyan,
          ),
          _buildFeatureButton(
            'Emergency',
            Icons.emergency,
            EmergencyContactsScreen(),
            Colors.red,
          ),
        ],
      ),
    );
  }

  Widget _buildEmergencySection() {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => EmergencyContactsScreen()),
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.red.shade100,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.red, width: 2),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.emergency,
              size: widget.currentFontSize != null ? widget.currentFontSize! * 2 : 48,
              color: Colors.red,
            ),
            const SizedBox(width: 16),
            Text(
              'Emergency\nHelp',
              style: TextStyle(
                fontSize: widget.currentFontSize != null ? widget.currentFontSize! * 1.5 : 24,
                fontWeight: FontWeight.bold,
                color: Colors.red,
                height: 1.2,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLargeFeatureCard(
    String title,
    IconData icon,
    Color color,
    Widget screen,
    String subtitle,
  ) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => screen),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: color.withOpacity(0.5),
            width: 2,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: widget.currentFontSize != null ? widget.currentFontSize! * 2.5 : 64,
              color: color,
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: TextStyle(
                fontSize: widget.currentFontSize != null ? widget.currentFontSize! * 1.2 : 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: widget.currentFontSize != null ? widget.currentFontSize! * 0.8 : 16,
                color: color.withOpacity(0.8),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureButton(
    String title,
    IconData icon,
    Widget screen,
    Color iconColor,
  ) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.all(widget.isHighContrast ?? false ? 12.0 : 8.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
          side: BorderSide(
            color: widget.isHighContrast ?? false ? Colors.white : Colors.transparent,
            width: widget.isHighContrast ?? false ? 2 : 0,
          ),
        ),
        backgroundColor: widget.isHighContrast ?? false
            ? Colors.black
            : isDarkMode
                ? Theme.of(context).primaryColor.withOpacity(0.8)
                : Colors.white,
        elevation: 4,
      ),
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => screen),
        );
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(
            icon,
            size: widget.currentFontSize != null ? widget.currentFontSize! * 2 : 40,
            color: iconColor,
          ),
          const SizedBox(height: 8),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: widget.currentFontSize ?? 16.0,
              fontWeight: FontWeight.bold,
              color: widget.isHighContrast ?? false
                  ? Colors.white
                  : isDarkMode
                      ? Colors.white
                      : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionsFooter() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildQuickActionButton(
            'Settings',
            Icons.settings,
            () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SettingsScreen(
                    onThemeChanged: widget.onThemeChanged ?? (_) {},
                  ),
                ),
              );
            },
          ),
          _buildQuickActionButton(
            'Help',
            Icons.help,
            () {
              // Show help dialog
              _showHelpDialog();
            },
          ),
          _buildQuickActionButton(
            'Family',
            Icons.people,
            () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => EmergencyContactsScreen()),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionButton(
    String label,
    IconData icon,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: widget.currentFontSize != null ? widget.currentFontSize! * 1.5 : 32,
              color: Theme.of(context).primaryColor,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: widget.currentFontSize != null ? widget.currentFontSize! * 0.8 : 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Need Help?',
          style: TextStyle(fontSize: widget.currentFontSize ?? 20.0),
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Tap any button to access its features.\n\n'
                'The Emergency button at the top provides quick access to emergency contacts.\n\n'
                'Use the view mode button in the top bar to switch between simple and standard views.',
                style: TextStyle(fontSize: widget.currentFontSize ?? 16.0),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'OK',
              style: TextStyle(fontSize: widget.currentFontSize ?? 16.0),
            ),
          ),
        ],
      ),
    );
  }
}