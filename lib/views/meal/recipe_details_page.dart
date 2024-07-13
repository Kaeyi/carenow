import 'package:care_now/views/calendar/schedule_task_notification.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

enum MealType { breakfast, lunch, dinner, snacks, teatime, other }

void saveRecipeToFirebase(
  String elderlyId,
  Map<String, dynamic> recipe,
  MealType mealType,
  DateTime? selectedDateTime,
) async {
  try {
    final DateTime defaultDateTime = DateTime.now();
    final DateTime effectiveDateTime = selectedDateTime ?? defaultDateTime;
    String status = 'pending';
    // Connect to Firebase
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    // Reference to the "meals" collection
    CollectionReference mealsCollection = firestore.collection('meals');

    // Add the recipe data to the collection
    await mealsCollection.add({
      'elderlyId': elderlyId,
      'label': recipe['label'],
      'image': recipe['image'],
      'ingredients': recipe['ingredients'],
      'url': recipe['url'],
      'mealType': enumToString(mealType), // Convert enum to string
      'selectedDateTime': effectiveDateTime, // Add a timestamp
      'status': status,
    });

    print('Recipe saved to Firebase successfully!');
  } catch (error) {
    print('Error saving recipe to Firebase: $error');
  }
}

String enumToString(MealType mealType) {
  switch (mealType) {
    case MealType.breakfast:
      return 'breakfast';
    case MealType.lunch:
      return 'lunch';
    case MealType.dinner:
      return 'dinner';
    case MealType.snacks:
      return 'snacks';
    case MealType.teatime:
      return 'teatime';
    case MealType.other:
      return 'other';
    default:
      throw ArgumentError('Invalid meal type');
  }
}

class RecipeDetailsPage extends StatefulWidget {
  final String elderlyId;
  final Map<String, dynamic> recipe;

  const RecipeDetailsPage({
    Key? key,
    required this.recipe,
    required this.elderlyId,
  }) : super(key: key);

  @override
  State<RecipeDetailsPage> createState() => _RecipeDetailsPageState();
}

class _RecipeDetailsPageState extends State<RecipeDetailsPage> {
  MealType _selectedMealType = MealType.lunch; // Default meal type
  DateTime? selectedDateTime;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.recipe['label']),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.network(widget.recipe['image']),
              const SizedBox(height: 20),
              const Text(
                'Ingredients:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: List.generate(
                  widget.recipe['ingredients'].length,
                  (index) => Text(widget.recipe['ingredients'][index]),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  // Add functionality to open recipe URL
                  _launchURL(widget.recipe['url']);
                },
                child: const Text('View Recipe'),
              ),
              const SizedBox(height: 20),
              DropdownButton<MealType>(
                value: _selectedMealType,
                onChanged: (MealType? newValue) {
                  setState(() {
                    _selectedMealType = newValue!;
                  });
                },
                items: MealType.values.map((MealType mealType) {
                  return DropdownMenuItem<MealType>(
                    value: mealType,
                    child: Text(mealType.toString().split('.').last),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
              DatePickerTxt(
                onDateTimeSelected: (dateTime) {
                  setState(() {
                    selectedDateTime =
                        dateTime; // Update the selectedDateTime in the parent widget
                  });
                },
              ),
              ElevatedButton(
                onPressed: () {
                  // Add functionality to save recipe to Firebase
                  saveRecipeToFirebase(
                    widget.elderlyId,
                    widget.recipe,
                    _selectedMealType,
                    selectedDateTime,
                  );
                  Navigator.pop(context);
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('Task Saved'),
                        content: const Text('The meal has been saved.'),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context); // Close the dialog
                            },
                            child: const Text('OK'),
                          ),
                        ],
                      );
                    },
                  );
                },
                child: const Text('Save Recipe'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  // Add functionality to update status of meal task as completed
                  _markMealTaskAsDone(widget.recipe['elderlyId']);
                  Navigator.pop(context);
                  // Show success message or navigate to previous screen
                },
                child: const Text('Mark as Done'),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  void _markMealTaskAsDone(String elderlyId) async {
    try {
      // Connect to Firestore
      FirebaseFirestore firestore = FirebaseFirestore.instance;

      // Reference to the "meals" collection
      CollectionReference mealsCollection = firestore.collection('meals');

      // Query for the specific meal task based on elderlyId and other criteria if needed
      QuerySnapshot querySnapshot = await mealsCollection
          .where('elderlyId', isEqualTo: elderlyId)
          // Add more criteria if needed
          .get();

      // Loop through the query results and update the status of each meal task
      querySnapshot.docs.forEach((doc) async {
        // Update the status to 'completed'
        await doc.reference.update({'status': 'completed'});
      });

      print('Meal task marked as done successfully!');
    } catch (error) {
      print('Error marking meal task as done: $error');
    }
  }

  void _launchURL(String url) async {
    // Convert the string URL to a Uri object
    final uri = Uri.parse(url);

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      throw 'Could not launch $url';
    }
  }
}
