import 'package:flutter/material.dart';
import 'settings_screen.dart';
import 'ai_chat_screen.dart';
import 'health_tracking_screen.dart';
import 'activity_tracker_screen.dart';
import 'fasting_timer_screen.dart';
import 'meal_planner_screen.dart';
import 'medication_management_screen.dart';
import 'profile_screen.dart';

class DashboardScreen extends StatelessWidget {
  final Function(bool) onThemeChanged;

  DashboardScreen({required this.onThemeChanged});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Health Companion'),
      ),
      body: GridView.count(
        crossAxisCount: 2,
        padding: EdgeInsets.all(16.0),
        mainAxisSpacing: 16.0,
        crossAxisSpacing: 16.0,
        children: [
          _buildDashboardItem(
            context,
            'AI Chat',
            Icons.chat,
            () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AIChatScreen()),
            ),
          ),
          _buildDashboardItem(
            context,
            'Health Tracking',
            Icons.favorite,
            () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => HealthTrackingScreen()),
            ),
          ),
          _buildDashboardItem(
            context,
            'Activity Tracker',
            Icons.directions_run,
            () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ActivityTrackerScreen()),
            ),
          ),
          _buildDashboardItem(
            context,
            'Fasting Timer',
            Icons.timer,
            () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => FastingTimerScreen()),
            ),
          ),
          _buildDashboardItem(
            context,
            'Meal Planner',
            Icons.restaurant_menu,
            () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => MealPlannerScreen()),
            ),
          ),
          _buildDashboardItem(
            context,
            'Medication',
            Icons.medical_services,
            () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => MedicationManagementScreen()),
            ),
          ),
          _buildDashboardItem(
            context,
            'Profile',
            Icons.person,
            () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ProfileScreen()),
            ),
          ),
          _buildDashboardItem(
            context,
            'Settings',
            Icons.settings,
            () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SettingsScreen(onThemeChanged: onThemeChanged),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardItem(
    BuildContext context,
    String title,
    IconData icon,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      child: Card(
        elevation: 4,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48, color: Theme.of(context).primaryColor),
            SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
