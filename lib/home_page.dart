import 'package:bifrost_ui/Vehicles/vehicle_options_page.dart';
import 'package:flutter/material.dart';

import 'Employees/employee_options_page.dart';
import 'Sites/site_options_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Page'),
      ),
      body: GridView.count(
        crossAxisCount: 2,
        children: [
          ButtonTile(
            title: 'Employees',
            color: Colors.blue,
            icon: Icons.people,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const EmployeeOptionsPage()),
              );
            },
          ),
          ButtonTile(
            title: 'Sites',
            color: Colors.orange,
            icon: Icons.location_on,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SiteOptionsPage()),
              );
            },
          ),
          ButtonTile(
            title: 'Transactions',
            color: Colors.green,
            icon: Icons.attach_money,
            onTap: () {
              // Action to perform when 'Transactions' button is clicked
            },
          ),
          ButtonTile(
            title: 'Current Location',
            color: Colors.purple,
            icon: Icons.my_location,
            onTap: () {
              // Action to perform when 'Assets' button is clicked
            },
          ),
          ButtonTile(
            title: 'Vehicles',
            color: Colors.red, // Adjust color as per your preference
            icon: Icons.directions_car, // Icon for Vehicles
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const VehicleOptionsPage()),
              );
            },
          ),
        ],
      ),
    );
  }
}

class ButtonTile extends StatelessWidget {
  final String title;
  final Color color;
  final IconData icon;
  final VoidCallback? onTap;

  const ButtonTile({super.key,
    required this.title,
    required this.color,
    required this.icon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 4.0,
              offset: const Offset(0, 2),
            ),
          ],
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
              title,
              style: const TextStyle(
                fontSize: 18.0,
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
