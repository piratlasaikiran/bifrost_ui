import 'package:bifrost_ui/Vehicles/vehicle_actions.dart';
import 'package:flutter/material.dart';


class VehicleListPage extends StatelessWidget {
  final List<VehicleDTO> vehicles;

  const VehicleListPage({Key? key, required this.vehicles}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Supervisors'),
      ),
      body: ListView.separated(
        itemCount: vehicles.length,
        separatorBuilder: (context, index) => Divider(color: Colors.grey[800]),
        itemBuilder: (context, index) {
          return VehicleTile(vehicle: vehicles[index]);
        },
      ),
    );
  }
}

class VehicleTile extends StatelessWidget {
  final VehicleDTO vehicle;

  const VehicleTile({super.key, required this.vehicle});


  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        vehicle.vehicleNumber ?? '',
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
      ),
      subtitle: Text('Vehicle Class: ${vehicle.vehicleClass ?? ''}'),
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
              value: 'current_location',
              child: Text('Current Location'),
            ),
          ];
        },
        onSelected: (value) {
          if (value == 'show_tax_receipts') {
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
