import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ActivityTrackingScreen extends StatefulWidget {
  @override
  _ActivityTrackingScreenState createState() => _ActivityTrackingScreenState();
}

class _ActivityTrackingScreenState extends State<ActivityTrackingScreen> {
  DateTime selectedDate = DateTime.now();
  List<ActivityData> activities = [
    ActivityData('Steps', 7500),
    ActivityData('Water (ml)', 1500),
    ActivityData('Sleep (hrs)', 7.5),
    ActivityData('Meditation (min)', 15),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Activity Tracking'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  DateFormat('MMMM d, y').format(selectedDate),
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: Icon(Icons.calendar_today),
                  onPressed: () => _selectDate(context),
                ),
              ],
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: activities.length,
                itemBuilder: (context, index) {
                  return ActivityTile(activity: activities[index]);
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          // TODO: Implement add new activity functionality
        },
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != selectedDate)
      setState(() {
        selectedDate = picked;
        // TODO: Load activities for the selected date
      });
  }
}

class ActivityData {
  final String name;
  final num value;

  ActivityData(this.name, this.value);
}

class ActivityTile extends StatelessWidget {
  final ActivityData activity;

  const ActivityTile({Key? key, required this.activity}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(Icons.fitness_center), // TODO: Use appropriate icons for each activity type
        title: Text(activity.name),
        trailing: Text(
          activity.value.toString(),
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}