import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:math';

class BMITrackingScreen extends StatefulWidget {
  const BMITrackingScreen({super.key});

  @override
  _BMITrackingScreenState createState() => _BMITrackingScreenState();
}

class _BMITrackingScreenState extends State<BMITrackingScreen> {
  List<FlSpot> bmiData = [];
  double minY = 0;
  double maxY = 40;

  @override
  void initState() {
    super.initState();
    _loadBMIData();
  }

  Future<void> _loadBMIData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? bmiHistory = prefs.getStringList('bmiHistory');
    if (bmiHistory != null && bmiHistory.isNotEmpty) {
      setState(() {
        bmiData = bmiHistory.asMap().entries.map((entry) {
          return FlSpot(entry.key.toDouble(), double.parse(entry.value));
        }).toList();

        minY = bmiData.map((spot) => spot.y).reduce(min) - 1;
        maxY = bmiData.map((spot) => spot.y).reduce(max) + 1;
      });
    }
  }

  String _getBMICategory(double bmi) {
    if (bmi < 18.5) return 'Underweight';
    if (bmi < 25) return 'Normal';
    if (bmi < 30) return 'Overweight';
    return 'Obese';
  }

  Color _getBMIColor(double bmi) {
    if (bmi < 18.5) return Colors.blue;
    if (bmi < 25) return Colors.green;
    if (bmi < 30) return Colors.orange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('BMI Tracking'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Your BMI Over Time', style: Theme.of(context).textTheme.titleLarge),
            SizedBox(height: 16),
            Expanded(
              child: bmiData.isEmpty
                  ? Center(child: Text('No BMI data available. Please update your weight and height in settings.'))
                  : LineChart(
                      LineChartData(
                        gridData: FlGridData(
                          show: true,
                          drawVerticalLine: true,
                          getDrawingHorizontalLine: (value) {
                            return FlLine(
                              color: Colors.grey[300],
                              strokeWidth: 1,
                            );
                          },
                          getDrawingVerticalLine: (value) {
                            return FlLine(
                              color: Colors.grey[300],
                              strokeWidth: 1,
                            );
                          },
                        ),
                        titlesData: FlTitlesData(
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 22,
                              getTitlesWidget: (value, meta) {
                                return Text(
                                  value % 5 == 0 ? value.toInt().toString() : '',
                                  style: const TextStyle(
                                    color: Color(0xff68737d),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                );
                              },
                            ),
                          ),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                return Text(
                                  value % 5 == 0 ? value.toInt().toString() : '',
                                  style: const TextStyle(
                                    color: Color(0xff67727d),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                );
                              },
                              reservedSize: 28,
                            ),
                          ),
                          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        ),
                        borderData: FlBorderData(
                          show: true,
                          border: Border.all(color: const Color(0xff37434d), width: 1),
                        ),
                        minX: 0,
                        maxX: bmiData.length.toDouble() - 1,
                        minY: minY,
                        maxY: maxY,
                        lineBarsData: [
                          LineChartBarData(
                            spots: bmiData,
                            isCurved: true,
                            color: Colors.blue,
                            barWidth: 3,
                            isStrokeCapRound: true,
                            dotData: FlDotData(show: false),
                            belowBarData: BarAreaData(show: false),
                          ),
                        ],
                        lineTouchData: LineTouchData(
                          touchTooltipData: LineTouchTooltipData(
                            // tooltipBgColor: Colors.black, // Remove this line
                            // Add any other necessary parameters or modifications here
                          ),
                          handleBuiltInTouches: true,
                        ),
                      ),
                    ),
            ),
            SizedBox(height: 16),
            Text(
              'BMI Categories:',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            _buildBMICategoryRow('Underweight', '< 18.5', Colors.blue),
            _buildBMICategoryRow('Normal weight', '18.5 - 24.9', Colors.green),
            _buildBMICategoryRow('Overweight', '25 - 29.9', Colors.orange),
            _buildBMICategoryRow('Obese', '≥ 30', Colors.red),
          ],
        ),
      ),
    );
  }

  Widget _buildBMICategoryRow(String category, String range, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Container(
            width: 16,
            height: 16,
            color: color,
            margin: EdgeInsets.only(right: 8),
          ),
          Text('$category: $range', style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}
