import 'package:bifrost_ui/Vehicles/vehicle_actions.dart';
import 'package:bifrost_ui/Vehicles/vehicle_tax_list_page.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'add_vehicle_dialog.dart';

class LatestVehicleTaxesListPage extends StatefulWidget {
  final Map<String, List<VehicleTaxDTO>> vehicleTaxesLatest;

  const LatestVehicleTaxesListPage({Key? key, required this.vehicleTaxesLatest}) : super(key: key);

  @override
  _LatestVehicleTaxesListPageState createState() => _LatestVehicleTaxesListPageState();
}

class _LatestVehicleTaxesListPageState extends State<LatestVehicleTaxesListPage> {
  TextEditingController _filterController = TextEditingController();
  List<String> _filteredVehicleNumbers = [];

  @override
  void initState() {
    super.initState();
    _filteredVehicleNumbers = widget.vehicleTaxesLatest.keys.toList();
  }

  @override
  void dispose() {
    _filterController.dispose();
    super.dispose();
  }

  void _filterVehicleNumbers(String filter) {
    setState(() {
      if (filter.isNotEmpty) {
        _filteredVehicleNumbers = widget.vehicleTaxesLatest.keys.where((vehicleNumber) {
          return vehicleNumber.toLowerCase().contains(filter.toLowerCase());
        }).toList();
      } else {
        _filteredVehicleNumbers = widget.vehicleTaxesLatest.keys.toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Latest Vehicle Taxes'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _filterController,
              onChanged: _filterVehicleNumbers,
              decoration: const InputDecoration(
                labelText: 'Vehicle Number',
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Table(
                defaultColumnWidth: const IntrinsicColumnWidth(),
                children: _buildTableRows(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<TableRow> _buildTableRows() {
    final List<TableRow> rows = [];

    rows.add(
      TableRow(
        children: [
          _buildTableCell('Vehicle Number', fontWeight: FontWeight.bold, fontSize: 16.0),
          _buildTableCell('PUC', fontWeight: FontWeight.bold, fontSize: 16.0),
          _buildTableCell('FITNESS', fontWeight: FontWeight.bold, fontSize: 16.0),
          _buildTableCell('PERMIT', fontWeight: FontWeight.bold, fontSize: 16.0),
          _buildTableCell('INSURANCE', fontWeight: FontWeight.bold, fontSize: 16.0),
          _buildTableCell('TAX', fontWeight: FontWeight.bold, fontSize: 16.0),
          _buildTableCell('OTHERS', fontWeight: FontWeight.bold, fontSize: 16.0),
          const TableCell(child: SizedBox()),
        ],
      ),
    );

    rows.add(
      getEmptyRowForDivider(),
    );

    _filteredVehicleNumbers.asMap().forEach((index, vehicleNumber) {
      final List<Widget> cells = [
        _buildTableCell(vehicleNumber, fontWeight: FontWeight.bold, fontSize: 16.0),
      ];

      for (final taxType in ['PUC', 'FITNESS', 'PERMIT', 'INSURANCE', 'TAX', 'OTHERS']) {
        final taxes = widget.vehicleTaxesLatest[vehicleNumber] ?? [];
        final matchingTax = taxes.firstWhere(
              (tax) => tax.taxType == taxType,
          orElse: () => VehicleTaxDTO(
            vehicleNumber: vehicleNumber,
            amount: 0,
            receipt: null,
            validityStartDate: DateTime.now(),
            validityEndDate: DateTime.now(),
            taxType: null,
          ),
        );

        final formattedDate = matchingTax.taxType != null
            ? DateFormat('dd-MM-yyyy').format(matchingTax.validityEndDate)
            : 'Not Available';

        cells.add(
          _buildTableCell(formattedDate, fontSize: 16.0),
        );
      }
      cells.add(
        PopupMenuButton(
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'upload',
              child: Text('Upload New Tax Doc'),
            ),
            const PopupMenuItem(
              value: 'view',
              child: Text('View Details'),
            ),
          ],
          onSelected: (value) {
            if (value == 'upload') {
              Future.microtask(() {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        AddVehicleTaxDialog(vehicleNumber: vehicleNumber),
                  ),
                );
              });
            } else if (value == 'view') {
              final List<VehicleTaxDTO> vehicleTaxes = widget.vehicleTaxesLatest[vehicleNumber] ?? [];
              Future.microtask(() {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        VehicleTaxListPage(vehicleTaxes: vehicleTaxes),
                  ),
                );
              });
            }
          },
        ),
      );

      rows.add(
        TableRow(
          children: cells,
        ),
      );

      if (index != _filteredVehicleNumbers.length - 1) {
        rows.add(
          getEmptyRowForDivider(),
        );
      }
    });

    return rows;
  }

  TableRow getEmptyRowForDivider() {
    return TableRow(
      children: [
        _buildDividerCell(),
        _buildDividerCell(),
        _buildDividerCell(),
        _buildDividerCell(),
        _buildDividerCell(),
        _buildDividerCell(),
        _buildDividerCell(),
        _buildDividerCell(),
      ],
    );
  }

  TableCell _buildDividerCell() {
    return const TableCell(
      child: Divider(
        color: Colors.black,
        height: 22.0,
      ),
    );
  }


  TableCell _buildTableCell(String text, {FontWeight? fontWeight, double? fontSize}) {
    return TableCell(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          text,
          style: TextStyle(
            fontWeight: fontWeight,
            fontSize: fontSize,
          ),
        ),
      ),
    );
  }
}
