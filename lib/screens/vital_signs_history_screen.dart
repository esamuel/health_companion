import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'dart:convert';

class VitalSignsHistoryScreen extends StatefulWidget {
  @override
  _VitalSignsHistoryScreenState createState() => _VitalSignsHistoryScreenState();
}

class _VitalSignsHistoryScreenState extends State<VitalSignsHistoryScreen> {
  List<Map<String, dynamic>> _vitalSignsHistory = [];
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadVitalSignsHistory();
  }

  Future<void> _loadVitalSignsHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final historyJson = prefs.getString('vitalSignsHistory');
      print('Loaded JSON: $historyJson'); // Debug print

      if (historyJson != null && historyJson.isNotEmpty) {
        setState(() {
          _vitalSignsHistory = List<Map<String, dynamic>>.from(json.decode(historyJson))
            ..sort((b, a) => DateTime.parse(a['date']).compareTo(DateTime.parse(b['date']))); // Sort by date, most recent first
        });
        print('Parsed history: $_vitalSignsHistory'); // Debug print
      } else {
        print('No history data found');
        setState(() {
          _errorMessage = 'No history data available';
        });
      }
    } catch (e) {
      print('Error loading vital signs history: $e');
      setState(() {
        _errorMessage = 'Error loading data: $e';
      });
    }
  }

  Widget _buildTrendIndicator(String current, String previous) {
    if (previous.isEmpty) return SizedBox.shrink();
    
    double currentValue = double.tryParse(current.split('/').first) ?? 0;
    double previousValue = double.tryParse(previous.split('/').first) ?? 0;
    
    if (currentValue > previousValue) {
      return Icon(Icons.arrow_upward, color: Colors.red, size: 14);
    } else if (currentValue < previousValue) {
      return Icon(Icons.arrow_downward, color: Colors.green, size: 14);
    } else {
      return Icon(Icons.arrow_forward, color: Colors.grey, size: 14);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Vital Signs History'),
      ),
      body: _errorMessage.isNotEmpty
          ? Center(child: Text(_errorMessage))
          : _vitalSignsHistory.isEmpty
              ? Center(child: Text('No history available'))
              : ListView.builder(
                  itemCount: _vitalSignsHistory.length,
                  itemBuilder: (context, index) {
                    final item = _vitalSignsHistory[index];
                    final prevItem = index < _vitalSignsHistory.length - 1 ? _vitalSignsHistory[index + 1] : null;
                    return Card(
                      margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                      child: Padding(
                        padding: EdgeInsets.all(8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              DateFormat('yyyy-MM-dd HH:mm').format(DateTime.parse(item['date'])),
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 4),
                            _buildVitalSignRow('Blood Pressure', item['bloodPressure'] ?? '', prevItem?['bloodPressure'] ?? ''),
                            _buildVitalSignRow('Heart Rate', '${item['heartRate'] ?? ''} BPM', '${prevItem?['heartRate'] ?? ''} BPM'),
                            _buildVitalSignRow('Blood Glucose', '${item['bloodGlucose'] ?? ''} mg/dL', '${prevItem?['bloodGlucose'] ?? ''} mg/dL'),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }

  Widget _buildVitalSignRow(String label, String current, String previous) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(label),
          ),
          Expanded(
            flex: 3,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(current),
                SizedBox(width: 4),
                _buildTrendIndicator(current, previous),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
