import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AddAssetOwnershipPopup extends StatefulWidget {
  final List<String> vehicleList;
  final List<String> ownerList;
  final Function(String, String, String, DateTime, DateTime?) onAdd;

  const AddAssetOwnershipPopup({
    Key? key,
    required this.vehicleList,
    required this.ownerList,
    required this.onAdd,
  }) : super(key: key);

  @override
  _AddAssetOwnershipPopup createState() => _AddAssetOwnershipPopup();
}

class _AddAssetOwnershipPopup extends State<AddAssetOwnershipPopup> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String? selectedAssetType;
  String? selectedAssetName;
  String? selectedCurrentOwner;
  DateTime? selectedStartDate;
  DateTime? selectedEndDate;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Asset Location'),
      content: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              value: selectedAssetType,
              onChanged: (value) {
                setState(() {
                  selectedAssetType = value;
                  selectedAssetName = null;
                });
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please select an asset type';
                }
                return null;
              },
              items: const [
                DropdownMenuItem<String>(
                  value: 'VEHICLE',
                  child: Text('Vehicle'),
                ),
              ],
              decoration: const InputDecoration(
                labelText: 'Asset Type',
              ),
            ),
            if (selectedAssetType == 'VEHICLE')
              DropdownButtonFormField<String>(
                value: selectedAssetName,
                onChanged: (value) {
                  setState(() {
                    selectedAssetName = value;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select an asset name';
                  }
                  return null;
                },
                items: widget.vehicleList.map((vehicle) {
                  return DropdownMenuItem<String>(
                    value: vehicle,
                    child: Text(vehicle),
                  );
                }).toList(),
                decoration: const InputDecoration(
                  labelText: 'Asset Name',
                ),
              ),
            DropdownButtonFormField<String>(
              value: selectedCurrentOwner,
              onChanged: (value) {
                setState(() {
                  selectedCurrentOwner = value;
                });
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please select an owner for asset';
                }
                return null;
              },
              items: widget.ownerList.map((location) {
                return DropdownMenuItem<String>(
                  value: location,
                  child: Text(location),
                );
              }).toList(),
              decoration: const InputDecoration(
                labelText: 'Current Owner',
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              readOnly: true,
              onTap: () async {
                final pickedStartDate = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(1900),
                  lastDate: DateTime(2100),
                );
                if (pickedStartDate != null) {
                  setState(() {
                    selectedStartDate = pickedStartDate;
                  });
                }
              },
              validator: (value) {
                if (selectedStartDate == null) {
                  return 'Please select a start date';
                }
                return null;
              },
              decoration: const InputDecoration(
                labelText: 'Start Date',
                suffixIcon: Icon(Icons.calendar_today),
              ),
              controller: TextEditingController(
                text: selectedStartDate != null
                    ? selectedStartDate!.toString().split(' ')[0]
                    : '',
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              readOnly: true,
              onTap: () async {
                final pickedEndDate = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(1900),
                  lastDate: DateTime(2100),
                );

                if (pickedEndDate != null) {
                  setState(() {
                    selectedEndDate = pickedEndDate;
                  });
                }
              },
              decoration: const InputDecoration(
                labelText: 'End Date',
                suffixIcon: Icon(Icons.calendar_today),
              ),
              controller: TextEditingController(
                text: selectedEndDate != null
                    ? selectedEndDate!.toString().split(' ')[0]
                    : '',
              ),
            ),
            const SizedBox(height: 24),
            Align(
              alignment: Alignment.bottomRight,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        widget.onAdd(
                          selectedAssetType!,
                          selectedAssetName!,
                          selectedCurrentOwner!,
                          selectedStartDate!,
                          selectedEndDate,
                        );

                        Navigator.of(context).pop();
                      }
                    },
                    child: const Text('Add'),
                  ),
                  const SizedBox(width: 16),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('Cancel'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}