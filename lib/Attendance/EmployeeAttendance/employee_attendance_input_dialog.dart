import 'package:bifrost_ui/Attendance/EmployeeAttendance/employee_attendance_actions.dart';
import 'package:bifrost_ui/Employees/Driver/driver_actions.dart';
import 'package:flutter/material.dart';

import '../../BankAccounts/bank_account_actions.dart';
import '../../Sites/site_actions.dart';

class EmployeeAttendanceInputDialog extends StatefulWidget {
  const EmployeeAttendanceInputDialog({Key? key}) : super(key: key);

  @override
  _EmployeeAttendanceInputDialogState createState() =>
      _EmployeeAttendanceInputDialogState();
}

class _EmployeeAttendanceInputDialogState
    extends State<EmployeeAttendanceInputDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  EmployeeAttendanceActions employeeAttendanceActions = EmployeeAttendanceActions();
  String? _selectedEmployeeType;
  String? _selectedEmployeeName;
  DateTime? _selectedAttendanceDate;
  String? _selectedSite;
  String? _selectedAttendanceType;
  String? _selectedBankAccount;

  bool makeTransaction = true;
  bool showBankAccountName = true;

  List<String> _employeeTypes = [];
  List<String> _employeeNames = [];
  List<String> _sites = [];
  List<String> _attendanceTypes = [];
  List<String> _bankAccounts = [];

  @override
  void initState() {
    super.initState();
    _fetchEmployeeTypes();
    _fetchAttendanceTypes();
    _fetchSites();
    _fetchBankAccounts();
  }

  void _fetchEmployeeTypes() async {
    final employeeTypes = await employeeAttendanceActions.getEmployeeTypes();
    setState(() {
      _employeeTypes = employeeTypes;
    });
  }

  void _fetchAttendanceTypes() async {
    final attendanceTypes = await employeeAttendanceActions.getAttendanceTypes();
    setState(() {
      _attendanceTypes = attendanceTypes;
    });
  }

  void _fetchSites() async {
    SiteActions siteActions = SiteActions();
    final sites = await siteActions.getSiteNames();
    setState(() {
      _sites = sites;
    });
  }

  Future<List<String>> _fetchEmployeeNames(String employeeType) async {
    if(employeeType == 'DRIVER') {
      DriverActions driverActions = DriverActions();
      final employeeNames = await driverActions.getDriverNames();
      return employeeNames;
    }
    return [];
  }

  void _fetchBankAccounts() async {
    BankAccountActions bankAccountActions = BankAccountActions();
    final accountNames = await bankAccountActions.getAccountNickNames();
    setState(() {
      _bankAccounts = accountNames;
      _bankAccounts.add("My Account");
    });
  }

  Future<void> _selectAttendanceDate() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: Colors.blue, // Head color
            hintColor: Colors.blue, // Selection color
            colorScheme: const ColorScheme.light(primary: Colors.blue),
            buttonTheme: const ButtonThemeData(
              textTheme: ButtonTextTheme.primary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      setState(() {
        _selectedAttendanceDate = pickedDate;
      });
    }
  }

  Future<void> _enterEmployeeAttendance() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final result = await employeeAttendanceActions.saveAttendance(
          employeeType: _selectedEmployeeType!,
          employeeName: _selectedEmployeeName!,
          site: _selectedSite!,
          attendanceType: _selectedAttendanceType!,
          attendanceDate: _selectedAttendanceDate!,
          makeTransaction: makeTransaction,
          bankAccount: _selectedBankAccount);
      if (result) {
        // Show success popup
        Future.microtask(() {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('Success'),
                content: const Text('Employee Attendance Entered Successfully.'),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).pop();
                    },
                    child: const Text('OK'),
                  ),
                ],
              );
            },
          );
        });
      } else {
        Future.microtask(() {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('Failure'),
                content: const Text('Failed to enter employee attendance.'),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('OK'),
                  ),
                ],
              );
            },
          );
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Employee Attendance'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DropdownButtonFormField<String>(
                value: _selectedEmployeeType,
                onChanged: (String? value) async {
                  _employeeNames = await _fetchEmployeeNames(value!);
                  setState(() {
                    _selectedEmployeeType = value;
                  });
                },
                validator: (value) {
                  if (_selectedEmployeeType == null) {
                    return 'Please select employee type';
                  }
                  return null;
                },
                items: _employeeTypes.map((String type) {
                  return DropdownMenuItem<String>(
                    value: type,
                    child: Text(type),
                  );
                }).toList(),
                decoration: const InputDecoration(labelText: 'Employee Type'),
              ),
              DropdownButtonFormField<String>(
                value: _selectedEmployeeName,
                onChanged: (String? value) {
                  setState(() {
                    _selectedEmployeeName = value;
                  });
                },
                validator: (value) {
                  if (_selectedEmployeeName == null) {
                    return 'Please select employee name';
                  }
                  return null;
                },
                items: _employeeNames.map((String name) {
                  return DropdownMenuItem<String>(
                    value: name,
                    child: Text(name),
                  );
                }).toList(),
                decoration: const InputDecoration(labelText: 'Employee Name'),
              ),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Attendance Date',
                      ),
                      onTap: _selectAttendanceDate,
                      readOnly: true,
                      validator: (value) {
                        if (_selectedAttendanceDate == null) {
                          return 'Please select attendance date';
                        }
                        return null;
                      },
                      controller: TextEditingController(
                        text: _selectedAttendanceDate != null ? _selectedAttendanceDate.toString() : '',
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: _selectAttendanceDate,
                    icon: const Icon(Icons.calendar_today),
                  ),
                ],
              ),
              Row(
                children: [
                  const Text('Make Transaction:'),
                  Switch(
                    value: makeTransaction,
                    onChanged: (value) {
                      setState(() {
                        makeTransaction = value;
                        showBankAccountName = value;
                      });
                    },
                  ),
                ],
              ),
              if (showBankAccountName)
                DropdownButtonFormField<String>(
                  value: _selectedBankAccount,
                  onChanged: (value) {
                    setState(() {
                      _selectedBankAccount = value;
                    });
                  },
                  items: _bankAccounts.map((purpose) {
                    return DropdownMenuItem<String>(
                      value: purpose,
                      child: Text(purpose),
                    );
                  }).toList(),
                  decoration: const InputDecoration(labelText: 'Bank Account'),
                ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: _selectedSite,
                onChanged: (String? value) {
                  setState(() {
                    _selectedSite = value;
                  });
                },
                validator: (value) {
                  if (_selectedSite == null) {
                    return 'Please select site';
                  }
                  return null;
                },
                items: _sites.map((String site) {
                  return DropdownMenuItem<String>(
                    value: site,
                    child: Text(site),
                  );
                }).toList(),
                decoration: const InputDecoration(labelText: 'Site'),
              ),
              DropdownButtonFormField<String>(
                value: _selectedAttendanceType,
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedAttendanceType = newValue!;
                  });
                },
                validator: (value) {
                  if (_selectedAttendanceType == null) {
                    return 'Please select attendance type';
                  }
                  return null;
                },
                items: _attendanceTypes.map((String type) {
                  return DropdownMenuItem<String>(
                    value: type,
                    child: Text(type),
                  );
                }).toList(),
                decoration: const InputDecoration(labelText: 'Attendance Type'),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _enterEmployeeAttendance,
          child: const Text('Save'),
        ),
      ],
    );
  }
}
