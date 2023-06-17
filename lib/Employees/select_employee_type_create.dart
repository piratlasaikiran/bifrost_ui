import 'package:flutter/material.dart';

import 'Driver/driver_page.dart';
import 'Supervisor/supervisor_page.dart';
import 'Vendors/vendor_page.dart';

class SelectEmployeeTypeForCreationDialog extends StatefulWidget {
  const SelectEmployeeTypeForCreationDialog({super.key});


  @override
  _SelectEmployeeTypeForCreationDialogState createState() =>
      _SelectEmployeeTypeForCreationDialogState();
}

class _SelectEmployeeTypeForCreationDialogState extends State<SelectEmployeeTypeForCreationDialog> {
  String? selectedOption;

  void selectOption(String? option) {
    setState(() {
      selectedOption = option;
    });

    // Perform different actions based on the selected option
    if (option == 'Supervisor') {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return const SupervisorInputDialog();
        },
      );
    } else if (option == 'Driver') {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return const DriverInputDialog();
        },
      );
    } else if (option == 'Vendor') {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return const VendorInputDialog();
        },
      );
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
