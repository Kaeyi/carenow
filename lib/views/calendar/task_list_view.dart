import 'package:care_now/views/general/add_general_view.dart';
import 'package:care_now/views/general/edit_general_view.dart';
import 'package:care_now/views/general/view_general_view.dart';
import 'package:care_now/views/meal/edit_meal_page.dart';
import 'package:care_now/views/meal/meal_planner_view.dart';
import 'package:care_now/views/meal/recipe_details_page.dart';
import 'package:care_now/views/medication/add_medication_page.dart';
import 'package:care_now/views/medication/edit_medication_page.dart';
import 'package:care_now/views/medication/view_medication_page.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class TaskListView extends StatefulWidget {
  final String elderlyId;

  const TaskListView({Key? key, required this.elderlyId}) : super(key: key);

  @override
  State<TaskListView> createState() => _TaskListViewState();
}

class _TaskListViewState extends State<TaskListView> {
  late DateTime _selectedDay;
  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now();
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    _initializeNotifications();
  }

  Future<void> _initializeNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
    );

    await _requestNotificationPermission(); // Request notification permission
  }

  Future<void> _requestNotificationPermission() async {
    // Check if permission is already granted
    var status = await Permission.notification.status;
    if (status.isGranted) {
      print('Notification permission already granted');
    } else {
      // If not granted, request permission
      status = await Permission.notification.request();
      if (status.isGranted) {
        print('Notification permission granted');
      } else {
        print('Notification permission denied');
        // Handle the scenario where permission is denied
      }
    }
  }

  // Stream to retrieve medication tasks
  Stream<QuerySnapshot<Map<String, dynamic>>> _getMedicationTasksStream(
      DateTime selectedDay) {
    return FirebaseFirestore.instance
        .collection('medications')
        .where('elderlyId', isEqualTo: widget.elderlyId)
        .where('selectedDateTime',
            isGreaterThanOrEqualTo: Timestamp.fromDate(selectedDay))
        .where('selectedDateTime',
            isLessThan: Timestamp.fromDate(selectedDay.add(
                const Duration(days: 1, hours: 23, minutes: 59, seconds: 59))))
        .snapshots();
  }

  // Stream to retrieve meals tasks
  Stream<QuerySnapshot> _getMealsTasksStream(DateTime selectedDay) {
    return FirebaseFirestore.instance
        .collection('meals')
        .where('elderlyId', isEqualTo: widget.elderlyId)
        .where('selectedDateTime',
            isGreaterThanOrEqualTo: Timestamp.fromDate(selectedDay))
        .where('selectedDateTime',
            isLessThan:
                Timestamp.fromDate(selectedDay.add(const Duration(days: 1))))
        .snapshots();
  }

  // Stream to retrieve general tasks
  Stream<QuerySnapshot> _getGeneralTasksStream(DateTime selectedDay) {
    return FirebaseFirestore.instance
        .collection('general')
        .where('elderlyId', isEqualTo: widget.elderlyId)
        .where('selectedDateTime',
            isGreaterThanOrEqualTo: Timestamp.fromDate(selectedDay))
        .where('selectedDateTime',
            isLessThan:
                Timestamp.fromDate(selectedDay.add(const Duration(days: 1))))
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Elderly Tasks'),
        ),
        body: SingleChildScrollView(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Weekly calendar
          TableCalendar(
            firstDay: DateTime.utc(2024, 1, 1),
            lastDay: DateTime.utc(2024, 12, 31),
            focusedDay: _selectedDay,
            calendarFormat: CalendarFormat.week,
            selectedDayPredicate: (day) {
              return isSameDay(_selectedDay, day);
            },
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
              });
            },
          ),
          const SizedBox(height: 5),
          // Stream builder for elderly details
          StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance
                .collection('elderlies')
                .doc(widget.elderlyId)
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const CircularProgressIndicator();
              } else {
                final elderlyData = snapshot.data!;
                return Container(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Name: ${elderlyData['name']}'),
                      Text('Age: ${elderlyData['age']}'),
                    ],
                  ),
                );
              }
            },
          ),
          const SizedBox(height: 5),
          //Stream builder for medication tasks
          StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: _getMedicationTasksStream(_selectedDay),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                // Show a circular progress indicator while waiting for data
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                // Handle error state
                return Center(child: Text('Error: ${snapshot.error}'));
              } else {
                final tasks = snapshot.data!.docs;
                return _buildMedicationTasks(tasks);
              }
            },
          ),

          const SizedBox(height: 16),

          // Stream builder for meals tasks
          StreamBuilder<QuerySnapshot>(
            stream: _getMealsTasksStream(_selectedDay),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                // Show a circular progress indicator while waiting for data
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                // Handle error state
                return Center(child: Text('Error: ${snapshot.error}'));
              } else {
                final tasks = snapshot.data!.docs;
                return _buildMealsTasks(tasks);
              }
            },
          ),

          const SizedBox(height: 16),

          // Stream builder for general tasks
          StreamBuilder<QuerySnapshot>(
            stream: _getGeneralTasksStream(_selectedDay),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                // Show a circular progress indicator while waiting for data
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                // Handle error state
                return Center(child: Text('Error: ${snapshot.error}'));
              } else {
                final tasks = snapshot.data!.docs;
                return _buildGeneralTasks(tasks);
              }
            },
          ),
        ])));
  }

  Widget _buildMedicationTasks(
      List<QueryDocumentSnapshot<Map<String, dynamic>>> tasks) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Medication',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AddMedicationPage(
                        elderlyId: widget.elderlyId,
                        selectedDay: _selectedDay,
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.add),
              ),
            ],
          ),
        ),
        SingleChildScrollView(
          child: tasks.isNotEmpty
              ? Column(
                  children: tasks.map((task) {
                    final taskTime =
                        (task['selectedDateTime'] as Timestamp).toDate();
                    final periodGapHours = task['gapTime'];
                    final quantity = task['quantity'];
                    final status = task['status'];
                    // final notificationTimes =
                    // _calculateNotificationTimes(taskTime, periodGapHours);

                    return GestureDetector(
                      onTap: () {
                        // Navigate to ViewMedicationPage
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ViewMedicationPage(
                              medicationId: task.id,
                            ),
                          ),
                        );
                      },
                      child: ListTile(
                        title: Text(task['title']),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Description: ${task['description']}'),
                            Text('Time: $taskTime'),
                            Text('Period Gap: $periodGapHours hours'),
                            Text('Pieces of Medicine: $quantity'),
                            Text('Status: $status')
                            // Text('Notification Times: ${notificationTimes.join(', ')}'),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => EditMedicationPage(
                                      medicationId: task.id,
                                    ),
                                  ),
                                );
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () {
                                _deleteTask(context, task.reference);
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                )
              : const Center(
                  child: Text('No medication tasks available.'),
                ),
        ),
      ],
    );
  }

  Widget _buildMealsTasks(List<DocumentSnapshot> tasks) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Meals',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              IconButton(
                onPressed: () {
                  // _showAddMealTaskDialog(context, 'Meals', _selectedDay);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MealPlannerView(
                        elderlyId: widget.elderlyId,
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.add),
              ),
            ],
          ),
        ),
        SingleChildScrollView(
          child: tasks.isNotEmpty
              ? Column(
                  children: tasks.map((task) {
                    // final taskTime = (task['time'] as Timestamp).toDate();

                    return GestureDetector(
                      onTap: () async {
                        // Fetch recipe data from Firestore using the task ID
                        final recipeSnapshot = await FirebaseFirestore.instance
                            .collection('meals')
                            .doc(task.id)
                            .get();
                        final recipeData = recipeSnapshot.data();
                        if (recipeData != null) {
                          // Navigate to RecipeDetailsPage and pass the recipe data
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => RecipeDetailsPage(
                                recipe: recipeData,
                                elderlyId: widget.elderlyId,
                              ),
                            ),
                          );
                        } else {
                          // Handle the case where recipe data is null
                          // Show an error message or take appropriate action
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text('Error'),
                                content:
                                    const Text('Failed to fetch recipe details.'),
                                actions: <Widget>[
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context)
                                          .pop(); // Close the dialog
                                    },
                                    child: const Text('OK'),
                                  ),
                                ],
                              );
                            },
                          );
                        }
                      },
                      child: ListTile(
                        title: Text(task['label']),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Meal: ${task['mealType']}'),
                            // Text('Time: ${_formatTime(taskTime)}'),
                            Text('Status: ${task['status']}'),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () {
                                // _showEditTaskDialog(context, task);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => EditMealView(
                                      mealId: task.id,
                                    ),
                                  ),
                                );
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () {
                                _deleteTask(context, task.reference);
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                )
              : const Center(
                  child: Text('No meal tasks available.'),
                ),
        ),
      ],
    );
  }

  Widget _buildGeneralTasks(List<DocumentSnapshot> tasks) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'General',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              IconButton(
                onPressed: () {
                  // _showAddGeneralTaskDialog(context, 'General', _selectedDay);
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AddGeneralTaskPage(
                        elderlyId: widget.elderlyId,
                        selectedDay: _selectedDay,
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.add),
              ),
            ],
          ),
        ),
        SingleChildScrollView(
          child: tasks.isNotEmpty
              ? Column(
                  children: tasks.map((task) {
                    // final taskTime = (task['time'] as Timestamp).toDate();

                    
                    return GestureDetector(
                      onTap: () {
                        // Navigate to ViewMedicationPage
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ViewGeneralTaskView(
                              generalTaskId: task.id,
                            ),
                          ),
                        );
                      },
                     child: ListTile(
                      title: Text(task['title']),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Description: ${task['description']}'),
                          Text('Status: ${task['status']}'),
                          // Text('Time: ${_formatTime(taskTime)}'),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () {
                              // _showEditTaskDialog(context, task);
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => EditGeneralTaskView(
                                      generalTaskId: task.id,
                                    ),
                                  ),
                                );
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () {
                              _deleteTask(context, task.reference);
                            },
                          ),
                        ],
                      ),
                    ),);
                  }).toList(),
                )
              : const Center(
                  child: Text('No meal tasks available.'),
                ),
        ),
      ],
    );
  }

  void _deleteTask(BuildContext context, DocumentReference taskRef) async {
    // Show confirmation dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Deletion'),
          content: const Text('Are you sure you want to delete this task?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop(); // Close the dialog
                // Perform deletion
                await flutterLocalNotificationsPlugin
                    .cancel(taskRef.id.hashCode);
                taskRef.delete();
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }
}
