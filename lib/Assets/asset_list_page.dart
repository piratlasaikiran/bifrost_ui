import 'package:bifrost_ui/Employees/Supervisor/supervisor_actions.dart';
import 'package:bifrost_ui/Sites/site_actions.dart';
import 'package:bifrost_ui/Vehicles/vehicle_actions.dart';
import 'package:flutter/material.dart';
import 'add_asset_location.dart';
import 'asset_actions.dart';

class AssetListPage extends StatefulWidget {
  final List<AssetDTO> assets;

  const AssetListPage({Key? key, required this.assets}) : super(key: key);

  @override
  _AssetListPageState createState() => _AssetListPageState();
}

class _AssetListPageState extends State<AssetListPage> {
  List<AssetDTO> filteredAssets = [];
  TextEditingController assetNameController = TextEditingController();
  TextEditingController assetTypeController = TextEditingController();
  TextEditingController locationController = TextEditingController();
  DateTime? startDate;
  DateTime? endDate;

  @override
  void initState() {
    super.initState();
    filteredAssets = widget.assets;
  }

  @override
  void dispose() {
    assetNameController.dispose();
    assetTypeController.dispose();
    locationController.dispose();
    super.dispose();
  }

  void applyFilters() {
    setState(() {
      final filterAssetName = assetNameController.text.toLowerCase();
      final filterAssetType = assetTypeController.text.toLowerCase();
      final filterLocation = locationController.text.toLowerCase();

      filteredAssets = widget.assets.where((asset) {
        final assetName = asset.assetName.toLowerCase();
        final assetType = asset.assetType.toLowerCase();
        final location = asset.location.toLowerCase();

        final isStartDateValid = startDate == null || asset.startDate!.isAfter(startDate!);
        final isEndDateValid = endDate == null || asset.endDate!.isBefore(endDate!);

        return assetName.contains(filterAssetName) &&
            assetType.contains(filterAssetType) &&
            location.contains(filterLocation) &&
            isStartDateValid &&
            isEndDateValid;
      }).toList();
    });
  }

  Future<void> showAddAssetLocationPopup() async {
    VehicleActions vehicleActions = VehicleActions();
    SupervisorActions supervisorActions = SupervisorActions();
    SiteActions siteActions = SiteActions();

    List<String> vehicleList = await vehicleActions.getVehicleNumbers();
    List<String> supervisorList = await supervisorActions.getSupervisorNames();
    List<String> locationList = await siteActions.getSiteNames();
    Future.microtask(() {
      showDialog(
        context: context,
        builder: (BuildContext context) =>
          AddAssetLocationPopup(
            vehicleList: vehicleList,
            supervisorList: supervisorList,
            locationList: locationList,
            onAdd: (assetType, assetName, location, startDate, endDate) async {
              AssetActions assetActions = AssetActions();
              final result = await assetActions.saveAssetLocation(
                  assetType: assetType,
                  assetName: assetName,
                  location: location,
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
                        content: const Text('AssetLocation saved successfully.'),
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
                        content: const Text('Failed to save AssetLocation.'),
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
      locationController.clear();
      startDate = null;
      endDate = null;
      filteredAssets = widget.assets;
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
              if (value == 'add_asset') {
                showAddAssetLocationPopup();
              } else if (value == 'reset_filters') {
                resetFilters();
              }
            },
            itemBuilder: (context) {
              return [
                const PopupMenuItem<String>(
                  value: 'add_asset',
                  child: Text('Add Asset Location'),
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
                    controller: locationController,
                    onChanged: (_) => applyFilters(),
                    decoration: const InputDecoration(labelText: 'Location'),
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
                  child: ElevatedButton(
                    onPressed: () async {
                      final pickedStartDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(1900),
                        lastDate: DateTime(2100),
                      );

                      if (pickedStartDate != null) {
                        setState(() {
                          startDate = pickedStartDate;
                          applyFilters();
                        });
                      }
                    },
                    child: Text(startDate != null ? 'Start: ${startDate!.toString().split(' ')[0]}' : 'Select Start Date'),
                  ),
                ),
                const SizedBox(width: 8.0),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      final pickedEndDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(1900),
                        lastDate: DateTime(2100),
                      );

                      if (pickedEndDate != null) {
                        setState(() {
                          endDate = pickedEndDate;
                          applyFilters();
                        });
                      }
                    },
                    child: Text(endDate != null ? 'End: ${endDate!.toString().split(' ')[0]}' : 'Select End Date'),
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
                      subtitle: Text('${asset.assetType}   ${asset.location}'),
                      trailing: PopupMenuButton<String>(
                        onSelected: (value) {
                          if (value == 'view_edit') {
                            // Handle View and Edit action
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
