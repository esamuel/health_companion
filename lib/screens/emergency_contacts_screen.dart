import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:convert';

enum ContactCategory {
  FAMILY,
  DOCTOR,
  NEIGHBOR,
  OTHER
}

extension ContactCategoryExtension on ContactCategory {
  String get displayName {
    switch (this) {
      case ContactCategory.FAMILY:
        return 'Family';
      case ContactCategory.DOCTOR:
        return 'Doctor';
      case ContactCategory.NEIGHBOR:
        return 'Neighbor';
      case ContactCategory.OTHER:
        return 'Other';
    }
  }

  IconData get icon {
    switch (this) {
      case ContactCategory.FAMILY:
        return Icons.family_restroom;
      case ContactCategory.DOCTOR:
        return Icons.medical_services;
      case ContactCategory.NEIGHBOR:
        return Icons.home;
      case ContactCategory.OTHER:
        return Icons.person;
    }
  }

  Color get color {
    switch (this) {
      case ContactCategory.FAMILY:
        return Colors.green;
      case ContactCategory.DOCTOR:
        return Colors.blue;
      case ContactCategory.NEIGHBOR:
        return Colors.orange;
      case ContactCategory.OTHER:
        return Colors.grey;
    }
  }
}

class EmergencyContact {
  String name;
  String relationship;
  String phoneNumber;
  bool isPrimary;
  ContactCategory category;

  EmergencyContact({
    required this.name,
    required this.relationship,
    required this.phoneNumber,
    this.isPrimary = false,
    this.category = ContactCategory.OTHER,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'relationship': relationship,
    'phoneNumber': phoneNumber,
    'isPrimary': isPrimary,
    'category': category.index,
  };

  factory EmergencyContact.fromJson(Map<String, dynamic> json) => EmergencyContact(
    name: json['name'],
    relationship: json['relationship'],
    phoneNumber: json['phoneNumber'],
    isPrimary: json['isPrimary'] ?? false,
    category: ContactCategory.values[json['category'] ?? 0],
  );
}

class EmergencyContactsScreen extends StatefulWidget {
  const EmergencyContactsScreen({super.key});

  @override
  _EmergencyContactsScreenState createState() => _EmergencyContactsScreenState();
}

class _EmergencyContactsScreenState extends State<EmergencyContactsScreen> {
  List<EmergencyContact> contacts = [];
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _relationshipController = TextEditingController();
  final _phoneController = TextEditingController();
  ContactCategory _selectedCategory = ContactCategory.OTHER;
  ContactCategory? _filterCategory;

  @override
  void initState() {
    super.initState();
    loadContacts();
  }

  Future<void> loadContacts() async {
    final prefs = await SharedPreferences.getInstance();
    final contactsJson = prefs.getStringList('emergency_contacts') ?? [];
    setState(() {
      contacts = contactsJson
          .map((contact) => EmergencyContact.fromJson(json.decode(contact)))
          .toList();
    });
  }

  Future<void> saveContacts() async {
    final prefs = await SharedPreferences.getInstance();
    final contactsJson = contacts
        .map((contact) => json.encode(contact.toJson()))
        .toList();
    await prefs.setStringList('emergency_contacts', contactsJson);
  }

  void _addContact() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          padding: EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Name',
                    prefixIcon: Icon(Icons.person),
                  ),
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Please enter a name' : null,
                ),
                SizedBox(height: 8),
                TextFormField(
                  controller: _relationshipController,
                  decoration: InputDecoration(
                    labelText: 'Relationship',
                    prefixIcon: Icon(Icons.people),
                  ),
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Please enter relationship' : null,
                ),
                SizedBox(height: 8),
                TextFormField(
                  controller: _phoneController,
                  decoration: InputDecoration(
                    labelText: 'Phone Number',
                    prefixIcon: Icon(Icons.phone),
                  ),
                  keyboardType: TextInputType.phone,
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Please enter phone number' : null,
                ),
                SizedBox(height: 16),
                DropdownButtonFormField<ContactCategory>(
                  value: _selectedCategory,
                  decoration: InputDecoration(
                    labelText: 'Category',
                    prefixIcon: Icon(_selectedCategory.icon),
                  ),
                  items: ContactCategory.values.map((category) {
                    return DropdownMenuItem(
                      value: category,
                      child: Row(
                        children: [
                          Icon(category.icon, size: 20, color: category.color),
                          SizedBox(width: 8),
                          Text(category.displayName),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedCategory = value ?? ContactCategory.OTHER;
                    });
                  },
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(double.infinity, 50),
                  ),
                  child: Text('Add Contact'),
                  onPressed: () {
                    if (_formKey.currentState?.validate() ?? false) {
                      setState(() {
                        contacts.add(EmergencyContact(
                          name: _nameController.text,
                          relationship: _relationshipController.text,
                          phoneNumber: _phoneController.text,
                          isPrimary: contacts.isEmpty,
                          category: _selectedCategory,
                        ));
                      });
                      saveContacts();
                      _nameController.clear();
                      _relationshipController.clear();
                      _phoneController.clear();
                      _selectedCategory = ContactCategory.OTHER;
                      Navigator.pop(context);
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri uri = Uri.parse('tel:$phoneNumber');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not launch phone call')),
        );
      }
    }
  }

  Widget _buildCategoryFilters() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          FilterChip(
            label: Text('All'),
            selected: _filterCategory == null,
            onSelected: (selected) {
              setState(() {
                _filterCategory = null;
              });
            },
          ),
          SizedBox(width: 8),
          ...ContactCategory.values.map((category) {
            return Padding(
              padding: EdgeInsets.only(right: 8),
              child: FilterChip(
                label: Text(category.displayName),
                selected: _filterCategory == category,
                avatar: Icon(category.icon, size: 16),
                onSelected: (selected) {
                  setState(() {
                    _filterCategory = selected ? category : null;
                  });
                },
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  List<EmergencyContact> get filteredContacts {
    if (_filterCategory == null) return contacts;
    return contacts.where((contact) => contact.category == _filterCategory).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Emergency Contacts'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: _addContact,
          ),
        ],
      ),
      body: Column(
        children: [
          _buildEmergencyServices(),
          _buildCategoryFilters(),
          Expanded(
            child: filteredContacts.isEmpty
                ? Center(
                    child: Text(
                      'No emergency contacts added yet.\nTap + to add contacts.',
                      textAlign: TextAlign.center,
                    ),
                  )
                : ListView.builder(
                    itemCount: filteredContacts.length,
                    itemBuilder: (context, index) {
                      final contact = filteredContacts[index];
                      return Dismissible(
                        key: Key(contact.phoneNumber),
                        background: Container(
                          color: Colors.red,
                          alignment: Alignment.centerRight,
                          padding: EdgeInsets.only(right: 16),
                          child: Icon(Icons.delete, color: Colors.white),
                        ),
                        direction: DismissDirection.endToStart,
                        confirmDismiss: (direction) async {
                          return await showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text('Confirm Deletion'),
                                content: Text('Are you sure you want to remove ${contact.name}?'),
                                actions: <Widget>[
                                  TextButton(
                                    onPressed: () => Navigator.of(context).pop(false),
                                    child: Text('CANCEL'),
                                  ),
                                  TextButton(
                                    onPressed: () => Navigator.of(context).pop(true),
                                    child: Text('DELETE', style: TextStyle(color: Colors.red)),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        onDismissed: (direction) {
                          setState(() {
                            contacts.remove(contact);
                          });
                          saveContacts();
                        },
                        child: Card(
                          margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: contact.category.color,
                              child: Icon(contact.category.icon, color: Colors.white),
                            ),
                            title: Text(
                              contact.name,
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(contact.relationship),
                                Text(
                                  contact.category.displayName,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: contact.category.color,
                                  ),
                                ),
                              ],
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (contact.isPrimary)
                                  Icon(Icons.star, color: Colors.amber, size: 20),
                                SizedBox(width: 8),
                                IconButton(
                                  icon: Icon(Icons.phone, color: Colors.green),
                                  onPressed: () => _makePhoneCall(contact.phoneNumber),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addContact,
        child: Icon(Icons.add),
        tooltip: 'Add Emergency Contact',
      ),
    );
  }

  Widget _buildEmergencyServices() {
    return Card(
      margin: EdgeInsets.all(8),
      child: Padding(
        padding: EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Emergency Services',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildEmergencyButton('Police', '100', Icons.local_police),
                _buildEmergencyButton('Ambulance', '101', Icons.medical_services),
                _buildEmergencyButton('Fire', '102', Icons.fire_truck),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmergencyButton(String label, String number, IconData icon) {
    return ElevatedButton.icon(
      icon: Icon(icon, size: 20),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      onPressed: () => _makePhoneCall(number),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _relationshipController.dispose();
    _phoneController.dispose();
    super.dispose();
  }
}