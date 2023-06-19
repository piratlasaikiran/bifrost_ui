import 'package:bifrost_ui/Vehicles/upload_vehicle_tax_dialog.dart';
import 'package:bifrost_ui/Vehicles/vehicle_actions.dart';
import 'package:bifrost_ui/Vehicles/vehicle_list_page.dart';
import 'package:flutter/material.dart';

import 'add_vehicle_dialog.dart';

class VehicleOptionsPage extends StatelessWidget {
  const VehicleOptionsPage({super.key});


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text('Vehicle Actions'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildCircularButton(
              icon: Icons.add,
              label: 'Add Vehicle',
              onTap: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return const AddVehicleDialog();
                  },
                );
              },
            ),
            const SizedBox(height: 16.0),
            _buildCircularButton(
              icon: Icons.upload_file,
              label: 'Upload Tax Receipt',
              onTap: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return const UploadVehicleTaxDialog();
                  },
                );
              },
            ),
            const SizedBox(height: 16.0),
            _buildCircularButton(
              icon: Icons.car_rental,
              label: 'View Vehicles',
              onTap: () async {
                VehicleActions vehicleActions = VehicleActions();
                List<VehicleDTO> vehicleDTOs = await vehicleActions.getAllVehicles();
                Future.microtask(() {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => VehicleListPage(vehicles: vehicleDTOs),
                    ),
                  );
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCircularButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 180.0,
        height: 180.0,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.blue,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 48.0,
              color: Colors.white,
            ),
            const SizedBox(height: 8.0),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16.0,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
