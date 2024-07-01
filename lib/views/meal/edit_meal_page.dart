import 'package:care_now/views/calendar/schedule_task_notification.dart';
import 'package:care_now/views/meal/recipe_details_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class EditMealView extends StatefulWidget {
  final String mealId; // Unique identifier for the meal

  const EditMealView({
    Key? key,
    required this.mealId,
  }) : super(key: key);

  @override
  State<EditMealView> createState() => _EditMealViewState();
}

class _EditMealViewState extends State<EditMealView> {
  final TextEditingController _labelController = TextEditingController();
  final TextEditingController _imageController = TextEditingController();
  final TextEditingController _ingredientsController = TextEditingController();
  MealType _selectedMealType = MealType.lunch;
  DateTime? selectedDateTime;

  @override
  void initState() {
    super.initState();
    FirebaseFirestore.instance.collection('meals').doc(widget.mealId).get().then((DocumentSnapshot documentSnapshot) {
    if (documentSnapshot.exists) {
      Map<String, dynamic> mealData = documentSnapshot.data() as Map<String, dynamic>;
      setState(() {
    // Initialize controllers with existing meal data
    _labelController.text = mealData['label'];
    _imageController.text = mealData['image'];
    _ingredientsController.text = mealData['ingredients'].join(', ');
    // Parse meal type from string to enum
    _selectedMealType = enumFromString(mealData['mealType']);
    // Parse selectedDateTime if it exists
    selectedDateTime = mealData['selectedDateTime']?.toDate();
  });} else {
    print('Document does not exist');
  }
  }).catchError((error) {
    // Handle errors that occur during data fetching
    print('Error fetching meal data: $error');
  });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Meal'),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                controller: _labelController,
                decoration: const InputDecoration(labelText: 'Label'),
              ),
              TextFormField(
                controller: _imageController,
                decoration: const InputDecoration(labelText: 'Image'),
              ),
              TextFormField(
                controller: _ingredientsController,
                decoration: const InputDecoration(labelText: 'Ingredients'),
              ),
              DropdownButton<MealType>(
                value: _selectedMealType,
                onChanged: (MealType? newValue) {
                  setState(() {
                    _selectedMealType = newValue!;
                  });
                },
                items: MealType.values.map((MealType mealType) {
                  return DropdownMenuItem
(
                    value: mealType,
                    child: Text(mealType.toString().split('.').last),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
              DatePickerTxt(
                onDateTimeSelected: (dateTime) {
                  setState(() {
                    selectedDateTime = dateTime;
                  });
                },
              ),
              ElevatedButton(
                onPressed: () {
                  // Add functionality to update meal in Firebase
                  updateMealInFirebase();
                  Navigator.pop(context);
                },
                child: const Text('Save Changes'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void updateMealInFirebase() async {
    try {
      // Connect to Firebase
      FirebaseFirestore firestore = FirebaseFirestore.instance;

      // Reference to the specific meal document
      DocumentReference mealRef =
          firestore.collection('meals').doc(widget.mealId);

      // Update the meal data in Firebase
      await mealRef.update({
        'label': _labelController.text.trim(),
        'image': _imageController.text.trim(),
        'ingredients': _ingredientsController.text.split(',').map((ingredient) => ingredient.trim()).toList(),
        'mealType': enumToString(_selectedMealType),
        'selectedDateTime': selectedDateTime,
      });

      print('Meal updated successfully!');
    } catch (error) {
      print('Error updating meal: $error');
    }
  }

  MealType enumFromString(String mealTypeString) {
    switch (mealTypeString) {
      case 'breakfast':
        return MealType.breakfast;
      case 'lunch':
        return MealType.lunch;
      case 'dinner':
        return MealType.dinner;
      case 'snacks':
        return MealType.snacks;
      case 'teatime':
        return MealType.teatime;
      case 'other':
        return MealType.other;
      default:
        throw ArgumentError('Invalid meal type string');
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
}