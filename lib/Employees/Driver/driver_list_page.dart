import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'driver_actions.dart';
import 'driver_edit_page.dart';

class DriverListPage extends StatefulWidget {
  final List<DriverDTO> drivers;

  const DriverListPage({Key? key, required this.drivers}) : super(key: key);

  @override
  _DriverListPage createState() => _DriverListPage();
}

class _DriverListPage extends State<DriverListPage> {
  List <DriverDTO> filteredDrivers = [];

  TextEditingController driverNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    filteredDrivers = widget.drivers;
  }

  @override
  void dispose() {
    driverNameController.dispose();
    super.dispose();
  }

  void applyFilters() {
    setState(() {
      final filterDriverName = driverNameController.text.toLowerCase();

      filteredDrivers = widget.drivers.where((driver) {
        final accountName = driver.name.toLowerCase();

        return accountName.contains(filterDriverName);
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
        title: const Text('Drivers'),
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
                          controller: driverNameController,
                          onChanged: (_) => applyFilters(),
                          decoration: const InputDecoration(labelText: 'Driver Name'),
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
                itemCount: filteredDrivers.length,
                itemBuilder: (context, index) {
                  final driver = filteredDrivers[index];
                  return Column(
                      children: [
                        ListTile(
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
                                Future.microtask(() {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          DriverEditDialog(driver: driver),
                                    ),
                                  );
                                });
                              } else if (value == 'current_location') {
                                // Perform action for Current Location
                              } else if(value == 'call'){
                                String phoneNumber = driver.mobileNumber.toString() ?? '';
                                _makePhoneCall(phoneNumber);
                              }
                            },
                          ),
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
