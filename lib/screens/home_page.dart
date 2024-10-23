// lib/screens/home_page.dart

import 'package:flutter/material.dart';
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

class HomePage extends StatelessWidget {
  final Function(bool)? onThemeChanged;
  final Function(double)? onFontSizeChanged;
  final Function(bool)? onHighContrastChanged;
  final double? currentFontSize;
  final bool? isHighContrast;

  const HomePage({
    Key? key,
    this.onThemeChanged,
    this.onFontSizeChanged,
    this.onHighContrastChanged,
    this.currentFontSize,
    this.isHighContrast,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Health Companion',
          style: TextStyle(fontSize: currentFontSize ?? 20.0),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SettingsScreen(
                    onThemeChanged: onThemeChanged ?? (_) {},
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
                  fontSize: currentFontSize ?? 24.0,
                ),
              ),
            ),
            ListTile(
              title: Text(
                'My AI Advisor',
                style: TextStyle(fontSize: currentFontSize ?? 16.0),
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
      // Replace the existing body with this new implementation
      body: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? Theme.of(context).scaffoldBackgroundColor
              : Colors.grey[100], // Light grey background in light mode
        ),
        child: GridView.count(
          crossAxisCount: 2,
          padding: EdgeInsets.all(16.0),
          childAspectRatio: 3 / 2,
          crossAxisSpacing: 16, // Increased spacing
          mainAxisSpacing: 16, // Increased spacing
          children: <Widget>[
            _buildFeatureButton(
              context,
              'Dashboard',
              Icons.dashboard,
              DashboardScreen(),
              Colors.blue,
            ),
            _buildFeatureButton(
              context,
              'Health Tracking',
              Icons.favorite,
              HealthTrackingScreen(),
              Colors.red,
            ),
            _buildFeatureButton(
              context,
              'Medications',
              Icons.medical_services,
              MedicationReminderScreen(),
              Colors.green,
            ),
            _buildFeatureButton(
              context,
              'Diet & Nutrition',
              Icons.restaurant_menu,
              DietNutritionScreen(),
              Colors.orange,
            ),
            _buildFeatureButton(
              context,
              'Activity',
              Icons.directions_run,
              ActivityTrackingScreen(),
              Colors.purple,
            ),
            _buildFeatureButton(
              context,
              'Appointments',
              Icons.event,
              AppointmentSchedulerScreen(),
              Colors.brown,
            ),
            _buildFeatureButton(
              context,
              'My AI Advisor',
              Icons.school,
              MyAIAdvisorScreen(),
              Colors.cyan,
            ),
            _buildFeatureButton(
              context,
              'Emergency Contacts',
              Icons.emergency,
              EmergencyContactsScreen(),
              Colors.red,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureButton(
    BuildContext context,
    String title,
    IconData icon,
    Widget screen,
    Color iconColor,
  ) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.all(isHighContrast ?? false ? 12.0 : 8.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
          side: BorderSide(
            color: isHighContrast ?? false ? Colors.white : Colors.transparent,
            width: isHighContrast ?? false ? 2 : 0,
          ),
        ),
        backgroundColor: isHighContrast ?? false
            ? Colors.black
            : isDarkMode
                ? Theme.of(context).primaryColor.withOpacity(0.8)
                : Colors.white, // White background in light mode
        elevation: 4, // Add some elevation for better visibility
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
            size: currentFontSize != null ? currentFontSize! * 2 : 40,
            color: iconColor, // Keep the original icon color
          ),
          SizedBox(height: 8),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: currentFontSize ?? 16.0,
              fontWeight: FontWeight.bold, // Make text bold for better visibility
              color: isHighContrast ?? false
                  ? Colors.white
                  : isDarkMode
                      ? Colors.white
                      : Colors.black87, // Dark text in light mode
            ),
          ),
        ],
      ),
    );
  }
}