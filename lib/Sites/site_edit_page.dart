import 'package:bifrost_ui/Employees/Supervisor/supervisor_actions.dart';
import 'package:bifrost_ui/Sites/site_actions.dart';
import 'package:bifrost_ui/Vehicles/vehicle_actions.dart';
import 'package:flutter/material.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';

import '../Utils/formatting_util.dart';

class EditSiteDialog extends StatefulWidget {
  final SiteDTO site;

  const EditSiteDialog({Key? key, required this.site}) : super(key: key);

  @override
  _EditSiteDialogState createState() => _EditSiteDialogState();
}

class _EditSiteDialogState extends State<EditSiteDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late BuildContext dialogContext;
  FormattingUtility formattingUtility = FormattingUtility();
  SiteActions siteActions = SiteActions();

  late String _siteName;
  late String _siteAddress;
  DateTime? _startDate;
  DateTime? _endDate;
  String? _selectedStatus;
  List<String> _selectedIncharges = [];
  List<String> _selectedVehicles = [];

  List<String> _vehicles = [];
  List<String> _supervisors = [];
  List<String> _statusOptions = [];

  @override
  void initState() {
    super.initState();
    _fetchVehicles();
    _fetchSupervisors();
    _fetchStatusOptions();
    _setInitialValues();
  }

  Future<void> _fetchVehicles() async {
    VehicleActions vehicleActions = VehicleActions();
    final vehicles = await vehicleActions.getVehicleNumbers();
    setState(() {
      _vehicles = vehicles;
    });
  }

  Future<void> _fetchSupervisors() async {
    SupervisorActions supervisorActions = SupervisorActions();
    final supervisors = await supervisorActions.getSupervisorNames();
    setState(() {
      _supervisors = supervisors;
    });
  }

  Future<void> _fetchStatusOptions() async {

    final statusOptions = await siteActions.getSiteStatuses();
    setState(() {
      _statusOptions = statusOptions;
    });
  }

  void _setInitialValues(){
    setState(() {
      _startDate = formattingUtility.getDateInDateTimeFormat(widget.site.startDate);
      _endDate = formattingUtility.getDateInDateTimeFormat(widget.site.endDate);
      _selectedIncharges = widget.site.supervisors!;
      _selectedVehicles = widget.site.vehicles!;
      _selectedStatus = widget.site.siteStatus;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Site'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Site Name',
                ),
                initialValue: widget.site.siteName,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter site name';
                  }
                  return null;
                },
                onSaved: (value) {
                  _siteName = value!;
                },
              ),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Site Address',
                ),
                initialValue: widget.site.address,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter site address';
                  }
                  return null;
                },
                onSaved: (value) {
                  _siteAddress = value!;
                },
              ),
              DropdownButtonFormField<String>(
                value: widget.site.siteStatus,
                onChanged: (value) {
                  setState(() {
                    _selectedStatus = value!;
                  });
                },
                items: _statusOptions.map((status) {
                  return DropdownMenuItem(
                    value: status,
                    child: Text(status),
                  );
                }).toList(),
                decoration: const InputDecoration(labelText: 'Site Status'),

                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select site status';
                  }
                  return null;
                },
              ),
              MultiSelectDialogField(
                title: const Text('Incharge Supervisors'),
                buttonText: const Text('Incharge Supervisors'),
                items: _supervisors
                    .map((supervisor) => MultiSelectItem<String>(supervisor, supervisor))
                    .toList(),
                listType: MultiSelectListType.CHIP,
                initialValue: _selectedIncharges,
                onConfirm: (List<String> values) {
                  setState(() {
                    _selectedIncharges = values;
                  });
                },
              ),
              MultiSelectDialogField(
                title: const Text('Working Vehicles'),
                buttonText: const Text('Working Vehicles'),
                items: _vehicles
                    .map((vehicle) => MultiSelectItem<String>(vehicle, vehicle))
                    .toList(),
                listType: MultiSelectListType.CHIP,
                initialValue: _selectedVehicles,
                onConfirm: (List<String> values) {
                  setState(() {
                    _selectedVehicles = values;
                  });
                },
              ),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Work Start Date',
                      ),
                      onTap: _showStartDatePicker,
                      readOnly: true,
                      validator: (value) {
                        if (_startDate == null) {
                          return 'Please select the work start date';
                        }
                        return null;
                      },
                      controller: TextEditingController(
                        text: _startDate != null ? _startDate.toString() : '',
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: _showStartDatePicker,
                    icon: const Icon(Icons.calendar_month),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Work End Date',
                      ),
                      onTap: _showEndDatePicker,
                      // initialValue: widget.site.endDate,
                      readOnly: true,
                      controller: TextEditingController(
                        text: _endDate != null ? _endDate.toString() : '',
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: _showStartDatePicker,
                    icon: const Icon(Icons.calendar_month),
                  ),
                ],
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
          onPressed: (){
            dialogContext = context;
            _updateSiteData();
          },
          child: const Text('Update'),
        ),
      ],
    );
  }

  Future<void> _showStartDatePicker() async {
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
        _startDate = pickedDate;
      });
    }
  }

  Future<void> _showEndDatePicker() async {
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
        _endDate = pickedDate;
      });
    }
  }

  Future<void> _updateSiteData() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final result = await siteActions.updateSite(
          initialSite: widget.site.siteName!,
          siteName: _siteName,
          address: _siteAddress,
          siteStatus: _selectedStatus!,
          vehicles: _selectedVehicles,
          supervisors: _selectedIncharges,
          startDate: _startDate,
          endDate: _endDate);

      if (result) {
        Future.microtask(() {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('Success'),
                content: const Text('Site updated successfully.'),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      Navigator.of(dialogContext).pop();
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
                content: const Text('Failed to update site.'),
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
}
