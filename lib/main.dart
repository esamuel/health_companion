// Flutter code to set up the basic structure of "Health_companion" app

import 'package:flutter/material.dart';

void main() {
  runApp(HealthCompanionApp());
}

class HealthCompanionApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Health Companion',
      theme: ThemeData(
        primarySwatch: Colors.teal,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    DashboardScreen(),
    HealthTrackingScreen(),
    FastingTimerScreen(),
    MealPlannerScreen(),
    ActivityTrackingScreen(),
  ];

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
                MaterialPageRoute(builder: (context) => SettingsScreen()),
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
                color: Colors.teal,
              ),
              child: Text(
                'Health Companion',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.person),
              title: Text('Profile'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ProfileScreen()),
                );
              },
            ),
          ],
        ),
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(), // Dismiss the keyboard when tapping outside
        child: _screens[_currentIndex],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Health Tracking',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.timer),
            label: 'Fasting Timer',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.restaurant),
            label: 'Meal Planner',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.directions_run),
            label: 'Activity Tracking',
          ),
        ],
      ),
    );
  }
}

// Placeholder screens for each section
class DashboardScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('Dashboard Screen'),
    );
  }
}

class HealthTrackingScreen extends StatelessWidget {
  final TextEditingController bloodPressureController = TextEditingController();
  final TextEditingController glucoseLevelController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          TextField(
            controller: bloodPressureController,
            decoration: InputDecoration(
              labelText: 'Enter Blood Pressure (e.g., 138/72)',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.text, // Allow slash character for blood pressure input
          ),
          SizedBox(height: 16),
          TextField(
            controller: glucoseLevelController,
            decoration: InputDecoration(
              labelText: 'Enter Glucose Level',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.numberWithOptions(decimal: true),
          ),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              FocusScope.of(context).unfocus(); // Dismiss the keyboard after saving
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Data Saved: BP: ${bloodPressureController.text}, Glucose: ${glucoseLevelController.text}'),
                ),
              );
            },
            child: Text('Save Data'),
          ),
        ],
      ),
    );
  }
}

class FastingTimerScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('Fasting Timer Screen'),
    );
  }
}

class MealPlannerScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('Meal Planner Screen'),
    );
  }
}

class ActivityTrackingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('Activity Tracking Screen'),
    );
  }
}

class SettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
      ),
      body: Center(
        child: Text('Settings Screen'),
      ),
    );
  }
}

class ProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
      ),
      body: Center(
        child: Text('Profile Screen'),
      ),
    );
  }
}