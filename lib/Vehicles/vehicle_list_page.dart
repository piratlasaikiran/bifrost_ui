import 'package:bifrost_ui/Vehicles/vehicle_actions.dart';
import 'package:flutter/material.dart';

import 'add_vehicle_dialog.dart';
import 'edit_vehicle_dialog.dart';

class VehicleListPage extends StatefulWidget {
  final List<VehicleDTO> vehicles;

  const VehicleListPage({Key? key, required this.vehicles}) : super(key: key);

  @override
  _VehicleListPage createState() => _VehicleListPage();
}

class _VehicleListPage extends State<VehicleListPage> {
  List <VehicleDTO> filteredVehicles = [];

  TextEditingController vehicleNumberController = TextEditingController();

  @override
  void initState() {
    super.initState();
    filteredVehicles = widget.vehicles;
  }

  @override
  void dispose() {
    vehicleNumberController.dispose();
    super.dispose();
  }

  void applyFilters() {
    setState(() {
      final filterVehicleNumber = vehicleNumberController.text.toLowerCase();

      filteredVehicles = widget.vehicles.where((vehicle) {
        final vehicleNumber = vehicle.vehicleNumber.toLowerCase();

        return vehicleNumber.contains(filterVehicleNumber);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vehicles'),
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
                          controller: vehicleNumberController,
                          onChanged: (_) => applyFilters(),
                          decoration: const InputDecoration(labelText: 'Vehicle Number'),
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
                itemCount: filteredVehicles.length,
                itemBuilder: (context, index) {
                  final vehicle = filteredVehicles[index];
                  return Column(
                      children: [
                        ListTile(
                          title: Text(
                            vehicle.vehicleNumber ?? '',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                          ),
                          subtitle: Text('Class: ${vehicle.vehicleClass ?? ''}'),
                          trailing: PopupMenuButton<String>(
                            itemBuilder: (context) {
                              return [
                                const PopupMenuItem(
                                  value: 'show_tax_receipts',
                                  child: Text('Show Tax Receipts'),
                                ),
                                const PopupMenuItem(
                                  value: 'view_edit',
                                  child: Text('View & Edit'),
                                ),
                                const PopupMenuItem(
                                  value: 'upload_tax_receipt',
                                  child: Text('Upload Vehicle Tax'),
                                )
                              ];
                            },
                            onSelected: (value) {
                              if (value == 'show_tax_receipts') {
                                // Perform action for show_tax_receipts
                              } else if(value == 'upload_tax_receipt'){
                                Future.microtask(() {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          AddVehicleTaxDialog(vehicleNumber: vehicle.vehicleNumber),
                                    ),
                                  );
                                });
                              } else if(value == 'view_edit'){
                                Future.microtask(() {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          VehicleEditDialog(vehicle: vehicle),
                                    ),
                                  );
                                });
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
