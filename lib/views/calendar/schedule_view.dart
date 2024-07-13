import 'package:care_now/views/calendar/task_list_view.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:table_calendar/table_calendar.dart';

class ScheduleView extends StatefulWidget {
  const ScheduleView({Key? key}) : super(key: key);

  @override
  State<ScheduleView> createState() => _ScheduleViewState();
}

class _ScheduleViewState extends State<ScheduleView> {
  late User _user; // Variable to hold the logged-in user

  @override
  void initState() {
    super.initState();
    _user = FirebaseAuth.instance.currentUser!; // Get the current logged-in user
  }

  CalendarFormat _calendarFormat = CalendarFormat.week;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Weekly Calendar'),
      ),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime.utc(2024, 1, 1),
            lastDay: DateTime.utc(2024, 12, 31),
            focusedDay: _focusedDay,
            calendarFormat: _calendarFormat,
            onFormatChanged: (format) {
              setState(() {
                _calendarFormat = format;
              });
            },
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            headerStyle: const HeaderStyle(
              formatButtonVisible: false,
            ),
          ),
          const SizedBox(height: 10), // Add some spacing
          const Text(
            'Incharge', // Title text
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('caregivers')
                  .doc(_user.uid)
                  .collection('elderlies')
                  .snapshots(),
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
                final data = snapshot.requireData;
                final elderlies = data.docs;

                return ListView.builder(
                  itemCount: elderlies.length,
                  itemBuilder: (context, index) {
                    final elderly = elderlies[index];
                    return GestureDetector(
                      onTap: () {
                        // Navigate to another view here
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => TaskListView(elderlyId: elderly.id)),
                        );
                      },
                      child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.0), // Adjust the radius as needed
                        ),
                        elevation: 4, // Add elevation for a shadow effect
                        margin: const EdgeInsets.all(10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                              child: Text(
                                elderly['name'], // Assuming 'name' is a field in your elderly documents
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            // Place your elderly-specific widgets here
                            // For example, you can display their schedules
                            // for the selected day.
                            Row(
                              children: [
                                Expanded(
                                  child: ListTile(
                                    title: Text('Schedule for ${_selectedDay ?? DateTime.now()}'),
                                    subtitle: const Text('Schedule details here...'),
                                  ),
                                ),
                                const Icon(Icons.arrow_forward_ios), // Add direction symbol
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}


