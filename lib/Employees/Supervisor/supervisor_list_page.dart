import 'package:bifrost_ui/Employees/Supervisor/supervisor_actions.dart';
import 'package:bifrost_ui/Employees/Supervisor/supervisor_edit_page.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class SupervisorListPage extends StatefulWidget {
  final List<SupervisorDTO> supervisors;

  const SupervisorListPage({Key? key, required this.supervisors}) : super(key: key);

  @override
  _SupervisorListPage createState() => _SupervisorListPage();
}

class _SupervisorListPage extends State<SupervisorListPage> {
  List <SupervisorDTO> filteredSupervisors = [];

  TextEditingController supervisorNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    filteredSupervisors = widget.supervisors;
  }

  @override
  void dispose() {
    supervisorNameController.dispose();
    super.dispose();
  }

  void applyFilters() {
    setState(() {
      final filterSupervisorName = supervisorNameController.text.toLowerCase();

      filteredSupervisors = widget.supervisors.where((supervisor) {
        final accountName = supervisor.name.toLowerCase();

        return accountName.contains(filterSupervisorName);
      }).toList();
    });
  }

  void _makePhoneCall(String phoneNumber) async {
    Uri url = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      throw 'Could not make phone call';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Supervisors'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(right: 20.0),
                        child: TextField(
                          controller: supervisorNameController,
                          onChanged: (_) => applyFilters(),
                          decoration: const InputDecoration(labelText: 'Supervisor Name'),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Divider(color: Colors.grey[800]),
          Expanded(
            child: ListView.builder(
                itemCount: filteredSupervisors.length,
                itemBuilder: (context, index) {
                  final supervisor = filteredSupervisors[index];
                  return Column(
                    children: [
                      ListTile(
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
                              Future.microtask(() {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        SupervisorEditDialog(supervisor: supervisor),
                                  ),
                                );
                              });
                            } else if (value == 'current_location') {
                            // Perform action for Current Location
                            } else if(value == 'call'){
                              String phoneNumber = supervisor.mobileNumber.toString() ?? '';
                              _makePhoneCall(phoneNumber);
                            }
                          },
                        ),
                      ),
                      const Divider(
                        color: Colors.grey,
                        thickness: 1.0,
                      ),
                    ]
                  );
                }
            ),
          ),
        ],
      ),
    );
  }
}
