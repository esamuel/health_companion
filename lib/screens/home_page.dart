import 'package:flutter/material.dart';
import 'dashboard_screen.dart';
import 'health_tracking_screen.dart';
import 'medication_reminder_screen.dart';
import 'diet_nutrition_screen.dart';
import 'activity_tracking_screen.dart';
import 'appointment_scheduler_screen.dart';
import 'health_education_screen.dart';
import 'emergency_contacts_screen.dart';
import 'settings_screen.dart';

class HomePage extends StatelessWidget {
  final Function(bool) onThemeChanged;

  const HomePage({super.key, required this.onThemeChanged});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Health Companion'),
        actions: [
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SettingsScreen(
                    onThemeChanged: onThemeChanged,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: GridView.count(
        crossAxisCount: 2,
        padding: EdgeInsets.all(16.0),
        childAspectRatio: 3 / 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        children: <Widget>[
          _buildFeatureButton(
              context, 'Dashboard', Icons.dashboard, DashboardScreen()),
          _buildFeatureButton(context, 'Health Tracking', Icons.favorite,
              HealthTrackingScreen()),
          _buildFeatureButton(context, 'Medications', Icons.medical_services,
              MedicationReminderScreen()),
          _buildFeatureButton(context, 'Diet & Nutrition',
              Icons.restaurant_menu, DietNutritionScreen()),
          _buildFeatureButton(context, 'Activity', Icons.directions_run,
              ActivityTrackingScreen()),
          _buildFeatureButton(context, 'Appointments', Icons.event,
              AppointmentSchedulerScreen()),
          _buildFeatureButton(context, 'Health Education', Icons.school,
              HealthEducationScreen()),
          _buildFeatureButton(context, 'Emergency Contacts', Icons.emergency,
              EmergencyContactsScreen()),
        ],
      ),
    );
  }

  Widget _buildFeatureButton(
      BuildContext context, String title, IconData icon, Widget screen) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.all(8.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
      ),
      onPressed: () {
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => screen));
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(icon, size: 40),
          SizedBox(height: 8),
          Text(title, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
