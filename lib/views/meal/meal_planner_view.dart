// ignore_for_file: avoid_print

import 'package:care_now/views/meal/recipe_details_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MealPlannerView extends StatefulWidget {
  final String elderlyId;
  const MealPlannerView({Key? key, required this.elderlyId, }) : super(key: key);

  @override
  State<MealPlannerView> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MealPlannerView> {
  final TextEditingController _ingredientController = TextEditingController();
  List<Map<String, dynamic>> recipes = [];
  bool isLoading = false; // Added loading indicator state

  // Selected filter values
  String selectedCaloriesFilter = 'Any';
  String selectedMealTypesFilter = 'Any';
  String selectedCuisineTypeFilter = 'Any';
  String selectedDietLabelsFilter = 'Any';
  String selectedHealthLabelsFilter = 'Any';

  // List of filter options
  List<String> caloriesOptions = ['Any', '0-50', '50-100', '100-200', '200+'];
  List<String> mealTypesOptions = [
    'Any',
    'Breakfast',
    'Lunch',
    'Dinner',
    'Snack',
    'Teatime'
  ];
  List<String> cuisineTypeOptions = [
    'Any',
    'American',
    'Italian',
    'Asian',
    'Mexican',
    'Indian',
    'French'
  ];
  List<String> dietLabelsOptions = [
    'Any',
    'Vegetarian',
    'Vegan',
    'Gluten-Free',
    'Ketogenic'
  ];
  List<String> healthLabelsOptions = [
    'Any',
    'Sugar-Conscious',
    'Low-Sodium',
    'Dairy-Free',
    'Egg-Free'
  ];

  Future<void> _searchRecipes(String ingredient) async {
    const appId = 'b58acc3d';
    const appKey = 'e9dc59f4ce60c6ab3c70bbe525079345';
    const endpoint = 'https://api.edamam.com/api/recipes/v2';

    print("fetching data");
    try {
      setState(() {
        isLoading = true; // show loading indicator
      });
      final response = await http.get(Uri.parse(
          // ignore: prefer_adjacent_string_concatenation
          '$endpoint?type=public&q=$ingredient&app_id=$appId&app_key=$appKey' +
              '&calories=${Uri.encodeComponent(selectedCaloriesFilter)}')); // Include calories filter in query URL
      print("data fetched");
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['hits'] != null) {
          final hits = data['hits'];
          final recipeData = hits.map<Map<String, dynamic>>((hit) {
            final recipe = hit['recipe'];
            return {
              'label': recipe['label'],
              'image': recipe['image'],
              'url': recipe['url'],
              'ingredients': recipe['ingredientLines'],
              'calories': recipe['calories'],
              'mealTypes': recipe['mealType'],
              'cuisineType': recipe['cuisineType'],
              'diet': recipe['dietLabels'],
              'allergies': recipe['healthLabels'],
            };
          }).toList();

          setState(() {
            recipes = recipeData;
          });
        }
      } else {
        print('Failed to fetch recipes: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    } catch (e) {
      print('error occurred: $e');
    } finally {
      setState(() {
        isLoading = false; // hide loading indicator
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Meal Planner'),
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextField(
                      controller: _ingredientController,
                      decoration: const InputDecoration(
                        hintText: 'Enter your ingredient',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text('Calories:'),
                    DropdownButton<String>(
                      value: selectedCaloriesFilter,
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedCaloriesFilter = newValue ?? 'Any';
                        });
                      },
                      items: caloriesOptions.map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 10),
                    const Text('Meal Types:'),
                    DropdownButton<String>(
                      value: selectedMealTypesFilter,
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedMealTypesFilter = newValue ?? 'Any';
                        });
                      },
                      items: mealTypesOptions.map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 10),
                    const Text('Cuisine Type:'),
                    DropdownButton<String>(
                      value: selectedCuisineTypeFilter,
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedCuisineTypeFilter = newValue ?? 'Any';
                        });
                      },
                      items: cuisineTypeOptions.map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 10),
                    const Text('Diet Labels:'),
                    DropdownButton<String>(
                      value: selectedDietLabelsFilter,
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedDietLabelsFilter = newValue ?? 'Any';
                        });
                      },
                      items: dietLabelsOptions.map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 10),
                    const Text('Health Labels:'),
                    DropdownButton<String>(
                      value: selectedHealthLabelsFilter,
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedHealthLabelsFilter = newValue ?? 'Any';
                        });
                      },
                      items: healthLabelsOptions.map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () {
                        print("Button clicked");
                        _searchRecipes(_ingredientController.text);
                      },
                      child: const Text("Search for Recipes"),
                    ),
                  ],
                ),
              ),
              SingleChildScrollView(
                child: isLoading
                    ? const Center(
                        child:
                            CircularProgressIndicator(), // Show loading indicator while fetching data
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: recipes.length,
                            itemBuilder: (context, index) {
                              final recipe = recipes[index];
                              return ListTile(
                                title: Text(recipe['label']),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Image.network(recipe['image']),
                                    Text(recipe['ingredients'].join('\n')),
                                  ],
                                ),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          RecipeDetailsPage(recipe: recipe, elderlyId: widget.elderlyId,),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                        ],
                      ),
              ),
            ],
          ),
        ));
  }
}
