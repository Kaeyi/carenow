import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ViewGeneralTaskView extends StatelessWidget {
  final String generalTaskId;

  const ViewGeneralTaskView({Key? key, required this.generalTaskId})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('View General Task'),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection('general')
            .doc(generalTaskId)
            .get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }
          if (!snapshot.hasData || snapshot.data!.data() == null) {
            return const Center(
              child: Text('No data found.'),
            );
          }
          Map<String, dynamic> taskData =
              snapshot.data!.data() as Map<String, dynamic>;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Title: ${taskData['title']}',
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Text(
                  'Description: ${taskData['description']}',
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 10),
                Text(
                  'Scheduled DateTime: ${taskData['selectedDateTime'].toString()}',
                  style: const TextStyle(fontSize: 16),
                ),
                // Add more fields here if needed
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    _markAsDone(context, generalTaskId);
                  },
                  child: const Text('Mark as Done'),
                ),
                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }

  void _markAsDone(BuildContext context, String generalTaskId) {
    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;

      // Update the task status to "completed" in Firestore
      firestore.collection('general').doc(generalTaskId).update({
        'status': 'completed',
      });

      // Show a success message or navigate to previous screen
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Task marked as done successfully.'),
        ),
      );
    } catch (error) {
      print('Error marking task as done: $error');
      // Show an error message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error marking task as done.'),
        ),
      );
    }
  }
}
