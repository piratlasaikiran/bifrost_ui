import 'package:bifrost_ui/Employees/Supervisor/supervisor_actions.dart';
import 'package:bifrost_ui/Employees/Vendors/vendor_actions.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../Utils/formatting_util.dart';
import 'edit_vendor_attendance_input_dialog.dart';

class VendorAttendanceListPage extends StatefulWidget {
  final List<VendorAttendanceDTO> vendorAttendances;

  const VendorAttendanceListPage({Key? key, required this.vendorAttendances})
      : super(key: key);

  @override
  _VendorAttendanceListPageState createState() => _VendorAttendanceListPageState();
}

class _VendorAttendanceListPageState extends State<VendorAttendanceListPage> {

  List<VendorAttendanceDTO> filteredVendorAttendances = [];
  FormattingUtility formattingUtility = FormattingUtility();

  String vendorIdFilter = '';
  DateTime? attendanceStartDateFilter;
  DateTime? attendanceEndDateFilter;
  String siteFilter = '';

  TextEditingController vendorIdController = TextEditingController();
  TextEditingController siteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    filteredVendorAttendances = widget.vendorAttendances;
  }

  @override
  void dispose() {
    vendorIdController.dispose();
    siteController.dispose();
    super.dispose();
  }

  void applyFilters() {
    setState(() {
      final filterVendorId = vendorIdController.text.toLowerCase();
      final filterLocation = siteController.text.toLowerCase();

      filteredVendorAttendances = widget.vendorAttendances.where((vendorAttendance) {
        final vendorId = vendorAttendance.vendorId.toLowerCase();
        final location = vendorAttendance.site.toLowerCase();

        final isStartDateValid = attendanceStartDateFilter == null || formattingUtility.getDateInDateTimeFormat(vendorAttendance.attendanceDate).isAfter(attendanceStartDateFilter!);
        final isEndDateValid = attendanceEndDateFilter == null || formattingUtility.getDateInDateTimeFormat(vendorAttendance.attendanceDate).isBefore(attendanceEndDateFilter!);


        return vendorId.contains(filterVendorId) &&
            location.contains(filterLocation) &&
            isStartDateValid &&
            isEndDateValid;
      }).toList();
    });
  }

  void resetFilters() {
    setState(() {
      vendorIdFilter = '';
      attendanceStartDateFilter = null;
      attendanceEndDateFilter = null;
      siteFilter = '';
      filteredVendorAttendances = widget.vendorAttendances;
    });
    vendorIdController.clear();
    siteController.clear();
  }

  void _showVendorAttendance(VendorAttendanceDTO vendorAttendanceDTO){
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Vendor Attendance'),
          content: SingleChildScrollView(
            child: ListBody(
              children: vendorAttendanceDTO.commodityAttendance.entries.map((entry) {
                return Text('${entry.key}: ${entry.value}');
              }).toList(),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vendor Attendances'),
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
                          controller: vendorIdController,
                          onChanged: (_) => applyFilters(),
                          decoration: const InputDecoration(labelText: 'Vendor ID'),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
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
                  ],
                ),
              ],
            ),
          ),
          Divider(color: Colors.grey[800]),
          Expanded(
            child: ListView.builder(
              itemCount: filteredVendorAttendances.length,
              itemBuilder: (context, index) {
                final vendorAttendance = filteredVendorAttendances[index];
                return Column(
                  children: [
                    ListTile(
                      title: Text(
                        vendorAttendance.vendorId ?? '',
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
                                  Text(vendorAttendance.site ?? ''),
                                ],
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              const Icon(Icons.calendar_today),
                              const SizedBox(width: 4),
                              Text(vendorAttendance.attendanceDate ?? ''),
                            ],
                          ),
                        ],
                      ),
                      trailing: PopupMenuButton<String>(
                          itemBuilder: (context) {
                            return [
                              const PopupMenuItem(
                                value: 'view_attendance',
                                child: Text('View Attendance'),
                              ),
                              const PopupMenuItem(
                                value: 'view_edit',
                                child: Text('View & Edit'),
                              ),
                            ];
                          },
                          onSelected: (value) {
                            if (value == 'view_attendance') {
                              _showVendorAttendance(vendorAttendance);
                            } else if (value == 'view_edit') {
                              Future.microtask(() {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        EditVendorAttendanceInputDialog(vendorAttendanceDTO: vendorAttendance),
                                  ),
                                );
                              });
                            }
                          }
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