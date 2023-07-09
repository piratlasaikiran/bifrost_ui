import 'dart:io';

import 'package:bifrost_ui/Employees/Supervisor/supervisor_actions.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../BankAccounts/bank_account_actions.dart';

class SupervisorEditDialog extends StatefulWidget {
  final SupervisorDTO supervisor;

  const SupervisorEditDialog({Key? key, required this.supervisor}) : super(key: key);

  @override
  _SupervisorEditDialogState createState() => _SupervisorEditDialogState();
}

class _SupervisorEditDialogState extends State<SupervisorEditDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  SupervisorActions supervisorActions = SupervisorActions();
  BankAccountActions bankAccountActions = BankAccountActions();
  late BuildContext dialogContext;

  String? _firstName;
  String? _lastName;
  String? _mobileNumber;
  String? _bankAccountNumber;
  double? _salary;
  bool _admin = false;
  File? _aadharImage;
  String? _companyMobileNumber;
  String? _atmCardNumber;
  double? _otPay;

  List<String> availableATMCards = [];

  @override
  void initState() {
    super.initState();
    _fetchAadhar();
    _fetchATMCards();
    _initialiseName();
  }

  Future<void> _fetchAadhar() async {
    final aadharImage = await supervisorActions.getAadhar(widget.supervisor.name);
    setState(() {
      _aadharImage = aadharImage;
    });
  }

  void _fetchATMCards() async {
    final atmCards = await bankAccountActions.getATMCards();
    setState(() {
      availableATMCards = atmCards;
      _atmCardNumber = availableATMCards.firstWhere((card) => card == widget.supervisor.atmCardNumber.toString(),  orElse: () => '');
      if(_atmCardNumber == ''){
        _atmCardNumber = null;
      }
    });
  }

  void _initialiseName(){
    List<String> nameParts = widget.supervisor.name.split(' ');
    _firstName = nameParts.length > 1 ? nameParts.sublist(0, nameParts.length - 1).join(' ') : null;
    _lastName = nameParts.isNotEmpty ? nameParts.last : null;
  }

  Future<void> _updateSupervisor() async {
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
      final result = await supervisorActions.updateSupervisor(existingSupervisor: widget.supervisor.name,
          name: fullName,
          mobileNumber: _mobileNumber,
          bankAccountNumber: _bankAccountNumber,
          salary: _salary,
          isAdmin: _admin,
          aadhar: _aadharImage,
          companyMobileNumber: _companyMobileNumber,
          atmCard: _atmCardNumber,
          otPay: _otPay);
      if (result) {
        // Show success popup
        Future.microtask(() {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('Success'),
                content: const Text('Supervisor updated successfully.'),
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
        supervisorActions.deleteTemporaryLocation(_aadharImage!);
      } else {
        Future.microtask(() {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('Failure'),
                content: const Text('Failed to update supervisor.'),
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
      title: const Text('Edit Supervisor Details'),
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
                initialValue: widget.supervisor.mobileNumber.toString(),
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
                initialValue: widget.supervisor.bankAccountNumber,
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
                initialValue: widget.supervisor.salary.toString(),
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
                value: widget.supervisor.admin!,
                onChanged: (value) {
                  setState(() {
                    _admin = value;
                  });
                },
              ),
              _buildAadharImageWidget(),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Company Mobile Number',
                ),
                initialValue: widget.supervisor.companyMobileNumber != null ? widget.supervisor.companyMobileNumber.toString() : '',
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
                initialValue: widget.supervisor.otPay.toString(),
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
            _updateSupervisor();
          },
          child: const Text('Update'),
        ),
      ],
    );
  }
}
