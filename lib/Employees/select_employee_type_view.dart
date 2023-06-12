import 'package:bifrost_ui/Employees/Driver/driver_actions.dart';
import 'package:flutter/material.dart';


import 'Driver/driver_list_page.dart';
import 'Supervisor/supervisor_actions.dart';
import 'Supervisor/supervisor_list_page.dart';


class SelectEmployeeTypeForViewDialog extends StatefulWidget {
  const SelectEmployeeTypeForViewDialog({super.key});


  @override
  _SelectEmployeeTypeForViewDialogState createState() =>
      _SelectEmployeeTypeForViewDialogState();
}

class _SelectEmployeeTypeForViewDialogState extends State<SelectEmployeeTypeForViewDialog> {
  String? selectedOption;

  Future<void> selectOption(String? option) async {
    setState(() {
      selectedOption = option;
    });

    // Perform different actions based on the selected option
    if (option == 'Supervisor') {
      SupervisorActions supervisorActions = SupervisorActions();
      List<SupervisorDTO> supervisorDTOs = await supervisorActions.getAllSupervisors();
      Future.microtask(() {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                SupervisorListPage(supervisors: supervisorDTOs),
          ),
        );
      });
    } else if (option == 'Driver') {
      DriverActions driverActions = DriverActions();
      List<DriverDTO> driverDTOs = await driverActions.getAllDrivers();
      Future.microtask(() {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DriverListPage(drivers: driverDTOs),
          ),
        );
      });
    } else if (option == 'Vendor') {
      // Action for Vendor option
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          buildOptionTile('Supervisor'),
          buildOptionTile('Driver'),
          buildOptionTile('Vendor'),
        ],
      ),
    );
  }

  Widget buildOptionTile(String option) {
    final bool isSelected = option == selectedOption;

    return InkWell(
      onTap: () {
        selectOption(option);
      },
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue.shade100 : null,
          borderRadius: BorderRadius.circular(12.0),
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.transparent,
            width: 2.0,
          ),
        ),
        child: ListTile(
          title: Text(
            option,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isSelected ? Colors.blue : Colors.black,
            ),
          ),
        ),
      ),
    );
  }
}
