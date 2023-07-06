import 'package:bifrost_ui/Vehicles/vehicle_actions.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'add_vehicle_dialog.dart';
import 'edit_vehicle_tax_dialog.dart';

class VehicleTaxListPage extends StatelessWidget {
  final List<VehicleTaxDTO> vehicleTaxes;

  const VehicleTaxListPage({Key? key, required this.vehicleTaxes}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vehicle Taxes'),
      ),
      body: ListView.builder(
        itemCount: vehicleTaxes.length,
        itemBuilder: (context, index) {
          final vehicleTax = vehicleTaxes[index];
          // Build your UI for each vehicle tax item
          return Column(
            children: [
              ListTile(
                title: Text(
                  vehicleTax.vehicleNumber,
                  style: const TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Row(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          const Icon(
                            Icons.currency_rupee_rounded,
                            size: 16.0,
                          ),
                          Text(
                            '${vehicleTax.amount}',
                            style: const TextStyle(fontSize: 14.0),
                          ),
                          const SizedBox(width: 8.0),
                          Chip(
                            label: Text(
                              vehicleTax.taxType ?? '',
                              style: const TextStyle(fontSize: 12.0),
                            ),
                            backgroundColor: Colors.blue,
                            labelStyle: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8.0),
                    const Icon(
                      Icons.calendar_month_outlined,
                      size: 18.0,
                    ),
                    const SizedBox(width: 2.0),
                    Text(
                      DateFormat('dd-MM-yyyy').format(vehicleTax.validityEndDate),
                      style: const TextStyle(
                        fontSize: 14.0,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),

                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    PopupMenuButton<String>(
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'view_edit',
                          child: Text('View And Edit'),
                        ),
                        const PopupMenuItem(
                          value: 'upload_new',
                          child: Text('Upload New'),
                        ),
                      ],
                      onSelected: (value) {
                        if (value == 'view_edit') {
                          Future.microtask(() {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    VehicleTaxEditDialog(vehicleTaxDTO: vehicleTax),
                              ),
                            );
                          });
                        }else if (value == 'upload_new') {
                          Future.microtask(() {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    AddVehicleTaxDialog(vehicleNumber: vehicleTax.vehicleNumber, taxType: vehicleTax.taxType,),
                              ),
                            );
                          });
                        }
                      },
                    ),
                  ],
                ),
              ),
              const Divider(
                color: Colors.grey,
                thickness: 1.0,
              ),
            ],
          );
        },
      ),
    );
  }
}
