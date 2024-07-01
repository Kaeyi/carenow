// ignore_for_file: avoid_print

import 'dart:io';
import 'dart:typed_data';
import 'package:care_now/services/notifi_service.dart';
import 'package:care_now/views/calendar/schedule_task_notification.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

class AddMedicationPage extends StatefulWidget {
  final String elderlyId;
  final DateTime selectedDay;

  const AddMedicationPage({
    Key? key,
    required this.elderlyId,
    required this.selectedDay,
  }) : super(key: key);

  @override
  State<AddMedicationPage> createState() => _AddMedicationPageState();
}

class _AddMedicationPageState extends State<AddMedicationPage> {
  // Define variables and controllers as needed for medication details
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController gapTimeController = TextEditingController();
  TextEditingController quantityController = TextEditingController();
  // Add more controllers for other fields if needed
  DateTime? selectedDateTime;
  XFile? _imageFile;

  Future<void> _getImageFromGallery() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    setState(() {
      _imageFile = image;
    });
  }

  Future<void> _takePhoto() async {
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
        title: const Text('Add Medication'),
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
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
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
              if (_imageFile != null) ...[
                Image.file(File(_imageFile!.path)),
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
                  double? quantity = double.tryParse(quantityController.text);
                  // Implement logic to save medication details
                  await _saveMedication(
                    elderlyId: widget.elderlyId,
                    title: titleController.text,
                    description: descriptionController.text,
                    gapTime: gapTime,
                    quantity: quantity,
                    selectedDateTime: selectedDateTime ?? DateTime.now(),
                    imageFile: _imageFile,
                  );
                  Navigator.pop(context);
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('Task Saved'),
                        content:
                            const Text('The medication task has been saved.'),
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

  static Future<void> _saveMedication({
    required String elderlyId,
    required String title,
    required String description,
    double? gapTime,
    double? quantity,
    required DateTime? selectedDateTime,
    XFile? imageFile,
    String status = 'pending', // Default status is 'pending'
  }) async {
    try {
      // Use selectedDateTime if it's not null, otherwise use the defaultDateTime
      final DateTime defaultDateTime = DateTime.now();
      final DateTime effectiveDateTime = selectedDateTime ?? defaultDateTime;
      // Get a reference to the Firestore database
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      Uint8List? imageData;
      if (imageFile != null) {
        imageData = await imageFile.readAsBytes();
      }
      // Upload image to Firebase Storage
      String? imageUrl;
      if (imageData != null) {
        String fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
        Reference storageReference =
            FirebaseStorage.instance.ref().child('images').child(fileName);
        UploadTask uploadTask = storageReference.putData(imageData, SettableMetadata(contentType: 'image/jpeg'));
        try {
          TaskSnapshot snapshot = await uploadTask;
          imageUrl = await snapshot.ref.getDownloadURL();
        } catch (error) {
          print(error);
        }
      }
      // Create a map containing the medication details
      Map<String, dynamic> medicationData = {
        'elderlyId': elderlyId,
        'title': title,
        'description': description,
        'gapTime': gapTime,
        'quantity': quantity,
        'selectedDateTime': effectiveDateTime,
        'imageUrl': imageUrl,
        'status': status,
        // Add more fields to the medicationData map for other details
      };

      // Add the medication data to Firestore
      DocumentReference documentReference =
          await firestore.collection('medications').add(medicationData);

      // Schedule notification if the medication data is successfully saved
      if (documentReference.id.isNotEmpty) {
        NotificationService().scheduleNotification(
          title: 'Scheduled Medication',
          body: 'Remember to take medication: $title',
          scheduledNotificationDateTime: effectiveDateTime,
        );
      }

      // Print a success message
      print('Medication saved successfully!');
    } catch (error) {
      // Print any errors that occur
      print('Error saving medication: $error');
    }
  }
}
