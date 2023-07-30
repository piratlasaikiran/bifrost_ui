import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                // Handle "Manage Bank Accounts" action
              },
              child: const Text('Manage Bank Accounts'),
            ),
            ElevatedButton(
              onPressed: () {
                // Handle "Manage User Logins" action
              },
              child: const Text('Users And Permissions'),
            ),
          ],
        ),
      ),
    );
  }
}
