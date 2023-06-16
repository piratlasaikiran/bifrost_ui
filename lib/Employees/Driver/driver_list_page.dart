import 'package:flutter/material.dart';

import 'driver_actions.dart';

class DriverListPage extends StatelessWidget {
  final List<DriverDTO> drivers;

  const DriverListPage({Key? key, required this.drivers}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Supervisors'),
      ),
      body: ListView.separated(
        itemCount: drivers.length,
        separatorBuilder: (context, index) => Divider(color: Colors.grey[800]),
        itemBuilder: (context, index) {
          return DriverTile(driver: drivers[index]);
        },
      ),
    );
  }
}

class DriverTile extends StatelessWidget {
  final DriverDTO driver;

  const DriverTile({super.key, required this.driver});


  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        driver.name ?? '',
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
      ),
      subtitle: Text('Mob: ${driver.mobileNumber ?? ''}'),
      trailing: PopupMenuButton<String>(
        itemBuilder: (context) {
          return [
            const PopupMenuItem(
              value: 'call',
              child: Text('Call'),
            ),
            const PopupMenuItem(
              value: 'view_edit',
              child: Text('View & Edit'),
            ),
            const PopupMenuItem(
              value: 'current_location',
              child: Text('Current Location'),
            ),
          ];
        },
        onSelected: (value) {
          if (value == 'view_edit') {
            // Perform action for View & Edit
          } else if (value == 'current_location') {
            // Perform action for Current Location
          } else if(value == 'call'){
            // Perform action for Call
          }
        },
      ),
    );
  }
}
