import 'package:bifrost_ui/Employees/Supervisor/supervisor_actions.dart';
import 'package:bifrost_ui/Sites/site_actions.dart';
import 'package:bifrost_ui/Vehicles/vehicle_actions.dart';
import 'package:flutter/material.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';

class AddSiteDialog extends StatefulWidget {
  const AddSiteDialog({Key? key}) : super(key: key);

  @override
  _AddSiteDialogState createState() => _AddSiteDialogState();
}

class _AddSiteDialogState extends State<AddSiteDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late BuildContext dialogContext;

  final TextEditingController _siteNameController = TextEditingController();
  final TextEditingController _siteAddressController = TextEditingController();
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

  SiteActions siteActions = SiteActions();

  @override
  void initState() {
    super.initState();
    _fetchVehicles();
    _fetchSupervisors();
    _fetchStatusOptions();
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

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Create Site'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _siteNameController,
                decoration: const InputDecoration(
                  labelText: 'Site Name',
                ),
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
                controller: _siteAddressController,
                decoration: const InputDecoration(
                  labelText: 'Site Address Number',
                ),
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
                value: _selectedStatus,
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
              GestureDetector(
                onTap: () {
                  _showStartDatePicker(context);
                },
                child: InputDecorator(
                  decoration: const InputDecoration(labelText: 'Work Start Date'),
                  child: Text(_startDate?.toString() ?? 'Select Date'),
                ),
              ),
              GestureDetector(
                onTap: () {
                  _showEndDatePicker(context);
                },
                child: InputDecorator(
                  decoration: const InputDecoration(labelText: 'Work End Date'),
                  child: Text(_endDate?.toString() ?? 'Select Date'),
                ),
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
        TextButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              _formKey.currentState!.save();
              dialogContext = context;
              _saveSiteData();
              // Navigator.pop(context);
            }
          },
          child: const Text('Save'),
        ),
      ],
    );
  }

  Future<void> _showStartDatePicker(BuildContext context) async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      setState(() {
        _startDate = pickedDate;
      });
    }
  }

  Future<void> _showEndDatePicker(BuildContext context) async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      setState(() {
        _endDate = pickedDate;
      });
    }
  }

  Future<void> _saveSiteData() async {
    final siteName = _siteNameController.text;
    final siteAddress = _siteAddressController.text;
    final siteStatus = _selectedStatus;

    SiteActions siteActions = SiteActions();
    final result = await siteActions.saveSite(siteName: siteName,
        address: _siteAddress,
        siteStatus: _selectedStatus!,
        vehicles: _selectedVehicles,
        supervisors: _selectedIncharges,
        startDate: _startDate,
        endDate: _endDate);

    if (result) {
      // Show success popup
      Future.microtask(() {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Success'),
              content: const Text('Site saved successfully.'),
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
              content: const Text('Failed to save site.'),
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
