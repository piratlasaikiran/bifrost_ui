import 'dart:io';

import 'package:bifrost_ui/BankAccounts/bank_account_actions.dart';
import 'package:bifrost_ui/Employees/Supervisor/supervisor_actions.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class SupervisorInputDialog extends StatefulWidget {
  const SupervisorInputDialog({super.key});

  @override
  _SupervisorInputDialogState createState() => _SupervisorInputDialogState();
}

class _SupervisorInputDialogState extends State<SupervisorInputDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  BankAccountActions bankAccountActions = BankAccountActions();
  SupervisorActions supervisorActions = SupervisorActions();

  late BuildContext dialogContext;

  String? _firstName;
  String? _lastName;
  String? _mobileNumber;
  String? _bankAccountNumber;
  double? _salary;
  File? _aadharImage;
  String? _companyMobileNumber;
  String? _atmCardNumber;
  double? _otPay;

  List<String> availableATMCards = [];

  @override
  void initState() {
    super.initState();
    _fetchATMCards();
  }

  void _fetchATMCards() async {
    final atmCards = await bankAccountActions.getATMCards();
    setState(() {
      availableATMCards = atmCards;
    });
  }

  Future<void> _saveSupervisor() async {
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

      String? fullName = '${_firstName ?? ''} ${_lastName ?? ''}';
      final result = await supervisorActions.saveSupervisor(name: fullName, mobileNumber: _mobileNumber, bankAccountNumber: _bankAccountNumber, salary: _salary,
          aadhar: _aadharImage, companyMobileNumber: _companyMobileNumber, atmCard: _atmCardNumber, otPay: _otPay);
      if (result) {
        // Show success popup
        Future.microtask(() {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('Success'),
                content: const Text('Supervisor saved successfully.'),
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
                content: const Text('Failed to save supervisor.'),
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

  void _removeAadharImage() {
    setState(() {
      _aadharImage = null;
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

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Enter Supervisor Details'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'First Name',
                ),
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
                keyboardType: TextInputType.number,
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
              _buildAadharImageWidget(),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Company Mobile Number',
                ),
                validator: (value) {
                  if (value != null && value.isNotEmpty) {
                    if (value.length != 10 || int.tryParse(value) == null) {
                      return 'Invalid company mobile number';
                    }
                  }
                  return null;
                },
                onSaved: (value) {
                  _companyMobileNumber = value;
                },
              ),
              Container(
                margin: const EdgeInsets.symmetric(vertical: 14.0),
                child: Row(
                  children: [
                    const Text('ATM Card'),
                    const SizedBox(width: 10),
                    DropdownButton<String>(
                      value: _atmCardNumber,
                      onChanged: (String? newValue) {
                        setState(() {
                          _atmCardNumber = newValue!;
                        });
                      },
                      items: availableATMCards.map((String atmCard) {
                        return DropdownMenuItem<String>(
                          value: atmCard,
                          child: Text(atmCard),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'OT Pay',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter OT pay';
                  }
                  double? otPay = double.tryParse(value);
                  if (otPay == null || otPay <= 0) {
                    return 'Invalid OT pay';
                  }
                  return null;
                },
                onSaved: (value) {
                  _otPay = double.tryParse(value!);
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
            _saveSupervisor();
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}
