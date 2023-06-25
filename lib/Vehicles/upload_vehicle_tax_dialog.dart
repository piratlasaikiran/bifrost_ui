import 'dart:io';

import 'package:bifrost_ui/Vehicles/vehicle_actions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';

class UploadVehicleTaxDialog extends StatefulWidget {
  const UploadVehicleTaxDialog({super.key});


  @override
  _UploadVehicleTaxDialogState createState() => _UploadVehicleTaxDialogState();
}

class _UploadVehicleTaxDialogState extends State<UploadVehicleTaxDialog> {

  List<String> _taxTypes = [];
  List<String> _vehicles = [];
  VehicleActions vehicleActions = VehicleActions();
  final _vehicleNumberController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchVehicles();
    _fetchVehicleTaxTypesList();
  }

  void _fetchVehicles() async {
    final vehicles = await vehicleActions.getVehicleNumbers();
    setState(() {
      _vehicles = vehicles;
      _vehicleNumberController.text = _selectedVehicle ?? '';
    });
  }

  @override
  void dispose() {
    _vehicleNumberController.dispose();
    super.dispose();
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
  String? _selectedVehicle;



  Future<void> _saveVehicleTax() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final result = await vehicleActions.uploadVehicleTax(
          amount: _amount,
          vehicleNumber: _selectedVehicle,
          taxType: _selectedTaxType,
          validityStartDate: _validityStartDate,
          validityEndDate: _validityEndDate,
          receipt: _receipt);

      if (result) {
        // Show success popup
        Future.microtask(() {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('Success'),
                content: const Text('Vehicle tax uploaded successfully.'),
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
                content: const Text('Failed to upload vehicle tax.'),
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
              Container(
                margin: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  children: [
                    const Text('Vehicle Number'),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TypeAheadFormField<String>(
                        key: const Key('Vehicle Number'),
                        textFieldConfiguration: TextFieldConfiguration(
                          controller: _vehicleNumberController,
                          decoration: const InputDecoration(
                            hintText: 'Vehicle Number',
                            hintStyle: TextStyle(fontSize: 14),
                            prefixIcon: Icon(Icons.search),
                          ),
                        ),
                        suggestionsCallback: (String pattern) {
                          if (pattern.isEmpty) {
                            return _vehicles;
                          } else {
                            final filteredList = _vehicles
                                .where((vehicle) => vehicle.toLowerCase().contains(pattern.toLowerCase()))
                                .toList();
                            return filteredList;
                          }
                        },
                        itemBuilder: (BuildContext context, String suggestion) {
                          return ListTile(
                            title: Text(suggestion),
                          );
                        },
                        onSuggestionSelected: (String suggestion) {
                          setState(() {
                            _selectedVehicle = suggestion;
                            _vehicleNumberController.text = suggestion;
                          });
                        },
                        validator: (String? value) {
                          if (value == null || value.isEmpty) {
                            return 'Please select a vehicle number';
                          }
                          return null;
                        },
                        onSaved: (String? value) {
                          _selectedVehicle = value;
                        },
                      ),
                    )
                  ],
                ),
              ),
              Container(
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