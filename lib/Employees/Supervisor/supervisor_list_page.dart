import 'package:bifrost_ui/Employees/Supervisor/supervisor_actions.dart';
import 'package:flutter/material.dart';

class SupervisorListPage extends StatelessWidget {
  final List<SupervisorDTO> supervisors;

  const SupervisorListPage({Key? key, required this.supervisors}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Supervisors'),
      ),
      body: ListView.separated(
        itemCount: supervisors.length,
        separatorBuilder: (context, index) => Divider(color: Colors.grey[800]),
        itemBuilder: (context, index) {
          return SupervisorTile(supervisor: supervisors[index]);
        },
      ),
    );
  }
}

class SupervisorTile extends StatelessWidget {
  final SupervisorDTO supervisor;

  const SupervisorTile({Key? key, required this.supervisor}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        supervisor.name ?? '',
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
      ),
      subtitle: Text('Mob: ${supervisor.mobileNumber ?? ''}'),
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
