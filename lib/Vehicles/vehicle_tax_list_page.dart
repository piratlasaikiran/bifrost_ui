import 'package:bifrost_ui/Vehicles/vehicle_actions.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:multi_select_flutter/dialog/multi_select_dialog_field.dart';
import 'package:multi_select_flutter/util/multi_select_item.dart';
import 'package:multi_select_flutter/util/multi_select_list_type.dart';

import '../Utils/formatting_util.dart';
import 'add_vehicle_dialog.dart';
import 'edit_vehicle_tax_dialog.dart';

class VehicleTaxListPage extends StatefulWidget {
  final List<VehicleTaxDTO> vehicleTaxes;
  const VehicleTaxListPage({Key? key, required this.vehicleTaxes}) : super(key: key);

  @override
  _VehicleTaxListPage createState() => _VehicleTaxListPage();
}

class _VehicleTaxListPage extends State<VehicleTaxListPage> {

  VehicleActions vehicleActions = VehicleActions();
  FormattingUtility formattingUtility = FormattingUtility();

  List <VehicleTaxDTO> filteredVehicleTaxes = [];
  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();

  int filterAmount = 0;
  List<String> selectedTaxTypes = [];
  List<String> availableTaxTypes = [];
  DateTime? filterValidityStartDate;
  DateTime? filterValidityEndDate;

  @override
  void initState() {
    super.initState();
    filteredVehicleTaxes = widget.vehicleTaxes;
    _fetchVehicleTaxTypesList();
  }

  void _fetchVehicleTaxTypesList() async {
    final taxTypes = await vehicleActions.getVehicleTaxTypes();
    setState(() {
      availableTaxTypes = taxTypes;
    });
  }

  void applyFilters() {
    setState(() {
      filteredVehicleTaxes = widget.vehicleTaxes.where((vehicleTax) {
        final isAmountMatch = filterAmount == 0 || vehicleTax.amount == filterAmount;
        final isTaxTypeMatch = selectedTaxTypes.isEmpty ||
            selectedTaxTypes.contains(vehicleTax.taxType);
        final isTransactionStartDateMatch =
            filterValidityStartDate == null || vehicleTax.validityStartDate.isAfter(filterValidityStartDate!);
        final isTransactionEndDateMatch =
            filterValidityEndDate == null || vehicleTax.validityStartDate.isBefore(filterValidityEndDate!);

        return isAmountMatch &&
            isTaxTypeMatch &&
            isTransactionStartDateMatch &&
            isTransactionEndDateMatch;
      }).toList();
    });
  }

  void clearFilters() {
    setState(() {
      filterAmount = 0;
      selectedTaxTypes = [];
      filterValidityStartDate = null;
      filterValidityEndDate = null;
      filteredVehicleTaxes = widget.vehicleTaxes;
    });
  }

  Future<void> _selectTransactionsStartDate() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: filterValidityStartDate ?? DateTime.now(),
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
        filterValidityStartDate = pickedDate;
        _startDateController.text = DateFormat('yyyy-MM-dd').format(pickedDate);
      });
    }
  }


  Future<void> _selectTransactionsEndDate() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: filterValidityEndDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: Colors.blue,
            hintColor: Colors.blue,
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
        filterValidityEndDate = pickedDate;
      });
      _endDateController.text = DateFormat('yyyy-MM-dd').format(pickedDate);
    }
  }

  void showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Select Filters'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MultiSelectDialogField(
                  title: const Text('Tax Type'),
                  buttonText: const Text('Tax Type'),
                  items: availableTaxTypes
                      .map((taxType) => MultiSelectItem<String>(taxType, taxType))
                      .toList(),
                  listType: MultiSelectListType.CHIP,
                  initialValue: selectedTaxTypes,
                  onConfirm: (List<String> values) {
                    setState(() {
                      selectedTaxTypes = values;
                    });
                  },
                ),
                TextField(
                  decoration: const InputDecoration(labelText: 'Amount'),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    setState(() {
                      filterAmount = int.tryParse(value) ?? 0;
                    });
                  },
                ),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Start Date',
                        ),
                        onTap: _selectTransactionsStartDate,
                        readOnly: true,
                        controller: _startDateController,

                      ),
                    ),
                    IconButton(
                      onPressed: _selectTransactionsStartDate,
                      icon: const Icon(Icons.calendar_today),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'End Date',
                        ),
                        onTap: _selectTransactionsEndDate,
                        readOnly: true,
                        controller: _endDateController,
                      ),
                    ),
                    IconButton(
                      onPressed: _selectTransactionsEndDate,
                      icon: const Icon(Icons.calendar_today),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Cancel button
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                applyFilters(); // Apply button
                Navigator.of(context).pop();
              },
              child: const Text('Apply'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vehicle Taxes'),
        actions: [
          PopupMenuButton<String>(
            itemBuilder: (context) => [
              const PopupMenuItem<String>(
                value: 'select_filters',
                child: Text('Select Filters'),
              ),
              const PopupMenuItem<String>(
                value: 'reset_filters',
                child: Text('Reset Filters'),
              ),
            ],
            onSelected: (value) {
              if (value == 'select_filters') {
                showFilterDialog(); // Show filter dialog
              } else if (value == 'reset_filters') {
                clearFilters();
              }
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: filteredVehicleTaxes.length,
        itemBuilder: (context, index) {
          final vehicleTax = filteredVehicleTaxes[index];
          // Build your UI for each vehicle tax item
          return Column(
            children: [
              ListTile(
                title: Text(
                  vehicleTax.vehicleNumber,
                  style: const TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Row(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          const Icon(
                            Icons.currency_rupee_rounded,
                            size: 16.0,
                          ),
                          Text(
                            '${vehicleTax.amount}',
                            style: const TextStyle(fontSize: 14.0),
                          ),
                          const SizedBox(width: 8.0),
                          Chip(
                            label: Text(
                              vehicleTax.taxType ?? '',
                              style: const TextStyle(fontSize: 12.0),
                            ),
                            backgroundColor: Colors.blue,
                            labelStyle: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8.0),
                    const Icon(
                      Icons.calendar_month_outlined,
                      size: 18.0,
                    ),
                    const SizedBox(width: 2.0),
                    Text(
                      DateFormat('dd-MM-yyyy').format(vehicleTax.validityEndDate),
                      style: const TextStyle(
                        fontSize: 14.0,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),

                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    PopupMenuButton<String>(
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'view_edit',
                          child: Text('View And Edit'),
                        ),
                        const PopupMenuItem(
                          value: 'upload_new',
                          child: Text('Upload New'),
                        ),
                      ],
                      onSelected: (value) {
                        if (value == 'view_edit') {
                          Future.microtask(() {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    VehicleTaxEditDialog(vehicleTaxDTO: vehicleTax),
                              ),
                            );
                          });
                        }else if (value == 'upload_new') {
                          Future.microtask(() {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    AddVehicleTaxDialog(vehicleNumber: vehicleTax.vehicleNumber, taxType: vehicleTax.taxType,),
                              ),
                            );
                          });
                        }
                      },
                    ),
                  ],
                ),
              ),
              const Divider(
                color: Colors.grey,
                thickness: 1.0,
              ),
            ],
          );
        },
      ),
    );
  }
}
