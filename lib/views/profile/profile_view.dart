// import 'package:care_now/enums/menu_action.dart';
// import 'package:care_now/services/auth/bloc/auth_bloc.dart';
// import 'package:care_now/services/auth/bloc/auth_event.dart';
// import 'package:care_now/utilities/dialogs/logout_dialog.dart';
import 'package:care_now/enums/menu_action.dart';
import 'package:care_now/extensions/buildcontext/loc.dart';
// import 'package:care_now/services/auth/auth_service.dart';
import 'package:care_now/services/auth/bloc/auth_bloc.dart';
import 'package:care_now/services/auth/bloc/auth_event.dart';
import 'package:care_now/utilities/dialogs/logout_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
            IconButton(
              onPressed: () {
                // Navigator.of(context).pushNamed(
                //     createOrUpdateNoteRoute); //use pushNamed cuz it will have back button in the new note view
              },
              icon: const Icon(Icons.add),
            ),
            PopupMenuButton<MenuAction>(
            onSelected: (value) async {
              switch (value) {
                case MenuAction.logout:
                  final shouldLogout = await showLogoutDialog(context);
                  if (shouldLogout) {
                    context.read<AuthBloc>().add(
                          const AuthEventLogOut(),
                        );
                  }
              }
            },
            itemBuilder: (context) {
              return [
                PopupMenuItem<MenuAction>(
                  value: MenuAction.logout,
                  child: Text(context.loc.logout_button),
                ),
              ];
            },
          )
          ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // User profile image
            const CircleAvatar(
              radius: 50.0,
              backgroundImage: AssetImage('assets/images/profile_image.jpg'),
            ),
            const SizedBox(height: 20.0),

            // Text to display username
            const Text(
              // userName,
              'John Doe',
              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10.0),

            // Setting option row
            ListTile(
              title: const Text('Edit Profile'),
              leading: const Icon(Icons.edit),
              onTap: () {
                // Handle edit profile action
              },
            ),

            // Divider
            const Divider(),

            // Another setting option row
            ListTile(
              title: const Text('Settings'),
              leading: const Icon(Icons.settings),
              onTap: () {
                // Handle settings action
              },
            ),
          ],
        ),
      ),
    );
  }
}
