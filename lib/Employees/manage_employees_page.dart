import 'package:bifrost_ui/Employees/select_employee_type.dart';
import 'package:flutter/material.dart';

class ManageEmployeesPage extends StatelessWidget {
  const ManageEmployeesPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Employees'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularButton(
              icon: Icons.person_add,
              label: 'Create\nEmployee',
              color: Colors.green,
              onTap: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) => const SelectEmployeeTypeDialog(),
                );
              },
            ),
            const SizedBox(height: 16.0),
            CircularButton(
              icon: Icons.edit,
              label: 'Update\nEmployee',
              color: Colors.orange,
              onTap: () {
                // Action to perform when 'Update Employee' button is clicked
              },
            ),
          ],
        ),
      ),
    );
  }
}

class CircularButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onTap;

  const CircularButton({super.key,
    required this.icon,
    required this.label,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 140.0,
        height: 140.0,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
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
              size: 64.0,
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
