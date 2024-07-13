
import 'package:care_now/views/calendar/schedule_task_notification.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';


class AddGeneralTaskPage extends StatefulWidget {
  final String elderlyId;
  final DateTime selectedDay;

  const AddGeneralTaskPage({
    Key? key,
    required this.elderlyId,
    required this.selectedDay,
  }) : super(key: key);

  @override
  State<AddGeneralTaskPage> createState() => _AddGeneralTaskPageState();}
  class _AddGeneralTaskPageState extends State<AddGeneralTaskPage>{
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  DateTime? selectedDateTime;


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add General Task'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Title'),
              ),
              TextFormField(
                controller: descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
              ),
              DatePickerTxt(
                onDateTimeSelected: (dateTime) {
                  setState(() {
                    selectedDateTime =
                        dateTime; // Update the selectedDateTime in the parent widget
                  });
                },
              ),
              
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  // Implement logic to save general task details
                  await _saveGeneralTask(
                    elderlyId: widget.elderlyId,
                    title: titleController.text,
                    description: descriptionController.text,
                    selectedDateTime: selectedDateTime ?? DateTime.now(),
                  );
                  Navigator.pop(context);
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('Task Saved'),
                        content:
                            const Text('The general task has been saved.'),
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
                child: const Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Future<void> _saveGeneralTask({
    required String elderlyId,
    required String title,
    required String description,
    required DateTime selectedDateTime,
    String status = 'pending',
  }) async {
    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;

      // Create a map containing the general task details
      Map<String, dynamic> generalTaskData = {
        'elderlyId': elderlyId,
        'title': title,
        'description': description,
        'selectedDateTime': selectedDateTime,
        // Add more fields to the generalTaskData map for other details
        'status': status,
      };

      // Add the general task data to Firestore
      await firestore.collection('general').add(generalTaskData);

      // Print a success message
      print('General task saved successfully!');
    } catch (error) {
      // Print any errors that occur
      print('Error saving general task: $error');
    }
  }
}



