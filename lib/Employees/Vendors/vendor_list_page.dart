import 'package:bifrost_ui/Employees/Vendors/vendor_actions.dart';
import 'package:flutter/material.dart';


class VendorListPage extends StatelessWidget {
  final List<VendorDTO> vendors;

  const VendorListPage({Key? key, required this.vendors}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vendors'),
      ),
      body: ListView.separated(
        itemCount: vendors.length,
        separatorBuilder: (context, index) => Divider(color: Colors.grey[800]),
        itemBuilder: (context, index) {
          return VendorTile(vendor: vendors[index]);
        },
      ),
    );
  }
}

class VendorTile extends StatelessWidget {
  final VendorDTO vendor;

  const VendorTile({super.key, required this.vendor});


  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        vendor.vendorId ?? '',
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
      ),
      subtitle: Text('Purpose: ${vendor.purpose ?? ''}'),
      trailing: PopupMenuButton<String>(
        itemBuilder: (context) {
          return [
            const PopupMenuItem(
              value: 'call',
              child: Text('Call'),
            ),
            const PopupMenuItem(
              value: 'commodity_prices',
              child: Text('Commodity Prices'),
            ),
            const PopupMenuItem(
              value: 'view_edit',
              child: Text('View & Edit'),
            ),
          ];
        },
        onSelected: (value) {
          if (value == 'commodity_prices') {
            // Perform action for View & Edit
          } else if (value == 'view_edit') {
            // Perform action for Current Location
          } else if(value == 'call'){
            // Perform action for Call
          }
        },
      ),
    );
  }
}
