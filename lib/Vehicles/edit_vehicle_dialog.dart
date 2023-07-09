
import 'package:bifrost_ui/Vehicles/vehicle_actions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class VehicleEditDialog extends StatefulWidget {
  final VehicleDTO vehicle;

  const VehicleEditDialog({Key? key, required this.vehicle}) : super(key: key);


  @override
  _VehicleEditDialog createState() => _VehicleEditDialog();
}

class _VehicleEditDialog extends State<VehicleEditDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late BuildContext dialogContext;

  late String _vehicleNumber;
  late String _owner;
  late String _chassisNumber;
  late String _engineNumber;
  late String _vehicleClass;
  String? _insuranceProvider;
  String? _financeProvider;

  bool _isInsuranceProviderNotApplicable = false;
  bool _isFinanceProviderNotApplicable = false;

  @override
  void initState() {
    super.initState();
    _setInitialValues();
  }

  void _setInitialValues() {
    setState(() {
      _isInsuranceProviderNotApplicable =
      (widget.vehicle.insuranceProvider == null ||
          widget.vehicle.insuranceProvider!.isEmpty) ? true : false;
      _isFinanceProviderNotApplicable =
      (widget.vehicle.financeProvider == null ||
          widget.vehicle.financeProvider!.isEmpty) ? true : false;
    });
  }

  void _toggleInsuranceProviderNotApplicable() {
    setState(() {
      _isInsuranceProviderNotApplicable = !_isInsuranceProviderNotApplicable;
      if (_isInsuranceProviderNotApplicable) {
        _insuranceProvider = null;
      }
    });
  }

  void _toggleFinanceProviderNotApplicable() {
    setState(() {
      _isFinanceProviderNotApplicable = !_isFinanceProviderNotApplicable;
      if (_isFinanceProviderNotApplicable) {
        _financeProvider = null;
      }
    });
  }

  Future<void> _updateVehicle() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      VehicleActions vehicleActions = VehicleActions();
      final result = await vehicleActions.updateVehicle(currentVehicleNumber: widget.vehicle.vehicleNumber,
          vehicleNumber: _vehicleNumber,
          owner: _owner,
          chassisNumber: _chassisNumber,
          engineNumber: _engineNumber,
          vehicleClass: _vehicleClass,
          insuranceProvider: _isInsuranceProviderNotApplicable ? null : _insuranceProvider,
          financeProvider: _isFinanceProviderNotApplicable ? null : _financeProvider);

      if (result) {
        // Show success popup
        Future.microtask(() {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('Success'),
                content: const Text('Vehicle edited successfully.'),
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
                content: const Text('Failed to edit vehicle.'),
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
      title: const Text('Edit Vehicle'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Vehicle Number',
                ),
                initialValue: widget.vehicle.vehicleNumber,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the vehicle number';
                  }
                  return null;
                },
                onSaved: (value) {
                  _vehicleNumber = value!;
                },
              ),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Owner',
                ),
                initialValue: widget.vehicle.owner,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the owner';
                  }
                  return null;
                },
                onSaved: (value) {
                  _owner = value!;
                },
              ),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Chassis Number',
                ),
                initialValue: widget.vehicle.chassisNumber,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the chassis number';
                  }
                  return null;
                },
                onSaved: (value) {
                  _chassisNumber = value!;
                },
              ),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Engine Number',
                ),
                initialValue: widget.vehicle.engineNumber,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the engine number';
                  }
                  return null;
                },
                onSaved: (value) {
                  _engineNumber = value!;
                },
              ),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Vehicle Class',
                ),
                initialValue: widget.vehicle.vehicleClass,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the vehicle class';
                  }
                  return null;
                },
                onSaved: (value) {
                  _vehicleClass = value!;
                },
              ),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Insurance Provider',
                      ),
                      initialValue: widget.vehicle.insuranceProvider,
                      validator: (value) {
                        if (!_isInsuranceProviderNotApplicable && (value == null || value.isEmpty)) {
                          return 'Please enter the insurance provider';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _insuranceProvider = value!;
                      },
                      enabled: !_isInsuranceProviderNotApplicable,
                    ),
                  ),
                  Checkbox(
                    value: _isInsuranceProviderNotApplicable,
                    onChanged: (value) {
                      _toggleInsuranceProviderNotApplicable();
                    },
                  ),
                  const Text('NA'),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Finance Provider',
                      ),
                      initialValue: widget.vehicle.financeProvider,
                      validator: (value) {
                        if (!_isFinanceProviderNotApplicable && (value == null || value.isEmpty)) {
                          return 'Please enter the finance provider';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _financeProvider = value!;
                      },
                      enabled: !_isFinanceProviderNotApplicable,
                    ),
                  ),
                  Checkbox(
                    value: _isFinanceProviderNotApplicable,
                    onChanged: (value) {
                      _toggleFinanceProviderNotApplicable();
                    },
                  ),
                  const Text('NA'),
                ],
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              _formKey.currentState!.save();
              dialogContext = context;
              _updateVehicle();
            }
          },
          child: const Text('Update'),
        ),
      ],
    );
  }
}
