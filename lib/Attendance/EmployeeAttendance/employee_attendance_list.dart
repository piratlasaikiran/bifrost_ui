import 'package:flutter/material.dart';

import 'employee_attendance_actions.dart';

class EmployeeAttendanceListPage extends StatelessWidget {
  final List<EmployeeAttendanceDTO> employeeAttendances;

  const EmployeeAttendanceListPage({Key? key, required this.employeeAttendances}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Employee Attendances'),
      ),
      body: ListView.separated(
        itemCount: employeeAttendances.length,
        separatorBuilder: (context, index) => Divider(color: Colors.grey[800]),
        itemBuilder: (context, index) {
          return EmployeeAttendanceTile(employeeAttendance: employeeAttendances[index]);
        },
      ),
    );
  }
}

class EmployeeAttendanceTile extends StatelessWidget {
  final EmployeeAttendanceDTO employeeAttendance;

  const EmployeeAttendanceTile({Key? key, required this.employeeAttendance}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        employeeAttendance.employeeName ?? '',
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
      ),
      subtitle: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(employeeAttendance.site ?? ''),
                ],
              ),
            ],
          ),
          Row(
            children: [
              const Icon(Icons.calendar_today),
              const SizedBox(width: 4),
              Text(employeeAttendance.attendanceDate ?? ''),
            ],
          ),
        ],
      ),
    );
  }
}


