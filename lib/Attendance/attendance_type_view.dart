import 'package:bifrost_ui/Attendance/EmployeeAttendance/employee_attendance_actions.dart';
import 'package:bifrost_ui/Employees/Vendors/vendor_actions.dart';
import 'package:flutter/material.dart';

import 'EmployeeAttendance/employee_attendance_input_dialog.dart';
import 'EmployeeAttendance/employee_attendance_list.dart';
import 'VendorAttendance/vendor_attendance_input_dialog.dart';
import 'VendorAttendance/vendor_attendance_list.dart';

class SelectAttendanceTypeForViewDialog extends StatefulWidget {
  const SelectAttendanceTypeForViewDialog({super.key});


  @override
  _SelectAttendanceTypeForViewDialog createState() =>
      _SelectAttendanceTypeForViewDialog();
}

class _SelectAttendanceTypeForViewDialog extends State<SelectAttendanceTypeForViewDialog> {
  String? selectedOption;

  Future<void> selectOption(String? option) async {
    setState(() {
      selectedOption = option;
    });

    // Perform different actions based on the selected option
    if (option == 'Vendor') {
      VendorActions vendorActions = VendorActions();
      List<VendorAttendanceDTO> vendorAttendanceDTOs = await vendorActions.getAllVendorAttendance();
      Future.microtask(() {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                VendorAttendanceListPage(vendorAttendances: vendorAttendanceDTOs),
          ),
        );
      });
    } else if (option == 'Employee') {
      EmployeeAttendanceActions employeeAttendanceActions = EmployeeAttendanceActions();
      List<EmployeeAttendanceDTO> employeeAttendanceDTOs = await employeeAttendanceActions.getAllEmployeeAttendance();
      Future.microtask(() {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                EmployeeAttendanceListPage(employeeAttendances: employeeAttendanceDTOs),
          ),
        );
      });
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
