// ignore_for_file: avoid_print

import 'dart:typed_data';
import 'package:care_now/views/calendar/schedule_task_notification.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

class EditMedicationPage extends StatefulWidget {
  final String medicationId; // Pass the medication ID to identify which medication to edit

  const EditMedicationPage({
    Key? key,
    required this.medicationId,
  }) : super(key: key);

  @override
  State<EditMedicationPage> createState() => _EditMedicationPageState();
}

class _EditMedicationPageState extends State<EditMedicationPage> {
  // Define variables and controllers as needed for medication details
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController gapTimeController = TextEditingController();
  TextEditingController quantityController = TextEditingController();
  // Add more controllers for other fields if needed
  DateTime? selectedDateTime;
  XFile? _imageFile;
  String? imageUrl;

  @override
  void initState() {
    super.initState();
    // Fetch existing medication data using widget.medicationId
  FirebaseFirestore.instance.collection('medications').doc(widget.medicationId).get().then((DocumentSnapshot documentSnapshot) {
    if (documentSnapshot.exists) {
      Map<String, dynamic> medicationData = documentSnapshot.data() as Map<String, dynamic>;
      setState(() {
        // Populate the form fields with the fetched medication data
        titleController.text = medicationData['title'];
        descriptionController.text = medicationData['description'];
        gapTimeController.text = medicationData['gapTime'].toString();
        quantityController.text = medicationData['quantity'].toString();
        selectedDateTime = medicationData['selectedDateTime'].toDate();
        imageUrl = medicationData['imageUrl'];
      });
    } else {
      // Handle the case where the medication document does not exist
      print('Document does not exist');
    }
  }).catchError((error) {
    // Handle errors that occur during data fetching
    print('Error fetching medication data: $error');
  });
  }

  Future<void> _getImageFromGallery() async {
    // Implement image picking functionality similar to AddMedicationPage
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    setState(() {
      _imageFile = image;
    });
  }

  Future<void> _takePhoto() async {
    // Implement image taking functionality similar to AddMedicationPage
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.camera);

    setState(() {
      _imageFile = image;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Medication'),
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
              TextFormField(
                controller: gapTimeController,
                decoration:
                    const InputDecoration(labelText: 'Gap Time of reminder'),
              ),
              TextFormField(
                controller: quantityController,
                decoration: const InputDecoration(
                    labelText: 'Quantity pieces of intake'),
              ),
              DatePickerTxt(
                onDateTimeSelected: (dateTime) {
                  setState(() {
                    selectedDateTime =
                        dateTime; // Update the selectedDateTime in the parent widget
                  });
                },
              ),
              if (imageUrl != null) ...[
                Image.network(imageUrl!), // Display existing image if available
                const SizedBox(height: 20),
              ],
              Row(
                children: [
                  ElevatedButton(
                    onPressed: _getImageFromGallery,
                    child: const Text('Select Photo'),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: _takePhoto,
                    child: const Text('Take Photo'),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // Add more form fields for other medication details
              // For example: time, period gap, quantity, etc.
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  double? gapTime = double.tryParse(gapTimeController.text);
                  // Implement logic to update medication details
                  await _updateMedication(
                    medicationId: widget.medicationId,
                    title: titleController.text,
                    description: descriptionController.text,
                    gapTime: gapTime,
                    quantity: quantityController.hashCode,
                    selectedDateTime: selectedDateTime ?? DateTime.now(),
                    imageFile: _imageFile,
                  );
                  Navigator.pop(context);
                  // Show a confirmation dialog or navigate back
                },
                child: const Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Future<void> _updateMedication({
    required String medicationId,
    required String title,
    required String description,
    double? gapTime,
    int? quantity,
    required DateTime selectedDateTime,
    XFile? imageFile,
  }) async {
    try {
      // Fetch the document reference of the medication using medicationId
      DocumentReference medicationRef =
          FirebaseFirestore.instance.collection('medications').doc(medicationId);

      Uint8List? imageData;
      if (imageFile != null) {
        imageData = await imageFile.readAsBytes();
      }
      // Upload image to Firebase Storage
      String? imageUrl;
      if (imageData != null) {
        String fileName = DateTime.now().millisecondsSinceEpoch.toString();
        Reference storageReference =
            FirebaseStorage.instance.ref().child('images').child(fileName);
        UploadTask uploadTask = storageReference.putData(imageData);
        try{
          TaskSnapshot snapshot = await uploadTask;
        imageUrl = await snapshot.ref.getDownloadURL();}catch (error) {
          print(error);
        }
      }

      // Create a map containing the updated medication details
      Map<String, dynamic> updatedMedicationData = {
        'title': title,
        'description': description,
        'gapTime': gapTime,
        'quantity': quantity,
        'selectedDateTime': selectedDateTime,
        'imageUrl':imageUrl,
        // Add more fields to the updatedMedicationData map for other details
      };

      // Update the medication data in Firestore
      await medicationRef.update(updatedMedicationData);

      // Print a success message
      print('Medication updated successfully!');
    } catch (error) {
      // Print any errors that occur
      print('Error updating medication: $error');
    }
  }
}
