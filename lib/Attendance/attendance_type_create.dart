import 'package:flutter/material.dart';

import 'EmployeeAttendance/employee_attendance_input_dialog.dart';
import 'VendorAttendance/vendor_attendance_input_dialog.dart';

class SelectAttendanceTypeForCreationDialog extends StatefulWidget {
  const SelectAttendanceTypeForCreationDialog({super.key});


  @override
  _SelectAttendanceTypeForCreationDialog createState() =>
      _SelectAttendanceTypeForCreationDialog();
}

class _SelectAttendanceTypeForCreationDialog extends State<SelectAttendanceTypeForCreationDialog> {
  String? selectedOption;

  void selectOption(String? option) {
    setState(() {
      selectedOption = option;
    });

    // Perform different actions based on the selected option
    if (option == 'Vendor') {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return const VendorAttendanceInputDialog();
        },
      );
    } else if (option == 'Employee') {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return const EmployeeAttendanceInputDialog();
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
          buildOptionTile('Vendor'),
          buildOptionTile('Employee'),
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
