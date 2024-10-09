import 'package:flutter/material.dart';

class DashboardScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            _buildCard(context, 'Weight & BMI', [
              'Weight: 75 kg',
              'BMI: 23.4',
            ]),
            SizedBox(height: 16),
            _buildCard(context, 'Blood Pressure', [
              '120/80 mmHg',
            ]),
            SizedBox(height: 16),
            _buildCard(context, 'Heart Rate', [
              '75 BPM',
            ]),
            SizedBox(height: 16),
            _buildCard(context, 'Blood Glucose Level', [
              '95 mg/dL',
            ]),
            SizedBox(height: 16),
            _buildCard(context, 'Hydration Level', [
              '6 Glasses',
            ]),
            SizedBox(height: 16),
            _buildCard(context, 'Sleep Duration', [
              '7 hours',
            ]),
            SizedBox(height: 16),
            _buildCard(context, 'Activity Level', [
              'Steps Taken: 5000',
              'Calories Burned: 200 kcal',
            ]),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(BuildContext context, String title, List<String> content) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            SizedBox(height: 8),
            ...content.map((item) => Text(
                  item,
                  style: Theme.of(context).textTheme.bodyMedium,
                )),
          ],
        ),
      ),
    );
  }
}
