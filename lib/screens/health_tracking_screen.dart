import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:flutter/foundation.dart';

class HealthTrackingScreen extends StatefulWidget {
  @override
  _HealthTrackingScreenState createState() => _HealthTrackingScreenState();
}

class _HealthTrackingScreenState extends State<HealthTrackingScreen> {
  TextEditingController _nameController = TextEditingController();
  TextEditingController _valueController = TextEditingController();

  List<Map<String, dynamic>> healthMetrics = [];

  Future<void> _saveMetrics() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final List<Map<String, dynamic>> serializableMetrics = healthMetrics.map((metric) {
        return {
          'name': metric['name'],
          'value': metric['value'],
          'icon': metric['icon'].toString(),
        };
      }).toList();
      await prefs.setString('healthMetrics', jsonEncode(serializableMetrics));
    } catch (e) {
      if (kDebugMode) {
        print('Error saving metrics: $e');
      }
      // You might want to show an error message to the user here
    }
  }

  Future<void> _loadMetrics() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      String? metricsString = prefs.getString('healthMetrics');
      if (metricsString != null) {
        final List<dynamic> decodedMetrics = jsonDecode(metricsString);
        setState(() {
          healthMetrics = decodedMetrics.map((metric) {
            return {
              'name': metric['name'],
              'value': metric['value'],
              'icon': _getIconFromString(metric['icon']),
            };
          }).toList();
        });
      } else {
        _initializeDefaultMetrics();
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error loading metrics: $e');
      }
      _initializeDefaultMetrics();
    }
  }

  void _initializeDefaultMetrics() {
    setState(() {
      healthMetrics = [
        {'name': 'Blood Pressure', 'value': '120/80 mmHg', 'icon': Icons.favorite},
        {'name': 'Glucose Level', 'value': '95 mg/dL', 'icon': Icons.bloodtype},
        {'name': 'Heart Rate', 'value': '72 BPM', 'icon': Icons.monitor_heart},
        {'name': 'Weight', 'value': '75 kg', 'icon': Icons.fitness_center},
      ];
    });
  }

  IconData _getIconFromString(String iconString) {
    switch (iconString) {
      case 'IconData(U+0E87D)':
        return Icons.favorite;
      case 'IconData(U+0E95F)':
        return Icons.bloodtype;
      case 'IconData(U+0F0374)':
        return Icons.monitor_heart;
      case 'IconData(U+0E328)':
        return Icons.fitness_center;
      default:
        return Icons.device_thermostat;
    }
  }

  @override
  void initState() {
    super.initState();
    _loadMetrics();
  }

  void _showAddHealthMetricDialog() {
    _nameController.clear();
    _valueController.clear();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add Health Metric'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Metric Name'),
            ),
            TextField(
              controller: _valueController,
              decoration: InputDecoration(labelText: 'Value'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              setState(() {
                healthMetrics.add({
                  'name': _nameController.text,
                  'value': _valueController.text,
                  'icon': Icons.device_thermostat,
                });
              });
              await _saveMetrics();
              Navigator.of(context).pop();
            },
            child: Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showEditHealthMetricDialog(int index) {
    _nameController.text = healthMetrics[index]['name'];
    _valueController.text = healthMetrics[index]['value'];
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit Health Metric'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Metric Name'),
            ),
            TextField(
              controller: _valueController,
              decoration: InputDecoration(labelText: 'Value'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              setState(() {
                healthMetrics[index] = {
                  'name': _nameController.text,
                  'value': _valueController.text,
                  'icon': healthMetrics[index]['icon'],
                };
              });
              await _saveMetrics();
              Navigator.of(context).pop();
            },
            child: Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Health Tracking', style: TextStyle(fontSize: 18, color: Colors.black)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: healthMetrics.length,
                itemBuilder: (context, index) {
                  return Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: GestureDetector(
                      onTap: () {
                        _showEditHealthMetricDialog(index);
                      },
                      child: ListTile(
                        leading: Icon(healthMetrics[index]['icon'], color: Colors.blue),
                        title: Text(healthMetrics[index]['name'],
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        subtitle: Text(healthMetrics[index]['value']),
                        trailing: Icon(Icons.edit),
                      ),
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Health Metrics Trend',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Container(
              height: 200,
              child: LineChart(
                LineChartData(
                  borderData: FlBorderData(show: false),
                  titlesData: FlTitlesData(show: false),
                  gridData: FlGridData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: [
                        FlSpot(0, 3),
                        FlSpot(1, 4),
                        FlSpot(2, 3.5),
                        FlSpot(3, 5),
                        FlSpot(4, 4),
                        FlSpot(5, 4.5),
                      ],
                      isCurved: true,
                      color: Colors.blue,
                      dotData: FlDotData(show: false),
                      belowBarData: BarAreaData(show: false),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddHealthMetricDialog();
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
