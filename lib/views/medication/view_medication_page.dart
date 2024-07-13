import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ViewMedicationPage extends StatelessWidget {
  final String medicationId;

  const ViewMedicationPage({
    Key? key,
    required this.medicationId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text('View Medication'),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection('medications')
            .doc(medicationId)
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

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(
              child: Text('Medication not found.'),
            );
          }

          final medicationData = snapshot.data!.data() as Map<String, dynamic>;
          final selectedDateTime =
              (medicationData['selectedDateTime'] as Timestamp).toDate();
          final formattedDateTime =
              DateFormat('yyyy-MM-dd HH:mm').format(selectedDateTime);
          final photoUrl = medicationData['imageUrl'];

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Title: ${medicationData['title']}',
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text('Description: ${medicationData['description']}'),
                const SizedBox(height: 8),
                Text('Gap Time: ${medicationData['gapTime']}'),
                const SizedBox(height: 8),
                Text('Quantity: ${medicationData['quantity']}'),
                const SizedBox(height: 8),
                Text('Selected Date Time: $formattedDateTime'),
                const SizedBox(height: 8),
                if (photoUrl != null)
                  CachedNetworkImage(
                    imageUrl: photoUrl,
                    placeholder: (context, url) => const CircularProgressIndicator(),
                    errorWidget: (context, url, error) {
                      print('Error loading image: $error');
                      return const Icon(Icons.error);
                    },
                  ),
                // You can display more details here if needed
                // For example, image, notification times, etc.
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => _markAsDone(context, medicationId),
                  child: const Text('Mark as Done'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
  Future<void> _markAsDone(BuildContext context, String medicationId) async {
    try {
      await FirebaseFirestore.instance
          .collection('medications')
          .doc(medicationId)
          .update({'status': 'completed'});
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Medication marked as done'),
        ),
      );
    } catch (error) {
      print('Error marking medication as done: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error marking medication as done'),
        ),
      );
    }
  }
}

