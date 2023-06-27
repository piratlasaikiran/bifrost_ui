import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../Utils/formatting_util.dart';
import 'employee_attendance_actions.dart';

class EmployeeAttendanceListPage extends StatefulWidget {
  final List<EmployeeAttendanceDTO> employeeAttendances;

  const EmployeeAttendanceListPage({Key? key, required this.employeeAttendances}) : super(key: key);

  @override
  _EmployeeAttendanceListPageState createState() => _EmployeeAttendanceListPageState();
}

class _EmployeeAttendanceListPageState extends State<EmployeeAttendanceListPage> {

  List<EmployeeAttendanceDTO> filteredEmployeeAttendances = [];
  FormattingUtility formattingUtility = FormattingUtility();

  String employeeNameFilter = '';
  String employeeTypeFilter = '';
  DateTime? attendanceStartDateFilter;
  DateTime? attendanceEndDateFilter;
  String siteFilter = '';

  TextEditingController employeeNameController = TextEditingController();
  TextEditingController employeeTypeController = TextEditingController();
  TextEditingController siteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    filteredEmployeeAttendances = widget.employeeAttendances;
  }

  @override
  void dispose() {
    employeeNameController.dispose();
    employeeTypeController.dispose();
    siteController.dispose();
    super.dispose();
  }

  void applyFilters() {
    setState(() {
      final filterEmployeeName = employeeNameController.text.toLowerCase();
      final filterEmployeeType = employeeTypeController.text.toLowerCase();
      final filterLocation = siteController.text.toLowerCase();

      filteredEmployeeAttendances = widget.employeeAttendances.where((employeeAttendance) {
        final employeeName = employeeAttendance.employeeName.toLowerCase();
        final employeeType = employeeAttendance.employeeType.toLowerCase();
        final location = employeeAttendance.site.toLowerCase();

        final isStartDateValid = attendanceStartDateFilter == null || formattingUtility.getDateInDateTimeFormat(employeeAttendance.attendanceDate).isAfter(attendanceStartDateFilter!);
        final isEndDateValid = attendanceEndDateFilter == null || formattingUtility.getDateInDateTimeFormat(employeeAttendance.attendanceDate).isBefore(attendanceEndDateFilter!);


        return employeeName.contains(filterEmployeeName) &&
            employeeType.contains(filterEmployeeType) &&
            location.contains(filterLocation) &&
            isStartDateValid &&
            isEndDateValid;
      }).toList();
    });
  }

  void resetFilters() {
    setState(() {
      employeeNameFilter = '';
      employeeTypeFilter = '';
      attendanceStartDateFilter = null;
      attendanceEndDateFilter = null;
      siteFilter = '';
      filteredEmployeeAttendances = widget.employeeAttendances;
    });
    employeeNameController.clear();
    employeeTypeController.clear();
    siteController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Employee Attendances'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'reset') {
                resetFilters();
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'reset',
                child: Text('Reset Filters'),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(right: 20.0),
                        child: TextField(
                          controller: employeeNameController,
                          onChanged: (_) => applyFilters(),
                          decoration: const InputDecoration(labelText: 'Employee Name'),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(right: 20.0),
                        child: TextField(
                          controller: employeeTypeController,
                          onChanged: (_) => applyFilters(),
                          decoration: const InputDecoration(labelText: 'Employee Type'),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () async {
                          final DateTime? pickedDate = await showDatePicker(
                            context: context,
                            initialDate: attendanceStartDateFilter ?? DateTime.now(),
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2100),
                          );
                          if (pickedDate != null) {
                            setState(() {
                              attendanceStartDateFilter = pickedDate;
                              applyFilters();
                            });
                          }
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(right: 20.0),
                          child: InputDecorator(
                            decoration: const InputDecoration(
                              labelText: 'Start Date',
                              suffixIcon: Icon(Icons.calendar_today),
                            ),
                            child: Text(
                              attendanceStartDateFilter != null
                                  ? DateFormat('yyyy-MM-dd').format(attendanceStartDateFilter!)
                                  : '',
                              style: const TextStyle(fontSize: 12),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: InkWell(
                        onTap: () async {
                          final DateTime? pickedDate = await showDatePicker(
                            context: context,
                            initialDate: attendanceEndDateFilter ?? DateTime.now(),
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2100),
                          );
                          if (pickedDate != null) {
                            setState(() {
                              attendanceEndDateFilter = pickedDate;
                              applyFilters();
                            });
                          }
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(right: 20.0),
                          child: InputDecorator(
                            decoration: const InputDecoration(
                              labelText: 'End Date',
                              suffixIcon: Icon(Icons.calendar_today),
                            ),
                            child: Text(
                              attendanceEndDateFilter != null
                                  ? DateFormat('yyyy-MM-dd').format(attendanceEndDateFilter!)
                                  : '',
                              style: const TextStyle(fontSize: 12),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8), // Add spacing between text fields
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(right: 20.0),
                        child: TextField(
                          controller: siteController,
                          decoration: const InputDecoration(labelText: 'Site'),
                          onChanged: (_) => applyFilters(),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Divider(color: Colors.grey[800]),
          Expanded(
            child: ListView.builder(
              itemCount: filteredEmployeeAttendances.length,
              itemBuilder: (context, index) {
                final employeeAttendance = filteredEmployeeAttendances[index];
                return Column(
                  children: [
                    ListTile(
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
                    ),
                    const Divider(color: Colors.grey),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
