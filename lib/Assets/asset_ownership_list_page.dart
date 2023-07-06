import 'package:bifrost_ui/Employees/Supervisor/supervisor_actions.dart';
import 'package:bifrost_ui/Sites/site_actions.dart';
import 'package:bifrost_ui/Vehicles/vehicle_actions.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../Employees/Driver/driver_actions.dart';
import '../Utils/formatting_util.dart';
import 'add_asset_ownership.dart';
import 'asset_actions.dart';
import 'asset_location_edit_dialog.dart';
import 'asset_ownership_edit_dialog.dart';

class AssetOwnershipListPage extends StatefulWidget {
  final List<AssetOwnershipDTO> assetOwnerships;

  const AssetOwnershipListPage({Key? key, required this.assetOwnerships}) : super(key: key);

  @override
  _AssetOwnershipListPage createState() => _AssetOwnershipListPage();
}

class _AssetOwnershipListPage extends State<AssetOwnershipListPage> {

  FormattingUtility formattingUtility = FormattingUtility();
  VehicleActions vehicleActions = VehicleActions();
  SupervisorActions supervisorActions = SupervisorActions();
  DriverActions driverActions = DriverActions();

  List<AssetOwnershipDTO> filteredAssets = [];
  TextEditingController assetNameController = TextEditingController();
  TextEditingController assetTypeController = TextEditingController();
  TextEditingController ownerNameController = TextEditingController();
  DateTime? startDate;
  DateTime? endDate;

  List<String> vehicleList = [];
  List<String> ownerList = [];

  @override
  void initState() {
    super.initState();
    filteredAssets = widget.assetOwnerships;
    _fetchVehicles();
    _fetchOwners();
  }

  Future<void> _fetchVehicles() async {
    final vehicles = await vehicleActions.getVehicleNumbers();
    setState(() {
      vehicleList = vehicles;
    });
  }

  Future<void> _fetchOwners() async {
    final supervisors = await supervisorActions.getSupervisorNames();
    final drivers = await driverActions.getDriverNames();
    setState(() {
      ownerList = supervisors;
      ownerList.addAll(drivers);
    });
  }

  @override
  void dispose() {
    assetNameController.dispose();
    assetTypeController.dispose();
    ownerNameController.dispose();
    super.dispose();
  }

  void applyFilters() {
    setState(() {
      final filterAssetName = assetNameController.text.toLowerCase();
      final filterAssetType = assetTypeController.text.toLowerCase();
      final filterOwnerName = ownerNameController.text.toLowerCase();

      filteredAssets = widget.assetOwnerships.where((asset) {
        final assetName = asset.assetName.toLowerCase();
        final assetType = asset.assetType.toLowerCase();
        final ownerName = asset.currentOwner.toLowerCase();

        final isStartDateValid = startDate == null || formattingUtility.getDateInDateTimeFormat(asset.startDate).isAfter(startDate!);
        final isEndDateValid = endDate == null || formattingUtility.getDateInDateTimeFormat(asset.endDate!).isBefore(endDate!);

        return assetName.contains(filterAssetName) &&
            assetType.contains(filterAssetType) &&
            ownerName.contains(filterOwnerName) &&
            isStartDateValid &&
            isEndDateValid;
      }).toList();
    });
  }

  Future<void> editAssetOwnershipPopup(AssetOwnershipDTO asset) async {
    Future.microtask(() {
      showDialog(
        context: context,
        builder: (BuildContext context) =>
            AssetOwnershipEditDialog(
              vehicleList: vehicleList,
              ownerList: ownerList,
              asset: asset,
              onAdd: (assetType, assetName, currentOwner, startDate, endDate) async {
                AssetActions assetActions = AssetActions();
                final result = await assetActions.updateAssetOwnership(
                    assetOwnershipId: asset.assetOwnershipId,
                    assetType: assetType,
                    assetName: assetName,
                    currentOwner: currentOwner,
                    startDate: startDate,
                    endDate: endDate);
                if (result) {
                  // Show success popup
                  Future.microtask(() {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text('Success'),
                          content: const Text('AssetOwnership edited successfully.'),
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
                } else {
                  Future.microtask(() {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text('Failure'),
                          content: const Text('Failed to edit AssetOwnership.'),
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
              },
            ),
      );
    });
  }

  Future<void> showAddAssetOwnershipPopup() async {
    Future.microtask(() {
      showDialog(
        context: context,
        builder: (BuildContext context) =>
            AddAssetOwnershipPopup(
              vehicleList: vehicleList,
              ownerList: ownerList,
              onAdd: (assetType, assetName, currentOwner, startDate, endDate) async {
                AssetActions assetActions = AssetActions();
                final result = await assetActions.saveAssetOwnership(
                    assetType: assetType,
                    assetName: assetName,
                    currentOwner: currentOwner,
                    startDate: startDate,
                    endDate: endDate);
                if (result) {
                  // Show success popup
                  Future.microtask(() {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text('Success'),
                          content: const Text('AssetOwnership saved successfully.'),
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
                } else {
                  Future.microtask(() {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text('Failure'),
                          content: const Text('Failed to save AssetOwnership.'),
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
              },
            ),
      );
    });
  }

  void resetFilters() {
    setState(() {
      assetNameController.clear();
      assetTypeController.clear();
      ownerNameController.clear();
      startDate = null;
      endDate = null;
      filteredAssets = widget.assetOwnerships;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Asset List'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'add_asset_ownership') {
                showAddAssetOwnershipPopup();
              } else if (value == 'reset_filters') {
                resetFilters();
              }
            },
            itemBuilder: (context) {
              return [
                const PopupMenuItem<String>(
                  value: 'add_asset_ownership',
                  child: Text('Add Asset Ownership'),
                ),
                const PopupMenuItem<String>(
                  value: 'reset_filters',
                  child: Text('Reset Filters'),
                ),
              ];
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: assetNameController,
                    onChanged: (_) => applyFilters(),
                    decoration: const InputDecoration(labelText: 'Asset Name'),
                  ),
                ),
                const SizedBox(width: 8.0),
                Expanded(
                  child: TextField(
                    controller: assetTypeController,
                    onChanged: (_) => applyFilters(),
                    decoration: const InputDecoration(labelText: 'Asset Type'),
                  ),
                ),
                const SizedBox(width: 8.0),
                Expanded(
                  child: TextField(
                    controller: ownerNameController,
                    onChanged: (_) => applyFilters(),
                    decoration: const InputDecoration(labelText: 'Owner Name'),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () async {
                      final DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: startDate ?? DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (pickedDate != null) {
                        setState(() {
                          startDate = pickedDate;
                          applyFilters();
                        });
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(right: 20.0),
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Start Date',
                          suffixIcon: Icon(Icons.calendar_today),
                        ),
                        child: Text(
                          startDate != null
                              ? DateFormat('yyyy-MM-dd').format(startDate!)
                              : '',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8.0),
                Expanded(
                  child: InkWell(
                    onTap: () async {
                      final DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: endDate ?? DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (pickedDate != null) {
                        setState(() {
                          endDate = pickedDate;
                          applyFilters();
                        });
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(right: 20.0),
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'End Date',
                          suffixIcon: Icon(Icons.calendar_today),
                        ),
                        child: Text(
                          endDate != null
                              ? DateFormat('yyyy-MM-dd').format(endDate!)
                              : '',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredAssets.length,
              itemBuilder: (context, index) {
                final asset = filteredAssets[index];
                return Column(
                  children: [
                    ListTile(
                      title: Text(asset.assetName),
                      subtitle: Text('${asset.assetType}   ${asset.currentOwner}'),
                      trailing: PopupMenuButton<String>(
                        onSelected: (value) {
                          if (value == 'view_edit') {
                            Future.microtask(() {
                              editAssetOwnershipPopup(asset);
                            });
                          }
                        },
                        itemBuilder: (context) {
                          return [
                            const PopupMenuItem<String>(
                              value: 'view_edit',
                              child: Text('View and Edit'),
                            ),
                          ];
                        },
                      ),
                    ),
                    const Divider(color: Colors.grey),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
