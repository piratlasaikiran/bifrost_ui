import 'package:bifrost_ui/Sites/site_actions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';

import '../../BankAccounts/bank_account_actions.dart';
import '../../Employees/Vendors/vendor_actions.dart';

class VendorAttendanceInputDialog extends StatefulWidget {
  const VendorAttendanceInputDialog({Key? key}) : super(key: key);

  @override
  _VendorAttendanceInputDialogState createState() =>
      _VendorAttendanceInputDialogState();
}

class _VendorAttendanceInputDialogState
    extends State<VendorAttendanceInputDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  VendorActions vendorActions = VendorActions();

  bool makeTransaction = false;
  bool showBankAccountName = false;
  String? _selectedVendorId;
  String? _selectedSite;
  String? _selectedBankAccount;
  DateTime? attendanceDate;

  final _vendorIdController = TextEditingController();
  final _siteController = TextEditingController();

  List<String> availableVendors = [];
  List<String> availableSites = [];
  List<String> availableBankAccounts = [];
  Map<String, double> commodityAttendance = {};

  @override
  void initState() {
    super.initState();
    _fetchVendors();
    _fetchSites();
    _fetchBankAccounts();
  }

  void _fetchVendors() async {
    final vendors = await vendorActions.getVendorIds();
    setState(() {
      availableVendors = vendors;
    });
  }

  void _fetchSites() async {
    SiteActions siteActions = SiteActions();
    final sites = await siteActions.getSiteNames();
    setState(() {
      availableSites = sites;
    });
  }

  void _fetchBankAccounts() async {
    BankAccountActions bankAccountActions = BankAccountActions();
    final accountNames = await bankAccountActions.getAccountNickNames();
    setState(() {
      availableBankAccounts = accountNames;
      availableBankAccounts.add("My Account");
    });
  }

  Future<void> _selectAttendanceDate() async {
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
        attendanceDate = pickedDate;
      });
    }
  }

  Future<void> _saveAttendance() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Vendor Attendance'),
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
                    const Text('Vendor ID'),
                    const SizedBox(width: 15),
                    Expanded(
                      child: TypeAheadFormField<String>(
                        key: const Key('Vendor ID'),
                        textFieldConfiguration: TextFieldConfiguration(
                          controller: _vendorIdController,
                          decoration: const InputDecoration(
                            hintText: 'Vendor ID',
                            hintStyle: TextStyle(fontSize: 14),
                            prefixIcon: Icon(Icons.search),
                          ),
                        ),
                        suggestionsCallback: (String pattern) {
                          if (pattern.isEmpty) {
                            return availableVendors;
                          } else {
                            final filteredList = availableVendors
                                .where((vendor) => vendor.toLowerCase().contains(pattern.toLowerCase()))
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
                            _selectedVendorId = suggestion;
                            _vendorIdController.text = suggestion;
                          });
                        },
                        validator: (String? value) {
                          if (value == null || value.isEmpty) {
                            return 'Please Select Vendor';
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
                          _selectedVendorId = value;
                        },
                      ),
                    )
                  ],
                ),
              ),
              if(_selectedVendorId != null)
                ElevatedButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (_) => CommodityAttendanceDialog(
                        vendorId: _selectedVendorId!,
                        onValuesChanged: (values) {
                          setState(() {
                            commodityAttendance = values;
                          });
                        },
                        initialValues: commodityAttendance.isNotEmpty ? Map<String, double>.from(commodityAttendance) : null,
                      ),
                    );
                  },
                  child: const Text('Commodity Attendance'),
                ),
                if (commodityAttendance.isNotEmpty)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16.0),
                      const Text(
                        'Commodity Attendance:',
                        style: TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8.0),
                      Wrap(
                        spacing: 4.0,
                        runSpacing: 4.0,
                        children: [
                          for (int i = 0; i < commodityAttendance.length; i += 2)
                            Row(
                              children: [
                                if (i < commodityAttendance.length)
                                  Chip(
                                    label: Text(
                                      '${commodityAttendance.entries.elementAt(i).key}: ${commodityAttendance.entries.elementAt(i).value.toStringAsFixed(2)}',
                                      style: const TextStyle(fontSize: 8.0),
                                    ),
                                  ),
                                if (i + 1 < commodityAttendance.length)
                                  Chip(
                                    label: Text(
                                      '${commodityAttendance.entries.elementAt(i + 1).key}: ${commodityAttendance.entries.elementAt(i + 1).value.toStringAsFixed(2)}',
                                      style: const TextStyle(fontSize: 8.0),
                                    ),
                                  ),
                              ],
                            ),
                        ],
                      ),
                    ],
                  ),
              Container(
                margin: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  children: [
                    const Text('Site'),
                    const SizedBox(width: 15),
                    Expanded(
                      child: TypeAheadFormField<String>(
                        key: const Key('Site'),
                        textFieldConfiguration: TextFieldConfiguration(
                          controller: _siteController,
                          decoration: const InputDecoration(
                            hintText: 'Site',
                            hintStyle: TextStyle(fontSize: 14),
                            prefixIcon: Icon(Icons.search),
                          ),
                        ),
                        suggestionsCallback: (String pattern) {
                          if (pattern.isEmpty) {
                            return availableSites;
                          } else {
                            final filteredList = availableSites
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
                            _siteController.text = suggestion;
                          });
                        },
                        validator: (String? value) {
                          if (value == null || value.isEmpty) {
                            return 'Please Select Site';
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
                    )
                  ],
                ),
              ),
              Row(
                children: [
                  const Text('Make Transaction:'),
                  Switch(
                    value: makeTransaction,
                    onChanged: (value) {
                      setState(() {
                        makeTransaction = value;
                        showBankAccountName = value;
                      });
                    },
                  ),
                ],
              ),
              if (showBankAccountName)
                DropdownButtonFormField<String>(
                  value: _selectedBankAccount,
                  onChanged: (value) {
                    setState(() {
                      _selectedBankAccount = value;
                    });
                  },
                  items: availableBankAccounts.map((purpose) {
                    return DropdownMenuItem<String>(
                      value: purpose,
                      child: Text(purpose),
                    );
                  }).toList(),
                  decoration: const InputDecoration(labelText: 'Bank Account'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select a bank account';
                    }
                    return null;
                  },
                ),
              const SizedBox(height: 8.0),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Attendance Date',
                      ),
                      onTap: _selectAttendanceDate,
                      readOnly: true,
                      validator: (value) {
                        if (attendanceDate == null) {
                          return 'Please select transaction date';
                        }
                        return null;
                      },
                      controller: TextEditingController(
                        text: attendanceDate != null ? attendanceDate.toString() : '',
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: _selectAttendanceDate,
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
            Navigator.of(context).pop(); // Close the dialog
          },
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            _saveAttendance();
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}

class CommodityAttendanceDialog extends StatefulWidget {
  final String vendorId;
  final void Function(Map<String, double>) onValuesChanged;
  final Map<String, double>? initialValues;

  const CommodityAttendanceDialog({Key? key, required this.vendorId, required this.onValuesChanged, this.initialValues}) : super(key: key);

  @override
  _CommodityAttendanceDialogState createState() => _CommodityAttendanceDialogState();
}

class _CommodityAttendanceDialogState extends State<CommodityAttendanceDialog> {
  Map<String, String> _commodityAttendanceUnits = {};
  VendorActions vendorActions = VendorActions();

  Map<String, TextEditingController> _textEditingControllers = {};

  @override
  void initState() {
    super.initState();
    if (widget.initialValues != null) {
      _commodityAttendanceUnits = widget.initialValues!
          .map((key, value) => MapEntry(key, value.toString()));
      _textEditingControllers = widget.initialValues!.map((key, value) {
        final controller = TextEditingController(text: value.toString());
        controller.addListener(() {
          setState(() {
            _commodityAttendanceUnits[key] = controller.text;
          });
        });
        return MapEntry(key, controller);
      });
    }else {
      _fetchCommodityBaseCount(widget.vendorId);
    }
  }

  void _fetchCommodityBaseCount(String vendorId) async {
    final commodityBaseUnits = await vendorActions.getCommodityAttendanceUnits(vendorId);
    setState(() {
      _commodityAttendanceUnits = commodityBaseUnits;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Commodity Attendance'),
      content: SingleChildScrollView(
        child: Column(
          children: [
            for (final entry in _commodityAttendanceUnits.entries)
              TextFormField(
                controller: _textEditingControllers[entry.key],
                decoration: InputDecoration(labelText: entry.key),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  setState(() {
                    _commodityAttendanceUnits[entry.key] = value;
                  });
                },
              ),
          ],
        ),
      ),
      actions: [
        ElevatedButton(
          onPressed: () {
            final commodityAttendance = <String, double>{};
            for (final entry in _commodityAttendanceUnits.entries) {
              final fieldValue = double.tryParse(entry.value) ?? 0.0;
              commodityAttendance[entry.key] = fieldValue;
            }
            widget.onValuesChanged(commodityAttendance);
            Navigator.pop(context);
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}
