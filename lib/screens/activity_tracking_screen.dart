import 'package:flutter/material.dart';
import 'package:pedometer/pedometer.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:async';

class ActivityTrackingScreen extends StatefulWidget {
  @override
  _ActivityTrackingScreenState createState() => _ActivityTrackingScreenState();
}

class _ActivityTrackingScreenState extends State<ActivityTrackingScreen> with WidgetsBindingObserver {
  int _steps = 0;
  double _sleepHours = 0;
  int _waterIntake = 0;
  late Stream<StepCount> _stepCountStream;
  late Stream<AccelerometerEvent> _accelerometerStream;
  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  Timer? _waterReminderTimer;
  DateTime _lastMovementTime = DateTime.now();
  bool _isSleeping = false;
  List<FlSpot> _stepData = [];
  List<FlSpot> _sleepData = [];
  List<FlSpot> _waterData = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    initPlatformState();
    initNotifications();
    loadData();
    startWaterReminder();
    startPeriodicSave();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      saveData();
    }
  }

  void initPlatformState() async {
    await Permission.activityRecognition.request();
    _stepCountStream = Pedometer.stepCountStream;
    _stepCountStream.listen(onStepCount).onError(onStepCountError);

    _accelerometerStream = accelerometerEvents;
    _accelerometerStream.listen((AccelerometerEvent event) {
      if (event.x.abs() > 1 || event.y.abs() > 1 || event.z.abs() > 1) {
        _lastMovementTime = DateTime.now();
        if (_isSleeping) {
          setState(() {
            _isSleeping = false;
          });
        }
      } else if (DateTime.now().difference(_lastMovementTime).inMinutes > 30) {
        if (!_isSleeping) {
          setState(() {
            _isSleeping = true;
          });
        }
        incrementSleepTime();
      }
    });
  }

  void onStepCount(StepCount event) {
    setState(() {
      _steps = event.steps;
      updateStepChart();
    });
  }

  void onStepCountError(error) {
    print('Step count error: $error');
  }

  void incrementSleepTime() {
    setState(() {
      _sleepHours += 1 / 60; // Add 1 minute
      updateSleepChart();
    });
  }

  void initNotifications() {
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    var initializationSettingsAndroid = AndroidInitializationSettings('app_icon');
    var initializationSettingsIOS = IOSInitializationSettings();
    var initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid, iOS: initializationSettingsIOS);
    flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  void startWaterReminder() {
    _waterReminderTimer = Timer.periodic(Duration(hours: 2), (timer) {
      if (DateTime.now().hour >= 8 && DateTime.now().hour <= 22) {
        showWaterReminder();
      }
    });
  }

  void showWaterReminder() async {
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'water_reminder_channel_id',
      'Water Reminder Notifications',
      importance: Importance.max,
      priority: Priority.high,
    );
    var iOSPlatformChannelSpecifics = IOSNotificationDetails();
    var platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics, iOS: iOSPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
      0,
      'Water Reminder',
      'Time to drink some water!',
      platformChannelSpecifics,
    );
  }

  void incrementWaterIntake() {
    setState(() {
      _waterIntake += 250; // Assuming one glass is 250ml
      updateWaterChart();
    });
  }

  void loadData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _steps = prefs.getInt('steps') ?? 0;
      _sleepHours = prefs.getDouble('sleep') ?? 0;
      _waterIntake = prefs.getInt('water') ?? 0;
      updateAllCharts();
    });
  }

  void saveData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt('steps', _steps);
    prefs.setDouble('sleep', _sleepHours);
    prefs.setInt('water', _waterIntake);
  }

  void startPeriodicSave() {
    Timer.periodic(Duration(minutes: 15), (timer) {
      saveData();
    });
  }

  void updateStepChart() {
    _stepData.add(FlSpot(_stepData.length.toDouble(), _steps.toDouble()));
    if (_stepData.length > 7) _stepData.removeAt(0);
  }

  void updateSleepChart() {
    _sleepData.add(FlSpot(_sleepData.length.toDouble(), _sleepHours));
    if (_sleepData.length > 7) _sleepData.removeAt(0);
  }

  void updateWaterChart() {
    _waterData.add(FlSpot(_waterData.length.toDouble(), _waterIntake.toDouble()));
    if (_waterData.length > 7) _waterData.removeAt(0);
  }

  void updateAllCharts() {
    updateStepChart();
    updateSleepChart();
    updateWaterChart();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Activity Tracking'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            
            children: [
  _buildInfoCard('Steps', _steps.toString(), Icons.directions_walk),
  SizedBox(height: 10),
  _buildChart(_stepData, Colors.blue, 'Steps'),
  SizedBox(height: 20),
  _buildInfoCard('Sleep', '${_sleepHours.toStringAsFixed(2)} hours', Icons.bedtime),
  SizedBox(height: 10),
  _buildChart(_sleepData, Colors.purple, 'Sleep (hours)'),
  SizedBox(height: 20),
  _buildInfoCard('Water Intake', '$_waterIntake ml', Icons.local_drink),
  SizedBox(height: 10),
  _buildChart(_waterData, Colors.cyan, 'Water (ml)'),
  SizedBox(height: 20),
  ElevatedButton(
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.blue,
      foregroundColor: Colors.white,
      padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
    ),
    onPressed: incrementWaterIntake,
    child: Text('Log Water Intake (250ml)'),
  ),
],  
  ),
        ),
      ),
    );
  }

  Widget _buildInfoCard(String title, String value, IconData icon) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(icon, size: 48, color: Colors.blue),
            SizedBox(width: 16),
            Flexible(  // Wrap the Column in a Flexible widget
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  Text(value, style: TextStyle(fontSize: 24)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChart(List<FlSpot> spots, Color color, String title) {
    return Container(
      height: 200,
      child: LineChart(
        LineChartData(
          gridData: FlGridData(show: false),
          titlesData: FlTitlesData(show: false),
          borderData: FlBorderData(show: true),
          minX: 0,
          maxX: 6,
          minY: 0,
          maxY: spots.isNotEmpty ? spots.map((spot) => spot.y).reduce((a, b) => a > b ? a : b) : 100,
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              color: color,
              barWidth: 4,
              isStrokeCapRound: true,
              dotData: FlDotData(show: false),
              belowBarData: BarAreaData(show: true, color: color.withOpacity(0.3)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _waterReminderTimer?.cancel();
    saveData();
    super.dispose();
  }
}
