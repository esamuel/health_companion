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

  Future<void> _resetBMIData() async {
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Reset BMI Data'),
          content: Text('Are you sure you want to reset all BMI tracking data? This cannot be undone.'),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            TextButton(
              child: Text(
                'Reset',
                style: TextStyle(color: Colors.red),
              ),
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.remove('bmiHistory');
      
      setState(() {
        bmiData = [];
        minY = 0;
        maxY = 40;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('BMI tracking data has been reset'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('BMI Tracking'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _resetBMIData,
            tooltip: 'Reset BMI Data',
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              LayoutBuilder(
                builder: (context, constraints) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(
                          'Your BMI Over Time',
                          style: Theme.of(context).textTheme.titleLarge,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      SizedBox(width: 8),
                      TextButton.icon(
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.symmetric(horizontal: 8),
                        ),
                        icon: Icon(Icons.delete_outline, color: Colors.red, size: 20),
                        label: Text(
                          'Clear',
                          style: TextStyle(color: Colors.red, fontSize: 12),
                        ),
                        onPressed: _resetBMIData,
                      ),
                    ],
                  );
                },
              ),
              Expanded(
                child: ListView(
                  children: [
                    SizedBox(height: 16),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.4,
                      child: bmiData.isEmpty
                          ? Center(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  'No BMI data available.\nPlease update your weight and height in settings.',
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            )
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
                                        return Padding(
                                          padding: const EdgeInsets.only(top: 8.0),
                                          child: Text(
                                            value % 5 == 0 ? value.toInt().toString() : '',
                                            style: const TextStyle(
                                              color: Color(0xff68737d),
                                              fontWeight: FontWeight.bold,
                                              fontSize: 10,
                                            ),
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
                                            fontSize: 10,
                                          ),
                                        );
                                      },
                                      reservedSize: 24,
                                    ),
                                  ),
                                  topTitles: AxisTitles(
                                    sideTitles: SideTitles(showTitles: false),
                                  ),
                                  rightTitles: AxisTitles(
                                    sideTitles: SideTitles(showTitles: false),
                                  ),
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
                                    getTooltipItems: (List<LineBarSpot> touchedSpots) {
                                      return touchedSpots.map((LineBarSpot touchedSpot) {
                                        return LineTooltipItem(
                                          'BMI: ${touchedSpot.y.toStringAsFixed(1)}',
                                          const TextStyle(color: Colors.white),
                                        );
                                      }).toList();
                                    },
                                  ),
                                  handleBuiltInTouches: true,
                                ),
                              ),
                            ),
                    ),
                    SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.only(left: 4.0),
                      child: Text(
                        'BMI Categories:',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildBMICategoryRow('Underweight', '< 18.5', Colors.blue),
                        _buildBMICategoryRow('Normal', '18.5-24.9', Colors.green),
                        _buildBMICategoryRow('Overweight', '25-29.9', Colors.orange),
                        _buildBMICategoryRow('Obese', '≥ 30', Colors.red),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBMICategoryRow(String category, String range, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 12,
            height: 12,
            color: color,
            margin: EdgeInsets.only(right: 4),
          ),
          Flexible(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                '$category: $range',
                style: Theme.of(context).textTheme.bodySmall,
                maxLines: 1,
              ),
            ),
          ),
        ],
      ),
    );
  }
}