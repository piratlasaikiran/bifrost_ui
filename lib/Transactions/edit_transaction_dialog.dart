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

import '../Sites/site_actions.dart';
import '../Utils/formatting_util.dart';
import '../Vehicles/vehicle_actions.dart';

class EditTransactionDialog extends StatefulWidget {
  final TransactionDTO transaction;

  const EditTransactionDialog({Key? key, required this.transaction}) : super(key: key);


  @override
  _EditTransactionDialogState createState() => _EditTransactionDialogState();
}

class _EditTransactionDialogState extends State<EditTransactionDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TransactionActions transactionActions = TransactionActions();
  FormattingUtility formattingUtility = FormattingUtility();
  SiteActions siteActions = SiteActions();
  BankAccountActions bankAccountActions = BankAccountActions();
  VendorActions vendorActions = VendorActions();
  DriverActions driverActions = DriverActions();
  SupervisorActions supervisorActions = SupervisorActions();
  VehicleActions vehicleActions = VehicleActions();

  String? _selectedSource;
  String? _selectedDestination;
  int? _amount;
  File? _bill;
  String? _selectedPurpose;
  String? _selectedMode;
  String? _selectedBankAccount;
  DateTime? _transactionDate;
  String? _remarks;
  String? _selectedSite;
  String? _selectedVehicle;
  bool _associationWithSite = false;
  bool _associationWithVehicle = false;

  final TextEditingController _tnxSourceController = TextEditingController();
  final TextEditingController _tnxDestinationController = TextEditingController();
  final TextEditingController _tnxSiteController = TextEditingController();
  final TextEditingController _tnxVehicleController = TextEditingController();

  List<String> _sources = [];
  List<String> _destinations = [];
  List<String> _purposes = [];
  List<String> _modes = [];
  List<String> _bankAccounts = [];
  List<String> _sites = [];
  List<String> _vehicles = [];

  void _toggleSiteAssociation() {
    setState(() {
      _associationWithSite = !_associationWithSite;
      if (_associationWithSite) {
        _selectedSite = null;
      }
    });
  }

  void _toggleVehicleAssociation() {
    setState(() {
      _associationWithVehicle = !_associationWithVehicle;
      if (_associationWithVehicle) {
        _selectedVehicle = null;
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _fetchTransactionPurposes();
    _fetchTransactionModes();
    _fetchBankAccounts();
    _fetchSources();
    _fetchDestinations();
    _selectedBankAccount = 'My Account';
    _setInitialData();
    _fetchSites();
    _fetchVehicles();
    _fetchBill();
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
    final accountNames = await bankAccountActions.getAccountNickNames();
    setState(() {
      _bankAccounts = accountNames;
      _bankAccounts.add("My Account");
    });
  }

  void _fetchSources() async {
    final supervisors = await supervisorActions.getSupervisorNames();
    setState(() {
      _sources = supervisors;
    });
  }

  void _fetchDestinations() async {
    final supervisors = await supervisorActions.getSupervisorNames();
    final drivers = await driverActions.getDriverNames();
    final vendors = await vendorActions.getVendorIds();

    setState(() {
      _destinations = supervisors;
      _destinations.addAll(drivers);
      _destinations.addAll(vendors);
    });
  }

  Future<void> _fetchBill() async {
    final billImage = await transactionActions.getBill(widget.transaction.transactionId);
    setState(() {
      _bill = billImage;
    });
  }

  void _fetchSites() async {
    final sites = await siteActions.getSiteNames();
    setState(() {
      _sites = sites;
    });
  }

  void _fetchVehicles() async {
    final vehicles = await vehicleActions.getVehicleNumbers();
    setState(() {
      _vehicles = vehicles;
    });
  }

  void _setInitialData(){
    setState(() {
      _tnxSourceController.text = widget.transaction.source;
      _tnxDestinationController.text = widget.transaction.destination;
      _tnxSiteController.text = widget.transaction.site!;
      _tnxVehicleController.text = widget.transaction.vehicle!;
      _transactionDate = formattingUtility.getDateInDateTimeFormat(widget.transaction.transactionDate);
    });
  }

  Future<void> _updateTransaction() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final result = await transactionActions.updateTransaction(
        transactionId: widget.transaction.transactionId,
        source: _selectedSource,
        destination: _selectedDestination,
        amount: _amount,
        bill: _bill,
        purpose: _selectedPurpose,
        site: _selectedSite,
        vehicleNumber: _selectedVehicle,
        mode: _selectedMode,
        bankAccount: _selectedBankAccount,
        transactionDate: _transactionDate,
        remarks: _remarks);

      if(result){
        Future.microtask(() {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('Success'),
                content: const Text('Transaction edited successfully.'),
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
          transactionActions.deleteTemporaryLocation(_bill!);
        });
      } else {
        Future.microtask(() {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('Failure'),
                content: const Text('Failed to edit transaction.'),
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
      title: const Text('Edit Transaction'),
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
                                .where((transaction) => transaction.toLowerCase().contains(pattern.toLowerCase()))
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
                                .where((transaction) => transaction.toLowerCase().contains(pattern.toLowerCase()))
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
                initialValue: widget.transaction.amount.toString(),
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
                value: widget.transaction.purpose,
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
                    icon: const Icon(Icons.calendar_month),
                  ),
                ],
              ),
              DropdownButtonFormField<String>(
                value: widget.transaction.mode,
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
                value: widget.transaction.bankAccount,
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
              Row(
                children: [
                  Expanded(
                    child: TypeAheadFormField<String>(
                      key: const Key('Site'),
                      textFieldConfiguration: TextFieldConfiguration(
                        controller: _tnxSiteController,
                        enabled: !_associationWithSite,
                        decoration: const InputDecoration(
                          hintText: 'Site',
                          hintStyle: TextStyle(fontSize: 14),
                          prefixIcon: Icon(Icons.search),
                        ),
                      ),
                      suggestionsCallback: (String pattern) {
                        if (pattern.isEmpty) {
                          return _sites;
                        } else {
                          final filteredList = _sites
                              .where((site) => site.toLowerCase().contains(pattern.toLowerCase()))
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
                          _selectedSite = suggestion;
                          _tnxSiteController.text = suggestion;
                        });
                      },
                      validator: (value) {
                        if (!_associationWithSite && (value == null || value.isEmpty)) {
                          return 'Please provide site name';
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
                        _selectedSite = value;
                      },
                    ),
                  ),
                  Checkbox(
                    value: _associationWithSite,
                    onChanged: (value) {
                      _toggleSiteAssociation();
                    },
                  ),
                  const Text('NA'),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: TypeAheadFormField<String>(
                      key: const Key('Vehicle'),
                      textFieldConfiguration: TextFieldConfiguration(
                        controller: _tnxVehicleController,
                        enabled: !_associationWithVehicle,
                        decoration: const InputDecoration(
                          hintText: 'Vehicle',
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
                          _tnxVehicleController.text = suggestion;
                        });
                      },
                      validator: (value) {
                        if (!_associationWithVehicle && (value == null || value.isEmpty)) {
                          return 'Please provide vehicle name';
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
                        _selectedVehicle = value;
                      },
                    ),
                  ),
                  Checkbox(
                    value: _associationWithVehicle,
                    onChanged: (value) {
                      _toggleVehicleAssociation();
                    },
                  ),
                  const Text('NA'),
                ],
              ),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Remarks',
                ),
                initialValue: widget.transaction.remarks,
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
            _updateTransaction();
          },
          child: const Text('Update'),
        ),
      ],
    );
  }
}
