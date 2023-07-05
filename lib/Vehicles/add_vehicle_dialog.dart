import 'dart:io';

import 'package:bifrost_ui/Vehicles/vehicle_actions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';

class AddVehicleDialog extends StatefulWidget {
  const AddVehicleDialog({Key? key}) : super(key: key);

  @override
  _AddVehicleDialogState createState() => _AddVehicleDialogState();
}

class _AddVehicleDialogState extends State<AddVehicleDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late BuildContext dialogContext;

  String _vehicleNumber = '';
  late String _owner;
  late String _chassisNumber;
  late String _engineNumber;
  late String _vehicleClass;
  String? _insuranceProvider;
  String? _financeProvider;
  final List<VehicleTaxDTO> _vehicleTaxes = [];
  final _vehicleNumberController = TextEditingController();

  bool _isInsuranceProviderNotApplicable = false;
  bool _isFinanceProviderNotApplicable = false;

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

  Future<void> _saveVehicle() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      VehicleActions vehicleActions = VehicleActions();
      final result = await vehicleActions.saveVehicle(vehicleNumber: _vehicleNumber,
          owner: _owner,
          chassisNumber: _chassisNumber,
          engineNumber: _engineNumber,
          vehicleClass: _vehicleClass,
          insuranceProvider: _isInsuranceProviderNotApplicable ? null : _insuranceProvider,
          financeProvider: _isFinanceProviderNotApplicable ? null : _financeProvider,
          vehicleTaxes: _vehicleTaxes);

      if (result) {
        // Show success popup
        Future.microtask(() {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('Success'),
                content: const Text('Vehicle saved successfully.'),
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
                content: const Text('Failed to save vehicle.'),
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

  void _showAddVehicleTaxDialog(String vehicleNumber) async {
    final VehicleTaxDTO? newTax = await showDialog<VehicleTaxDTO>(
      context: context,
      builder: (BuildContext context) {
        return AddVehicleTaxDialog(vehicleNumber: vehicleNumber);
      },
    );

    if (newTax != null) {
      setState(() {
        _vehicleTaxes.add(newTax);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Vehicle'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _vehicleNumberController,
                decoration: const InputDecoration(
                  labelText: 'Vehicle Number',
                ),
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
              Padding(
                padding: const EdgeInsets.only(top: 24.0),
                child: ElevatedButton(
                  onPressed: (){
                    _showAddVehicleTaxDialog(_vehicleNumberController.text);
                  },
                  child: const Text('Add Vehicle Tax'),
                ),
              ),
              const SizedBox(height: 16.0),
              if (_vehicleTaxes.isNotEmpty)
                const Text(
                  'Vehicle Taxes:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              Column(
                children: _vehicleTaxes.map((tax) => ListTile(
                  title: Text(tax.taxType.toString()),
                  trailing: IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      setState(() {
                        _vehicleTaxes.remove(tax);
                      });
                    },
                  ),
                )).toList(),
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
              _saveVehicle();
            }
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}

class AddVehicleTaxDialog extends StatefulWidget {
  final String vehicleNumber;
  const AddVehicleTaxDialog({Key? key, required this.vehicleNumber}) : super(key: key);


  @override
  _AddVehicleTaxDialogState createState() => _AddVehicleTaxDialogState();
}

class _AddVehicleTaxDialogState extends State<AddVehicleTaxDialog> {

  List<String> _taxTypes = [];
  VehicleActions vehicleActions = VehicleActions();

  @override
  void initState() {
    super.initState();
    _fetchVehicleTaxTypesList();
  }

  void _fetchVehicleTaxTypesList() async {
    final taxTypes = await vehicleActions.getVehicleTaxTypes();
    setState(() {
      _taxTypes = taxTypes;
    });
  }

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late int _amount;
  late File? _receipt = null;
  DateTime? _validityStartDate;
  DateTime? _validityEndDate;
  String? _selectedTaxType;



  void _saveVehicleTax() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final VehicleTaxDTO newTax = VehicleTaxDTO(
          vehicleNumber: widget.vehicleNumber,
          amount: _amount,
          receipt: _receipt!,
          validityStartDate: _validityStartDate!,
          validityEndDate: _validityEndDate!,
          taxType: _selectedTaxType
      );

      Navigator.of(context).pop(newTax);
    }
  }



  Future<void> _selectValidityStartDate() async {
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
        _validityStartDate = pickedDate;
      });
    }
  }

  Future<void> _selectValidityEndDate() async {
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
        _validityEndDate = pickedDate;
      });
    }
  }

  void _pickReceiptImage(ImageSource source) async {
    final pickedImage = await ImagePicker().pickImage(source: source);
    if (pickedImage != null) {
      setState(() {
        _receipt = File(pickedImage.path);
      });
    }
  }

  void _removeReceiptImage() {
    setState(() {
      _receipt = null;
    });
  }

  Widget _buildReceiptImageWidget() {
    if (_receipt != null) {
      return Column(
        children: [
          Image.file(
            _receipt!,
            width: 100,
            height: 100,
          ),
          ElevatedButton(
            onPressed: _removeReceiptImage,
            child: const Text('Remove Receipt Image'),
          ),
        ],
      );
    } else {
      return TextButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: const Text('Select Receipt Image'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ListTile(
                      leading: const Icon(Icons.photo_library),
                      title: const Text('Pick from Gallery'),
                      onTap: () {
                        _pickReceiptImage(ImageSource.gallery);
                        Navigator.of(context).pop();
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.camera_alt),
                      title: const Text('Take a Picture'),
                      onTap: () {
                        _pickReceiptImage(ImageSource.camera);
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
        child: Container(
          margin: const EdgeInsets.only(top: 16.0),
          child: const Text('Upload Receipt Image'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Vehicle Tax'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container( // Container containing the dropdown widget
                margin: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  children: [
                    const Text('Tax Type'),
                    const SizedBox(width: 10),
                    DropdownButton<String>(
                      value: _selectedTaxType,
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedTaxType = newValue!;
                        });
                      },
                      items: _taxTypes.map((String taxType) {
                        return DropdownMenuItem<String>(
                          value: taxType,
                          child: Text(taxType),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Amount',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the amount';
                  }
                  return null;
                },
                onSaved: (value) {
                  _amount = int.parse(value!);
                },
              ),
              _buildReceiptImageWidget(),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Validity Start Date',
                      ),
                      onTap: _selectValidityStartDate,
                      readOnly: true,
                      validator: (value) {
                        if (_validityStartDate == null) {
                          return 'Please select the validity start date';
                        }
                        return null;
                      },
                      controller: TextEditingController(
                        text: _validityStartDate != null ? _validityStartDate.toString() : '',
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: _selectValidityStartDate,
                    icon: const Icon(Icons.calendar_today),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Validity End Date',
                      ),
                      onTap: _selectValidityEndDate,
                      readOnly: true,
                      validator: (value) {
                        if (_validityEndDate == null) {
                          return 'Please select the validity end date';
                        }
                        return null;
                      },
                      controller: TextEditingController(
                        text: _validityEndDate != null ? _validityEndDate.toString() : '',
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: _selectValidityEndDate,
                    icon: const Icon(Icons.calendar_today),
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
            Navigator.of(context).pop();
          },
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _saveVehicleTax,
          child: const Text('Save'),
        ),
      ],
    );
  }
}