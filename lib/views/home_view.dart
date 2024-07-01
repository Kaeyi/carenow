// import 'package:care_now/constants/routes.dart';
// import 'package:care_now/enums/menu_action.dart';
// import 'package:care_now/services/auth/auth_service.dart';
// import 'package:care_now/utilities/dialogs/logout_dialog.dart';
// import 'package:care_now/views/calendar/schedule_task_notification.dart';
import 'package:care_now/views/calendar/schedule_view.dart';
import 'package:care_now/views/location/location_view.dart';
// import 'package:care_now/views/meal/meal_planner_view.dart';
import 'package:care_now/views/profile/profile_view.dart';
import 'package:flutter/material.dart';

class HomeView extends StatefulWidget {

  const HomeView({super.key, });

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  int currentIndex = 0;

  final List<Widget> _children = [
    const ScheduleView(),
    const LocationView(),
    const ProfileView(),
  ];

  void onTabTapped(int index) {
    setState(() {
      currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _children.elementAt(currentIndex), //New
      ),
      bottomNavigationBar: BottomNavigationBar(
        onTap: onTabTapped,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.location_on),
            label: 'Location',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: currentIndex,
        unselectedItemColor: Colors.grey,
        unselectedLabelStyle: const TextStyle(color: Colors.black),
        showUnselectedLabels: true,
        selectedItemColor: Colors.deepPurple,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }
}
