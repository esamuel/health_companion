import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DietNutritionScreen extends StatefulWidget {
  const DietNutritionScreen({super.key});

  @override
  _DietNutritionScreenState createState() => _DietNutritionScreenState();
}

class _DietNutritionScreenState extends State<DietNutritionScreen> {
  List<Map<String, dynamic>> meals = [];
  TextEditingController mealController = TextEditingController();
  TextEditingController caloriesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadMeals();
  }

  void _loadMeals() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      meals = (prefs.getStringList('meals') ?? [])
          .map((item) => Map<String, dynamic>.from(
              Map<String, dynamic>.from(item as Map)))
          .toList();
    });
  }

  void _saveMeals() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('meals',
        meals.map((item) => item.toString()).toList());
  }

  void _addMeal() {
    if (mealController.text.isNotEmpty && caloriesController.text.isNotEmpty) {
      setState(() {
        meals.add({
          'name': mealController.text,
          'calories': int.parse(caloriesController.text),
          'date': DateTime.now().toString(),
        });
        _saveMeals();
        mealController.clear();
        caloriesController.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Diet & Nutrition Tracker')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: meals.length,
              itemBuilder: (context, index) {
                final meal = meals[index];
                return ListTile(
                  title: Text(meal['name']),
                  subtitle: Text('${meal['calories']} calories'),
                  trailing: Text(meal['date'].split(' ')[0]),  // Show only the date
                );
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: mealController,
                    decoration: InputDecoration(labelText: 'Meal'),
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: caloriesController,
                    decoration: InputDecoration(labelText: 'Calories'),
                    keyboardType: TextInputType.number,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.add),
                  onPressed: _addMeal,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}