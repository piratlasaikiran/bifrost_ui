import 'dart:io';

import 'package:bifrost_ui/BankAccounts/bank_account_actions.dart';
import 'package:bifrost_ui/Employees/Driver/driver_actions.dart';
import 'package:bifrost_ui/Employees/Supervisor/supervisor_actions.dart';
import 'package:bifrost_ui/Employees/Vendors/vendor_actions.dart';
import 'package:bifrost_ui/Transactions/transaction_actions.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:image_picker/image_picker.dart';

class AddTransactionDialog extends StatefulWidget {
  const AddTransactionDialog({super.key});


  @override
  _AddTransactionDialogState createState() => _AddTransactionDialogState();
}

class _AddTransactionDialogState extends State<AddTransactionDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TransactionActions transactionActions = TransactionActions();

  String? _selectedSource;
  String? _selectedDestination;
  int? _amount;
  File? _bill;
  String? _selectedPurpose;
  String? _selectedMode;
  String? _selectedBankAccount;
  DateTime? _transactionDate;
  String? _remarks;

  final _tnxSourceController = TextEditingController();
  final _tnxDestinationController = TextEditingController();

  List<String> _sources = [];
  List<String> _destinations = [];
  List<String> _purposes = [];
  List<String> _modes = [];
  List<String> _bankAccounts = [];

  @override
  void initState() {
    super.initState();
    _fetchTransactionPurposes();
    _fetchTransactionModes();
    _fetchBankAccounts();
    _fetchSources();
    _fetchDestinations();
  }

  void _fetchTransactionPurposes() async {
    final transactionPurposes = await transactionActions.getPurposes();
    setState(() {
      _purposes = transactionPurposes;
    });
  }

  void _fetchTransactionModes() async {
    final transactionModes = await transactionActions.getModes();
    setState(() {
      _modes = transactionModes;
    });
  }

  void _fetchBankAccounts() async {
    BankAccountActions bankAccountActions = BankAccountActions();
    final accountNames = await bankAccountActions.getAccountNickNames();
    setState(() {
      _bankAccounts = accountNames;
      _bankAccounts.add("My Account");
    });
  }

  //ToDo: check and all remaining type of sources for transactions
  void _fetchSources() async {
    SupervisorActions supervisorActions = SupervisorActions();
    final supervisors = await supervisorActions.getSupervisorNames();
    setState(() {
      _sources = supervisors;
    });
  }

  void _fetchDestinations() async {
    SupervisorActions supervisorActions = SupervisorActions();
    final supervisors = await supervisorActions.getSupervisorNames();

    DriverActions driverActions = DriverActions();
    final drivers = await driverActions.getDriverNames();

    VendorActions vendorActions = VendorActions();
    final vendors = await vendorActions.getVendorIds();

    setState(() {
      _destinations = supervisors;
      _destinations.addAll(drivers);
      _destinations.addAll(vendors);
    });
  }

  Future<void> _saveTransaction() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final result = await transactionActions.saveTransaction(
          source: _selectedSource,
          destination: _selectedDestination,
          amount: _amount,
          bill: _bill,
          purpose: _selectedPurpose,
          mode: _selectedMode,
          bankAccount: _selectedBankAccount,
          transactionDate: _transactionDate,
          remarks: _remarks);

      if(result){

      }else{

      }
    }
  }

  Future<void> _selectTransactionDate() async {
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
        _transactionDate = pickedDate;
      });
    }
  }

  void _pickBillImage(ImageSource source) async {
    final pickedImage = await ImagePicker().pickImage(source: source);
    if (pickedImage != null) {
      setState(() {
        _bill = File(pickedImage.path);
      });
    }
  }

  void _removeBillImage() {
    setState(() {
      _bill = null;
    });
  }

  Widget _buildBillImageWidget() {
    if (_bill != null) {
      return Column(
        children: [
          Image.file(
            _bill!,
            width: 100,
            height: 100,
          ),
          ElevatedButton(
            onPressed: _removeBillImage,
            child: const Text('Remove Bill Image'),
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
                title: const Text('Select Bill Image'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ListTile(
                      leading: const Icon(Icons.photo_library),
                      title: const Text('Pick from Gallery'),
                      onTap: () {
                        _pickBillImage(ImageSource.gallery);
                        Navigator.of(context).pop();
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.camera_alt),
                      title: const Text('Take a Picture'),
                      onTap: () {
                        _pickBillImage(ImageSource.camera);
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
          child: const Text('Upload Bill Image'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Transaction'),
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
                    const Text('Source'),
                    const SizedBox(width: 15),
                    Expanded(
                      child: TypeAheadFormField<String>(
                        key: const Key('Source'),
                        textFieldConfiguration: TextFieldConfiguration(
                          controller: _tnxSourceController,
                          decoration: const InputDecoration(
                            hintText: 'Source',
                            hintStyle: TextStyle(fontSize: 14),
                            prefixIcon: Icon(Icons.search),
                          ),
                        ),
                        suggestionsCallback: (String pattern) {
                          if (pattern.isEmpty) {
                            return _sources;
                          } else {
                            final filteredList = _sources
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
                            _selectedSource = suggestion;
                            _tnxSourceController.text = suggestion;
                          });
                        },
                        validator: (String? value) {
                          if (value == null || value.isEmpty) {
                            return 'Please select source';
                          }
                          return null;
                        },
                        noItemsFoundBuilder: (BuildContext context) {
                          return const SizedBox(
                            height: 48.0,
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 15.0),
                              child: Text(
                                'No items found',
                                style: TextStyle(
                                  fontSize: 16.0,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                          );
                        },
                        onSaved: (String? value) {
                          _selectedSource = value;
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
                    const Text('Destination'),
                    const SizedBox(width: 15),
                    Expanded(
                      child: TypeAheadFormField<String>(
                        key: const Key('Destination'),
                        textFieldConfiguration: TextFieldConfiguration(
                          controller: _tnxDestinationController,
                          decoration: const InputDecoration(
                            hintText: 'Destination',
                            hintStyle: TextStyle(fontSize: 14),
                            prefixIcon: Icon(Icons.search),
                          ),
                        ),
                        suggestionsCallback: (String pattern) {
                          if (pattern.isEmpty) {
                            return _destinations;
                          } else {
                            final filteredList = _destinations
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
                            _selectedDestination = suggestion;
                            _tnxDestinationController.text = suggestion;
                          });
                        },
                        validator: (String? value) {
                          if (value == null || value.isEmpty) {
                            return 'Please select destination';
                          }
                          return null;
                        },
                        noItemsFoundBuilder: (BuildContext context) {
                          return const SizedBox(
                            height: 48.0,
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 15.0),
                              child: Text(
                                'No items found',
                                style: TextStyle(
                                  fontSize: 16.0,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                          );
                        },
                        onSaved: (String? value) {
                          _selectedDestination = value;
                        },
                      ),
                    )
                  ],
                ),
              ),
              TextFormField(
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  setState(() {
                    _amount = int.tryParse(value);
                  });
                },
                decoration: const InputDecoration(labelText: 'Amount *'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an amount';
                  }
                  return null;
                },
                onSaved: (value) {
                  _amount = int.parse(value!);
                },
              ),
              DropdownButtonFormField<String>(
                value: _selectedPurpose,
                onChanged: (value) {
                  setState(() {
                    _selectedPurpose = value;
                  });
                },
                items: _purposes.map((purpose) {
                  return DropdownMenuItem<String>(
                    value: purpose,
                    child: Text(purpose),
                  );
                }).toList(),
                decoration: const InputDecoration(labelText: 'Purpose *'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a purpose';
                  }
                  return null;
                },
              ),
              _buildBillImageWidget(),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Transaction Date',
                      ),
                      onTap: _selectTransactionDate,
                      readOnly: true,
                      validator: (value) {
                        if (_transactionDate == null) {
                          return 'Please select transaction date';
                        }
                        return null;
                      },
                      controller: TextEditingController(
                        text: _transactionDate != null ? _transactionDate.toString() : '',
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: _selectTransactionDate,
                    icon: const Icon(Icons.calendar_today),
                  ),
                ],
              ),
              DropdownButtonFormField<String>(
                value: _selectedMode,
                onChanged: (value) {
                  setState(() {
                    _selectedMode = value;
                  });
                },
                items: _modes.map((mode) {
                  return DropdownMenuItem<String>(
                    value: mode,
                    child: Text(mode),
                  );
                }).toList(),
                decoration: const InputDecoration(labelText: 'Mode *'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a Mode';
                  }
                  return null;
                },
              ),
              DropdownButtonFormField<String>(
                value: _selectedBankAccount,
                onChanged: (value) {
                  setState(() {
                    _selectedBankAccount = value;
                  });
                },
                items: _bankAccounts.map((bankAccount) {
                  return DropdownMenuItem<String>(
                    value: bankAccount,
                    child: Text(bankAccount),
                  );
                }).toList(),
                decoration: const InputDecoration(labelText: 'Bank Account'),
              ),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Remarks',
                ),
                onChanged: (value) {
                  _remarks = value;
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
          onPressed: () {
            _saveTransaction();
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}
