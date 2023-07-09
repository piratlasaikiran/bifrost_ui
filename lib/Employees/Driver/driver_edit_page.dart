import 'dart:io';

import 'package:bifrost_ui/Employees/Driver/driver_actions.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class DriverEditDialog extends StatefulWidget {
  final DriverDTO driver;

  const DriverEditDialog({Key? key, required this.driver}) : super(key: key);

  @override
  _DriverEditDialogState createState() => _DriverEditDialogState();
}

class _DriverEditDialogState extends State<DriverEditDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  DriverActions supervisorActions = DriverActions();
  DriverActions driverActions = DriverActions();
  late BuildContext dialogContext;

  String? _firstName;
  String? _lastName;
  String? _mobileNumber;
  String? _bankAccountNumber;
  double? _salary;
  bool _admin = false;
  File? _aadharImage;
  File? _licenseImage;
  double? _otPayDay;
  double? _otPayDayNight;

  @override
  void initState() {
    super.initState();
    _fetchAadhar();
    _fetchLicense();
    _initialiseName();
  }

  Future<void> _fetchAadhar() async {
    final aadharImage = await driverActions.getAadhar(widget.driver.name);
    setState(() {
      _aadharImage = aadharImage;
    });
  }

  Future<void> _fetchLicense() async {
    final licenseImage = await driverActions.getLicense(widget.driver.name);
    setState(() {
      _licenseImage = licenseImage;
    });
  }
  void _initialiseName(){
    List<String> nameParts = widget.driver.name.split(' ');
    _firstName = nameParts.length > 1 ? nameParts.sublist(0, nameParts.length - 1).join(' ') : null;
    _lastName = nameParts.isNotEmpty ? nameParts.last : null;
  }

  Future<void> _updateDriver() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      if (_aadharImage == null) {
        showDialog(
          context: dialogContext,
          builder: (context) {
            return AlertDialog(
              title: const Text('Aadhar Upload'),
              content: const Text('Please upload Aadhar image.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
        return;
      }

      if (_licenseImage == null) {
        showDialog(
          context: dialogContext,
          builder: (context) {
            return AlertDialog(
              title: const Text('License Upload'),
              content: const Text('Please upload license image.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
        return;
      }

      String? fullName = '${_firstName ?? ''} ${_lastName ?? ''}';
      final result = await supervisorActions.updateDriver(existingDriver: widget.driver.name,
          name: fullName,
          mobileNumber: _mobileNumber,
          bankAccountNumber: _bankAccountNumber,
          salary: _salary,
          isAdmin: _admin,
          aadhar: _aadharImage,
          license: _licenseImage,
          otPayDay: _otPayDay,
          otPayDayNight: _otPayDayNight);
      if (result) {
        Future.microtask(() {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('Success'),
                content: const Text('Driver edited successfully.'),
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
        driverActions.deleteTemporaryLocation(_aadharImage!);
        driverActions.deleteTemporaryLocation(_licenseImage!);
      } else {
        Future.microtask(() {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('Failure'),
                content: const Text('Failed to edit driver.'),
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

  void _pickAadharImage(ImageSource source) async {
    final pickedImage = await ImagePicker().pickImage(source: source);
    if (pickedImage != null) {
      setState(() {
        _aadharImage = File(pickedImage.path);
      });
    }
  }

  void _pickLicenseImage(ImageSource source) async {
    final pickedImage = await ImagePicker().pickImage(source: source);
    if (pickedImage != null) {
      setState(() {
        _licenseImage = File(pickedImage.path);
      });
    }
  }

  void _removeAadharImage() {
    setState(() {
      _aadharImage = null;
    });
  }

  void _removeLicenseImage() {
    setState(() {
      _licenseImage = null;
    });
  }

  Widget _buildAadharImageWidget() {
    if (_aadharImage != null) {
      return Column(
        children: [
          Image.file(
            _aadharImage!,
            width: 100,
            height: 100,
          ),
          ElevatedButton(
            onPressed: _removeAadharImage,
            child: const Text('Remove Aadhar Image'),
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
                title: const Text('Select Aadhar Image'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ListTile(
                      leading: const Icon(Icons.photo_library),
                      title: const Text('Pick from Gallery'),
                      onTap: () {
                        _pickAadharImage(ImageSource.gallery);
                        Navigator.of(context).pop();
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.camera_alt),
                      title: const Text('Take a Picture'),
                      onTap: () {
                        _pickAadharImage(ImageSource.camera);
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
        child: const Text('Upload Aadhar Image'),
      );
    }
  }

  Widget _buildLicenseImageWidget() {
    if (_licenseImage != null) {
      return Column(
        children: [
          Image.file(
            _licenseImage!,
            width: 100,
            height: 100,
          ),
          ElevatedButton(
            onPressed: _removeLicenseImage,
            child: const Text('Remove License Image'),
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
                title: const Text('Select License Image'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ListTile(
                      leading: const Icon(Icons.photo_library),
                      title: const Text('Pick from Gallery'),
                      onTap: () {
                        _pickLicenseImage(ImageSource.gallery);
                        Navigator.of(context).pop();
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.camera_alt),
                      title: const Text('Take a Picture'),
                      onTap: () {
                        _pickLicenseImage(ImageSource.camera);
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
        child: const Text('Upload License Image'),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Driver Details'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'First Name',
                ),
                initialValue: _firstName,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter first name';
                  }
                  return null;
                },
                onSaved: (value) {
                  _firstName = value;
                },
              ),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Last Name',
                ),
                initialValue: _lastName,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter last name';
                  } else if(value.contains(' ')){
                    return 'Last Name can not contain space';
                  }
                  return null;
                },
                onSaved: (value) {
                  _lastName = value;
                },
              ),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Mobile Number',
                ),
                initialValue: widget.driver.mobileNumber.toString(),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a mobile number';
                  }
                  if (value.length != 10 || int.tryParse(value) == null) {
                    return 'Invalid mobile number';
                  }
                  return null;
                },
                onSaved: (value) {
                  _mobileNumber = value;
                },
              ),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Bank Account Number',
                ),
                initialValue: widget.driver.bankAccountNumber,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a bank account number';
                  }
                  return null;
                },
                onSaved: (value) {
                  _bankAccountNumber = value;
                },
              ),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Salary',
                ),
                keyboardType: TextInputType.number,
                initialValue: widget.driver.salary.toString(),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter salary';
                  }
                  double? salary = double.tryParse(value);
                  if (salary == null || salary <= 0) {
                    return 'Invalid salary';
                  }
                  return null;
                },
                onSaved: (value) {
                  _salary = double.tryParse(value!);
                },
              ),
              SwitchListTile(
                title: const Text('Admin'),
                value: widget.driver.admin!,
                onChanged: (value) {
                  setState(() {
                    _admin = value;
                  });
                },
              ),
              _buildAadharImageWidget(),
              _buildLicenseImageWidget(),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'OT Pay Day',
                ),
                keyboardType: TextInputType.number,
                initialValue: widget.driver.otPayDay.toString(),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter OT pay for day';
                  }
                  double? otPay = double.tryParse(value);
                  if (otPay == null || otPay <= 0) {
                    return 'Invalid OT pay for day';
                  }
                  return null;
                },
                onSaved: (value) {
                  _otPayDay = double.tryParse(value!);
                },
              ),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'OT Pay Day&Night',
                ),
                keyboardType: TextInputType.number,
                initialValue: widget.driver.otPayDayNight.toString(),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter OT pay for day&night';
                  }
                  double? otPay = double.tryParse(value);
                  if (otPay == null || otPay <= 0) {
                    return 'Invalid OT pay for Day&Night';
                  }
                  return null;
                },
                onSaved: (value) {
                  _otPayDayNight = double.tryParse(value!);
                },
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
          onPressed: (){
            dialogContext = context;
            _updateDriver();
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}
