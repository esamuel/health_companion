import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class MedicationReminder {
  final String name;
  final String dosage;
  final TimeOfDay timeToTake;
  final TimeOfDay alertTime;

  MedicationReminder({
    required this.name,
    required this.dosage,
    required this.timeToTake,
    required this.alertTime,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'dosage': dosage,
    'timeToTake': '${timeToTake.hour}:${timeToTake.minute}',
    'alertTime': '${alertTime.hour}:${alertTime.minute}',
  };

  static MedicationReminder fromJson(Map<String, dynamic> json) => MedicationReminder(
    name: json['name'],
    dosage: json['dosage'],
    timeToTake: TimeOfDay(hour: int.parse(json['timeToTake'].split(':')[0]), minute: int.parse(json['timeToTake'].split(':')[1])),
    alertTime: TimeOfDay(hour: int.parse(json['alertTime'].split(':')[0]), minute: int.parse(json['alertTime'].split(':')[1])),
  );
}

class MedicationReminderScreen extends StatefulWidget {
  @override
  _MedicationReminderScreenState createState() => _MedicationReminderScreenState();
}

class _MedicationReminderScreenState extends State<MedicationReminderScreen> {
  final List<MedicationReminder> _reminders = [];
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _loadReminders();
  }

  void _loadReminders() async {
    final prefs = await SharedPreferences.getInstance();
    final String? remindersJson = prefs.getString('reminders');
    if (remindersJson != null) {
      setState(() {
        final List<dynamic> jsonDecoded = json.decode(remindersJson);
        _reminders.clear();
        _reminders.addAll(jsonDecoded.map((json) => MedicationReminder.fromJson(json as Map<String, dynamic>)));
      });
    }
  }

  void _saveReminders() async {
    final prefs = await SharedPreferences.getInstance();
    final String encodedData = json.encode(_reminders.map((reminder) => reminder.toJson()).toList());
    await prefs.setString('reminders', encodedData);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Medication Reminders'),
      ),
      body: ListView.builder(
        itemCount: _reminders.length,
        itemBuilder: (context, index) {
          final reminder = _reminders[index];
          return ListTile(
            title: Text(reminder.name),
            subtitle: Text('${reminder.dosage} at ${reminder.timeToTake.format(context)}'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: () => _editReminder(index),
                ),
                IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () => _deleteReminder(index),
                ),
                Text('Alert: ${reminder.alertTime.format(context)}'),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddReminderDialog,
        child: Icon(Icons.add),
      ),
    );
  }

  void _showAddReminderDialog() {
    String name = '';
    String dosage = '';
    TimeOfDay timeToTake = TimeOfDay.now();
    TimeOfDay alertTime = TimeOfDay.now();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add Medication Reminder'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  decoration: InputDecoration(labelText: 'Medication Name'),
                  onChanged: (value) => name = value,
                ),
                TextField(
                  decoration: InputDecoration(labelText: 'Dosage'),
                  onChanged: (value) => dosage = value,
                ),
                ListTile(
                  title: Text('Time to Take'),
                  subtitle: Text(timeToTake.format(context)),
                  onTap: () async {
                    final TimeOfDay? picked = await showTimePicker(
                      context: context,
                      initialTime: timeToTake,
                    );
                    if (picked != null && picked != timeToTake) {
                      setState(() {
                        timeToTake = picked;
                      });
                    }
                  },
                ),
                ListTile(
                  title: Text('Alert Time'),
                  subtitle: Text(alertTime.format(context)),
                  onTap: () async {
                    final TimeOfDay? picked = await showTimePicker(
                      context: context,
                      initialTime: alertTime,
                    );
                    if (picked != null && picked != alertTime) {
                      setState(() {
                        alertTime = picked;
                      });
                    }
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text('Save'),
              onPressed: () {
                if (name.isNotEmpty && dosage.isNotEmpty) {
                  setState(() {
                    _reminders.add(MedicationReminder(
                      name: name,
                      dosage: dosage,
                      timeToTake: timeToTake,
                      alertTime: alertTime,
                    ));
                    _saveReminders();  // Ensure reminders are saved after adding
                  });
                  Navigator.of(context).pop();
                  _scheduleAlert(alertTime);
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _scheduleAlert(TimeOfDay alertTime) {
    // This is a simplified version. In a real app, you'd use a background service or plugin like flutter_local_notifications
    final now = DateTime.now();
    final scheduledTime = DateTime(
      now.year,
      now.month,
      now.day,
      alertTime.hour,
      alertTime.minute,
    );
    
    final difference = scheduledTime.difference(now);
    if (difference.isNegative) {
      // If the time has already passed today, schedule for tomorrow
      scheduledTime.add(Duration(days: 1));
    }

    Future.delayed(difference, () {
      _playAlertSound();
    });
  }

  void _playAlertSound() async {
    print("Attempting to play sound: assets/sounds/alert.mp3");
    try {
      final player = AudioPlayer();
      await player.setSource(AssetSource('sounds/alert.mp3'));
      await player.resume();
      print("Sound played successfully");
    } catch (e) {
      print("Error playing sound: $e");
    }
  }

  void _editReminder(int index) {
    MedicationReminder reminder = _reminders[index];
    String name = reminder.name;
    String dosage = reminder.dosage;
    TimeOfDay timeToTake = reminder.timeToTake;
    TimeOfDay alertTime = reminder.alertTime;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit Medication Reminder'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: TextEditingController(text: name),
                  decoration: InputDecoration(labelText: 'Medication Name'),
                  onChanged: (value) => name = value,
                ),
                TextField(
                  controller: TextEditingController(text: dosage),
                  decoration: InputDecoration(labelText: 'Dosage'),
                  onChanged: (value) => dosage = value,
                ),
                ListTile(
                  title: Text('Time to Take'),
                  subtitle: Text(timeToTake.format(context)),
                  onTap: () async {
                    final TimeOfDay? picked = await showTimePicker(
                      context: context,
                      initialTime: timeToTake,
                    );
                    if (picked != null && picked != timeToTake) {
                      setState(() {
                        timeToTake = picked;
                      });
                    }
                  },
                ),
                ListTile(
                  title: Text('Alert Time'),
                  subtitle: Text(alertTime.format(context)),
                  onTap: () async {
                    final TimeOfDay? picked = await showTimePicker(
                      context: context,
                      initialTime: alertTime,
                    );
                    if (picked != null && picked != alertTime) {
                      setState(() {
                        alertTime = picked;
                      });
                    }
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text('Save'),
              onPressed: () {
                if (name.isNotEmpty && dosage.isNotEmpty) {
                  setState(() {
                    _reminders[index] = MedicationReminder(
                      name: name,
                      dosage: dosage,
                      timeToTake: timeToTake,
                      alertTime: alertTime,
                    );
                    _saveReminders();  // Ensure reminders are saved after editing
                  });
                  Navigator.of(context).pop();
                  _scheduleAlert(alertTime);
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _deleteReminder(int index) {
    setState(() {
      _reminders.removeAt(index);
      _saveReminders();  // Ensure reminders are saved after deletion
    });
  }
}
