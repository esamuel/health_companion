import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class MedicationReminderScreen extends StatefulWidget {
  const MedicationReminderScreen({super.key});

  @override
  _MedicationReminderScreenState createState() => _MedicationReminderScreenState();
}

class _MedicationReminderScreenState extends State<MedicationReminderScreen> {
  List<Map<String, String>> medications = [];
  TextEditingController nameController = TextEditingController();
  TextEditingController dosageController = TextEditingController();
  TextEditingController timeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadMedications();
  }

  void _loadMedications() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      medications = (prefs.getStringList('medications') ?? [])
          .map((item) => Map<String, String>.from(json.decode(item)))
          .toList();
    });
  }

  void _saveMedications() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> encodedMedications = medications
        .map((item) => json.encode(item))
        .toList();
    await prefs.setStringList('medications', encodedMedications);
  }

  void _addMedication() {
    if (nameController.text.isNotEmpty &&
        dosageController.text.isNotEmpty &&
        timeController.text.isNotEmpty) {
      setState(() {
        medications.add({
          'name': nameController.text,
          'dosage': dosageController.text,
          'time': timeController.text,
        });
        _saveMedications();
        _clearInputFields();
      });
    }
  }

  void _editMedication(int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        TextEditingController editNameController = TextEditingController(text: medications[index]['name']);
        TextEditingController editDosageController = TextEditingController(text: medications[index]['dosage']);
        TextEditingController editTimeController = TextEditingController(text: medications[index]['time']);

        return AlertDialog(
          title: Text('Edit Medication'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: editNameController,
                  decoration: InputDecoration(labelText: 'Medication Name'),
                ),
                TextField(
                  controller: editDosageController,
                  decoration: InputDecoration(labelText: 'Dosage'),
                ),
                TextField(
                  controller: editTimeController,
                  decoration: InputDecoration(labelText: 'Time'),
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
                setState(() {
                  medications[index] = {
                    'name': editNameController.text,
                    'dosage': editDosageController.text,
                    'time': editTimeController.text,
                  };
                  _saveMedications();
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _clearInputFields() {
    nameController.clear();
    dosageController.clear();
    timeController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Medication Reminders')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: medications.length,
              itemBuilder: (context, index) {
                final medication = medications[index];
                return ListTile(
                  title: Text(medication['name'] ?? ''),
                  subtitle: Text('${medication['dosage']} - ${medication['time']}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () => _editMedication(index),
                      ),
                      IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () {
                          setState(() {
                            medications.removeAt(index);
                            _saveMedications();
                          });
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Column(
              children: [
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(labelText: 'Medication Name'),
                ),
                TextField(
                  controller: dosageController,
                  decoration: InputDecoration(labelText: 'Dosage'),
                ),
                TextField(
                  controller: timeController,
                  decoration: InputDecoration(labelText: 'Time'),
                ),
                ElevatedButton(
                  onPressed: _addMedication,
                  child: Text('Add Medication'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}