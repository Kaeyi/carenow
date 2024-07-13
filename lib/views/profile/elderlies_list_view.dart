import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ElderlyListView extends StatefulWidget {
  const ElderlyListView({
    Key? key,
  }) : super(key: key);

  @override
  State<ElderlyListView> createState() => _ElderlyListViewState();
}

class _ElderlyListViewState extends State<ElderlyListView> {
  late User _user;

  @override
  void initState() {
    super.initState();
    _user =
        FirebaseAuth.instance.currentUser!; // Get the current logged-in user
  }

  Future<void> _addElderly() async {
    String elderlyEmail = ''; // Initialize elderlyEmail variable

    // Show dialog to get elderly email input
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add Elderly'),
          content: TextField(
            onChanged: (value) {
              elderlyEmail =
                  value; // Update elderlyEmail variable when text field changes
            },
            decoration: const InputDecoration(hintText: 'Enter Elderly Email'),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context)
                    .pop(); // Close dialog without adding elderly
              },
            ),
            TextButton(
              child: const Text('Add'),
              onPressed: () {
                Navigator.of(context)
                    .pop(); // Close dialog after adding elderly
                _addElderlyWithEmail(
                    elderlyEmail); // Call _addElderlyWithEmail with the entered email
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _addElderlyWithEmail(String email) async {
    // Check if the email exists in the users collection
    var userSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('email', isEqualTo: email)
        .get();

    if (userSnapshot.docs.isNotEmpty) {
      var userData = userSnapshot.docs.first.data();
      var userId = userSnapshot.docs.first.id; // Get the user ID
      var username = userData['username'];

      // Use the user ID as the document ID for the elderly in caregivers collection
      var elderlyId = userId;

      // Email exists, proceed to add elderly
      await FirebaseFirestore.instance
          .collection('caregivers')
          .doc(_user.uid)
          .collection('elderlies')
          .doc(elderlyId) // Use user ID as the document ID for the elderly
          .set({
        'name': username,
        'userId': userId
      }); // Store user ID along with elderly data
    } else {
      // Email does not exist
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Error'),
            content: const Text('The specified email does not exist.'),
            actions: <Widget>[
              TextButton(
                child: const Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
  }

  Future<void> _deleteElderly(String elderlyId) async {
    await FirebaseFirestore.instance
        .collection('caregivers')
        .doc(_user.uid)
        .collection('elderlies')
        .doc(elderlyId)
        .delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Elderly List'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('caregivers')
            .doc(_user.uid)
            .collection('elderlies')
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const CircularProgressIndicator();
          }
          // Data is available
          var elderlyDocs = snapshot.data!.docs;
          return ListView.builder(
            itemCount: elderlyDocs.length,
            itemBuilder: (context, index) {
              var elderly = elderlyDocs[index];
              // Assuming your elderly document has a field called 'name'
              var elderlyName = elderly['name'];
              return ListTile(
                  title: Text(elderlyName),
                  // You can add more details here if needed
                  trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () {
                        _deleteElderly(elderly.id);
                      }));
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _addElderly();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
