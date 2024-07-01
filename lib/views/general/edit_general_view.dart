import 'package:care_now/views/calendar/schedule_task_notification.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class EditGeneralTaskView extends StatefulWidget {
  final String generalTaskId;

  const EditGeneralTaskView({Key? key, required this.generalTaskId,}) : super(key: key);

  @override
  State<EditGeneralTaskView> createState() => _EditGeneralTaskViewState();
}

class _EditGeneralTaskViewState extends State<EditGeneralTaskView> {
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  DateTime? selectedDateTime;

  @override
  void initState() {
    super.initState();
    fetchGeneralTaskDetails();
  }

  Future<void> fetchGeneralTaskDetails() async {
    try {
      DocumentSnapshot generalTaskSnapshot = await FirebaseFirestore.instance.collection('general').doc(widget.generalTaskId).get();
      Map<String, dynamic> taskData = generalTaskSnapshot.data() as Map<String, dynamic>;

      setState(() {
        titleController.text = taskData['title'];
        descriptionController.text = taskData['description'];
        selectedDateTime = (taskData['selectedDateTime'] as Timestamp).toDate();
      });
    } catch (error) {
      print('Error fetching general task details: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit General Task'),
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
                    selectedDateTime = dateTime;
                  });
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  await _updateGeneralTask(
                    generalTaskId: widget.generalTaskId,
                    title: titleController.text,
                    description: descriptionController.text,
                    selectedDateTime: selectedDateTime ?? DateTime.now(),
                  );
                  Navigator.pop(context);
                  // Show success message or navigate to previous screen
                },
                child: const Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Future<void> _updateGeneralTask({
    required String generalTaskId,
    required String title,
    required String description,
    required DateTime selectedDateTime,
  }) async {
    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;

      // Create a map containing the updated general task details
      Map<String, dynamic> updatedGeneralTaskData = {
        'title': title,
        'description': description,
        'selectedDateTime': selectedDateTime,
        // Add more fields to update if needed
      };

      // Update the general task data in Firestore
      await firestore.collection('general').doc(generalTaskId).update(updatedGeneralTaskData);

      print('General task updated successfully!');
    } catch (error) {
      print('Error updating general task: $error');
    }
  }
}

