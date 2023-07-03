import 'package:bifrost_ui/Employees/Supervisor/supervisor_actions.dart';
import 'package:bifrost_ui/Sites/site_actions.dart';
import 'package:bifrost_ui/Vehicles/vehicle_actions.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../Utils/formatting_util.dart';
import 'add_asset_location.dart';
import 'asset_actions.dart';
import 'asset_edit_dialog.dart';

class AssetListPage extends StatefulWidget {
  final List<AssetDTO> assets;

  const AssetListPage({Key? key, required this.assets}) : super(key: key);

  @override
  _AssetListPageState createState() => _AssetListPageState();
}

class _AssetListPageState extends State<AssetListPage> {

  FormattingUtility formattingUtility = FormattingUtility();
  VehicleActions vehicleActions = VehicleActions();
  SupervisorActions supervisorActions = SupervisorActions();
  SiteActions siteActions = SiteActions();

  List<AssetDTO> filteredAssets = [];
  TextEditingController assetNameController = TextEditingController();
  TextEditingController assetTypeController = TextEditingController();
  TextEditingController locationController = TextEditingController();
  DateTime? startDate;
  DateTime? endDate;

  List<String> vehicleList = [];
  List<String> supervisorList = [];
  List<String> siteList = [];

  @override
  void initState() {
    super.initState();
    filteredAssets = widget.assets;
    _fetchVehicles();
    _fetchSupervisors();
    _fetchSites();
  }

  Future<void> _fetchVehicles() async {
    VehicleActions vehicleActions = VehicleActions();
    final vehicles = await vehicleActions.getVehicleNumbers();
    setState(() {
      vehicleList = vehicles;
    });
  }

  Future<void> _fetchSupervisors() async {
    SupervisorActions supervisorActions = SupervisorActions();
    final supervisors = await supervisorActions.getSupervisorNames();
    setState(() {
      supervisorList = supervisors;
    });
  }

  void _fetchSites() async {
    SiteActions siteActions = SiteActions();
    final sites = await siteActions.getSiteNames();
    setState(() {
      siteList = sites;
    });
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

        final isStartDateValid = startDate == null || formattingUtility.getDateInDateTimeFormat(asset.startDate).isAfter(startDate!);
        final isEndDateValid = endDate == null || formattingUtility.getDateInDateTimeFormat(asset.endDate!).isBefore(endDate!);

        return assetName.contains(filterAssetName) &&
            assetType.contains(filterAssetType) &&
            location.contains(filterLocation) &&
            isStartDateValid &&
            isEndDateValid;
      }).toList();
    });
  }

  Future<void> editAssetLocationPopup(AssetDTO asset) async {
    Future.microtask(() {
      showDialog(
        context: context,
        builder: (BuildContext context) =>
            AssetEditDialog(
              vehicleList: vehicleList,
              supervisorList: supervisorList,
              locationList: siteList,
              asset: asset,
              onAdd: (assetType, assetName, location, startDate, endDate) async {
                AssetActions assetActions = AssetActions();
                final result = await assetActions.updateAssetLocation(
                    assetLocationId: asset.assetLocationId,
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
                          content: const Text('AssetLocation edited successfully.'),
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
                          content: const Text('Failed to edit AssetLocation.'),
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

  Future<void> showAddAssetLocationPopup() async {
    Future.microtask(() {
      showDialog(
        context: context,
        builder: (BuildContext context) =>
          AddAssetLocationPopup(
            vehicleList: vehicleList,
            supervisorList: supervisorList,
            locationList: siteList,
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
              if (value == 'add_asset_location') {
                showAddAssetLocationPopup();
              } else if (value == 'reset_filters') {
                resetFilters();
              }
            },
            itemBuilder: (context) {
              return [
                const PopupMenuItem<String>(
                  value: 'add_asset_location',
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
                          labelText: 'Start Date',
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
                      subtitle: Text('${asset.assetType}   ${asset.location}'),
                      trailing: PopupMenuButton<String>(
                        onSelected: (value) {
                          if (value == 'view_edit') {
                            Future.microtask(() {
                              editAssetLocationPopup(asset);
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
