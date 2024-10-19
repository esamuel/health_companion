import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class Appointment {
  String id;
  String name;
  String dateTime;
  String category;
  String notes;

  Appointment({
    required this.id,
    required this.name,
    required this.dateTime,
    required this.category,
    this.notes = '',
  });

  Map<String, String> toMap() => {
    'id': id,
    'name': name,
    'dateTime': dateTime,
    'category': category,
    'notes': notes,
  };

  factory Appointment.fromMap(Map<String, String> map) => Appointment(
    id: map['id'] ?? '',
    name: map['name'] ?? '',
    dateTime: map['dateTime'] ?? '',
    category: map['category'] ?? '',
    notes: map['notes'] ?? '',
  );

  @override
  String toString() => 'Appointment(id: $id, name: $name, dateTime: $dateTime, category: $category, notes: $notes)';
}

class AppointmentSchedulerScreen extends StatefulWidget {
  @override
  _AppointmentSchedulerScreenState createState() => _AppointmentSchedulerScreenState();
}

class _AppointmentSchedulerScreenState extends State<AppointmentSchedulerScreen> {
  List<Appointment> _appointments = [];
  final List<String> _categories = ['Doctor', 'Dentist', 'Therapy', 'Lab Test'];

  @override
  void initState() {
    super.initState();
    _loadAppointments();
  }

  Future<void> _loadAppointments() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final appointmentsList = prefs.getStringList('appointments') ?? [];
      print('Loaded appointments: $appointmentsList'); // Debug print

      setState(() {
        _appointments = appointmentsList
            .map((appointmentString) {
              try {
                final Map<String, String> appointmentMap = {};
                appointmentString.split(',').forEach((pair) {
                  final parts = pair.split(':');
                  if (parts.length == 2) {
                    appointmentMap[parts[0]] = parts[1];
                  }
                });
                return Appointment.fromMap(appointmentMap);
              } catch (e) {
                print('Error parsing appointment: $appointmentString. Error: $e'); // Debug print
                return null;
              }
            })
            .where((appointment) => appointment != null)
            .cast<Appointment>()
            .toList();
        _sortAppointments();
      });
      print('Parsed appointments: $_appointments'); // Debug print
    } catch (e) {
      print('Error loading appointments: $e'); // Debug print
    }
  }

  Future<void> _saveAppointments() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final appointmentsList = _appointments
          .map((appointment) => appointment.toMap().entries
              .map((e) => '${e.key}:${e.value}')
              .join(','))
          .toList();
      print('Saving appointments: $appointmentsList'); // Debug print
      await prefs.setStringList('appointments', appointmentsList);
      print('Appointments saved successfully'); // Debug print
    } catch (e) {
      print('Error saving appointments: $e'); // Debug print
    }
  }

  void _sortAppointments() {
    _appointments.sort((a, b) {
      if (a.dateTime.isEmpty || b.dateTime.isEmpty) return 0;
      try {
        return DateTime.parse(a.dateTime).compareTo(DateTime.parse(b.dateTime));
      } catch (e) {
        print('Error sorting appointments: $e'); // Debug print
        return 0;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Appointment Scheduler'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              _loadAppointments();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Appointments refreshed')),
              );
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: _appointments.length,
        itemBuilder: (context, index) {
          final appointment = _appointments[index];
          return Card(
            margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: ListTile(
              title: Text(appointment.name),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${appointment.category} - ${appointment.dateTime}'),
                  if (appointment.notes.isNotEmpty)
                    Text(appointment.notes, style: TextStyle(fontStyle: FontStyle.italic)),
                ],
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(Icons.edit),
                    onPressed: () => _showAddEditAppointmentDialog(context, appointment: appointment),
                  ),
                  IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () async {
                      setState(() {
                        _appointments.remove(appointment);
                      });
                      await _saveAppointments();
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () => _showAddEditAppointmentDialog(context),
      ),
    );
  }

  void _showAddEditAppointmentDialog(BuildContext context, {Appointment? appointment}) {
    final isEditing = appointment != null;
    final nameController = TextEditingController(text: appointment?.name ?? '');
    final notesController = TextEditingController(text: appointment?.notes ?? '');
    String selectedCategory = appointment?.category ?? _categories.first;
    DateTime selectedDateTime = isEditing && appointment.dateTime.isNotEmpty
        ? DateTime.parse(appointment.dateTime)
        : DateTime.now();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isEditing ? 'Edit Appointment' : 'Add Appointment'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: 'Name'),
              ),
              DropdownButtonFormField<String>(
                value: selectedCategory,
                items: _categories
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (value) {
                  selectedCategory = value!;
                },
                decoration: InputDecoration(labelText: 'Category'),
              ),
              ListTile(
                title: Text('Date and Time'),
                subtitle: Text(DateFormat('yyyy-MM-dd HH:mm').format(selectedDateTime)),
                trailing: Icon(Icons.calendar_today),
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: selectedDateTime,
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2101),
                  );
                  if (date != null) {
                    final time = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.fromDateTime(selectedDateTime),
                    );
                    if (time != null) {
                      selectedDateTime = DateTime(
                        date.year,
                        date.month,
                        date.day,
                        time.hour,
                        time.minute,
                      );
                    }
                  }
                },
              ),
              TextField(
                controller: notesController,
                decoration: InputDecoration(labelText: 'Notes'),
                maxLines: 3,
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
            child: Text(isEditing ? 'Save' : 'Add'),
            onPressed: () async {
              if (nameController.text.isNotEmpty) {
                final updatedAppointment = Appointment(
                  id: isEditing ? appointment.id : DateTime.now().millisecondsSinceEpoch.toString(),
                  name: nameController.text,
                  dateTime: DateFormat('yyyy-MM-dd HH:mm').format(selectedDateTime),
                  category: selectedCategory,
                  notes: notesController.text,
                );
                setState(() {
                  if (isEditing) {
                    final index = _appointments.indexWhere((a) => a.id == appointment.id);
                    _appointments[index] = updatedAppointment;
                  } else {
                    _appointments.add(updatedAppointment);
                  }
                  _sortAppointments();
                });
                await _saveAppointments();
                print('Appointment ${isEditing ? 'updated' : 'added'}: $updatedAppointment'); // Debug print
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Appointment ${isEditing ? 'updated' : 'added'}')),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}