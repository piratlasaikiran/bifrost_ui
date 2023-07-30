import 'dart:io';
import 'package:bifrost_ui/Employees/Vendors/vendor_actions.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:multi_select_flutter/dialog/multi_select_dialog_field.dart';
import 'package:multi_select_flutter/util/multi_select_item.dart';
import 'package:multi_select_flutter/util/multi_select_list_type.dart';

import '../../Sites/site_actions.dart';

class VendorEditDialog extends StatefulWidget {
  final VendorDTO vendor;

  const VendorEditDialog({Key? key, required this.vendor}) : super(key: key);

  @override
  _VendorEditDialogState createState() => _VendorEditDialogState();
}

class _VendorEditDialogState extends State<VendorEditDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  VendorActions vendorActions = VendorActions();

  String? _firstName;
  String? _lastName;
  String? _vendorId;
  int? _mobileNumber;
  String? _selectedLocation;
  List<String> _selectedPurposes = [];
  File? _contractDocument;
  Map<String, int> _selectedCommodities = {};

  List<String> _locationList = [];
  List<String> _purposeList = [];
  Map<String, String> _commodityBaseUnitMap = {};


  @override
  void initState() {
    super.initState();
    _fetchLocationList();
    _fetchPurposeList();
    _fetchCommodityBaseUnits();
    _fetchContractDoc();
    _initialiseName();
  }

  void _fetchLocationList() async {
    SiteActions siteActions = SiteActions();
    final locations = await siteActions.getSiteNames();
    setState(() {
      _locationList = locations;
      _selectedLocation = widget.vendor.location;
    });
  }

  void _fetchPurposeList() async {
    final purposes = await vendorActions.getVendorPurposes();
    setState(() {
      _purposeList = purposes;
      _selectedPurposes = widget.vendor.purposes;
    });
  }

  void _fetchCommodityBaseUnits() async {
    final commodityBaseUnits = await vendorActions.getCommodityBaseUnits();
    setState(() {
      _commodityBaseUnitMap = commodityBaseUnits;
      _selectedCommodities = widget.vendor.commodityCosts;
    });
  }

  Future<void> _fetchContractDoc() async {
    final contractDocImage = await vendorActions.getContractDoc(widget.vendor.vendorId);
    setState(() {
      _contractDocument = contractDocImage;
    });
  }

  void _initialiseName(){
    List<String> nameParts = widget.vendor.name.split(' ');
    _firstName = nameParts.length > 1 ? nameParts.sublist(0, nameParts.length - 1).join(' ') : null;
    _lastName = nameParts.isNotEmpty ? nameParts.last : null;
  }

  Future<void> _updateVendor() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      if (_contractDocument == null) {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('ContractDoc Upload'),
              content: const Text('Please Upload Contract Document.'),
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
      final result = await vendorActions.updateVendor(
          existingVendorId: widget.vendor.vendorId,
          name: fullName,
          vendorId: _vendorId,
          mobileNumber: _mobileNumber,
          location: _selectedLocation,
          purposes: _selectedPurposes,
          contractDoc: _contractDocument,
          selectedCommodities: _selectedCommodities);
      if (result) {
        // Show success popup
        Future.microtask(() {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('Success'),
                content: const Text('Vendor updated successfully.'),
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
        vendorActions.deleteTemporaryLocation(_contractDocument!);
      } else {
        Future.microtask(() {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('Failure'),
                content: const Text('Failed to update vendor.'),
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

  void _pickContractDocument(ImageSource source) async {
    final pickedImage = await ImagePicker().pickImage(source: source);
    if (pickedImage != null) {
      setState(() {
        _contractDocument = File(pickedImage.path);
      });
    }
  }

  void _removeContractDocument() {
    setState(() {
      _contractDocument = null;
    });
  }

  Widget _buildContractDocumentWidget() {
    if (_contractDocument != null) {
      return Column(
        children: [
          Image.file(
            _contractDocument!,
            width: 100,
            height: 100,
          ),
          ElevatedButton(
            onPressed: _removeContractDocument,
            child: const Text('Remove ContractDoc'),
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
                title: const Text('Select Document'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ListTile(
                      leading: const Icon(Icons.photo_library),
                      title: const Text('Pick from Gallery'),
                      onTap: () {
                        _pickContractDocument(ImageSource.gallery);
                        Navigator.of(context).pop();
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.camera_alt),
                      title: const Text('Take a Picture'),
                      onTap: () {
                        _pickContractDocument(ImageSource.camera);
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
        child: const Text('Upload Document'),
      );
    }
  }

  void _addCommodityRate() {
    final formKey = GlobalKey<FormState>();
    final rateController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        String? selectedCommodity;
        int? rate;
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            title: const Text('Add Commodity'),
            content: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<String>(
                    value: selectedCommodity,
                    decoration: const InputDecoration(labelText: 'Commodity'),
                    items: _commodityBaseUnitMap.keys.map((String commodity) {
                      return DropdownMenuItem<String>(
                        value: commodity,
                        child: Text(commodity),
                      );
                    }).toList(),
                    onChanged: (String? value) {
                      setState(() {
                        selectedCommodity = value;
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please select a commodity';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16.0),
                  TextFormField(
                    controller: rateController,
                    decoration: InputDecoration(
                      labelText: 'Rate',
                      hintText: selectedCommodity != null ? _commodityBaseUnitMap[selectedCommodity!] : '',
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a rate';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      rate = int.tryParse(value ?? '') ?? 0;
                    },
                    onChanged: (value) {
                      if (value.isEmpty && selectedCommodity != null) {
                        rateController.text = _commodityBaseUnitMap[selectedCommodity!] ?? '';
                      }
                    },
                  ),
                ],
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
                  if (formKey.currentState!.validate()) {
                    formKey.currentState!.save();
                    if (rate != null && selectedCommodity != null) {
                      setState(() {
                        _selectedCommodities[selectedCommodity!] = rate!;
                      });
                      Navigator.of(context).pop();
                    }
                  }
                },
                child: const Text('Save'),
              ),
            ],
          );
        });
      },
    ).then((_) {
      setState(() {});
    });
  }






  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Vendor'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
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
                decoration: const InputDecoration(labelText: 'Vendor ID'),
                initialValue: widget.vendor.vendorId,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a vendor ID';
                  }
                  return null;
                },
                onSaved: (value) {
                  _vendorId = value;
                },
              ),
              const SizedBox(height: 16.0),
              DropdownButtonFormField<String>(
                value: _selectedLocation,
                decoration: const InputDecoration(labelText: 'Location'),
                items: _locationList.map((String location) {
                  return DropdownMenuItem<String>(
                    value: location,
                    child: Text(location),
                  );
                }).toList(),
                onChanged: (String? value) {
                  setState(() {
                    _selectedLocation = value;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a location';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Mobile Number',
                ),
                keyboardType: TextInputType.number,
                initialValue: widget.vendor.mobileNumber.toString(),
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
                  _mobileNumber = int.parse(value!);
                },
              ),
              const SizedBox(height: 16.0),
              MultiSelectDialogField(
                title: const Text('Vendor Purposes'),
                buttonText: const Text('Vendor Purposes'),
                items: _purposeList
                    .map((mode) => MultiSelectItem<String>(mode, mode))
                    .toList(),
                listType: MultiSelectListType.CHIP,
                initialValue: widget.vendor.purposes,
                onConfirm: (List<String> values) {
                  setState(() {
                    _selectedPurposes = values;
                  });
                },
                validator: (values) {
                  if(values!.isEmpty){
                    return 'Please select at least one purpose';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              _buildContractDocumentWidget(),

              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: _addCommodityRate,
                child: const Text('Add Commodity'),
              ),
              const SizedBox(height: 16.0),
              if (_selectedCommodities.isNotEmpty)
                Wrap(
                  spacing: 8.0,
                  runSpacing: 8.0,
                  children: _selectedCommodities.entries.map((entry) {
                    final commodity = entry.key;
                    final rate = entry.value;
                    return Chip(
                      label: Text('$commodity: $rate'),
                      deleteIcon: const Icon(Icons.clear),
                      onDeleted: () {
                        setState(() {
                          _selectedCommodities.remove(commodity);
                        });
                      },
                    );
                  }).toList(),
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
          onPressed: _updateVendor,
          child: const Text('Save'),
        ),
      ],
    );
  }
}
