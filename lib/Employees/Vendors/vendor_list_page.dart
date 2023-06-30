import 'package:bifrost_ui/Employees/Vendors/vendor_actions.dart';
import 'package:bifrost_ui/Employees/Vendors/vendor_edit_page.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class VendorListPage extends StatefulWidget {
  final List<VendorDTO> vendors;

  const VendorListPage({Key? key, required this.vendors}) : super(key: key);

  @override
  _VendorListPage createState() => _VendorListPage();
}

class _VendorListPage extends State<VendorListPage> {
  List <VendorDTO> filteredVendors = [];

  TextEditingController vendorNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    filteredVendors = widget.vendors;
  }

  @override
  void dispose() {
    vendorNameController.dispose();
    super.dispose();
  }

  void applyFilters() {
    setState(() {
      final filterVendorName = vendorNameController.text.toLowerCase();

      filteredVendors = widget.vendors.where((vendor) {
        final vendorId = vendor.vendorId.toLowerCase();

        return vendorId.contains(filterVendorName);
      }).toList();
    });
  }

  void _makePhoneCall(String phoneNumber) async {
    Uri url = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      throw 'Could not make phone call';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vendors'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(right: 20.0),
                        child: TextField(
                          controller: vendorNameController,
                          onChanged: (_) => applyFilters(),
                          decoration: const InputDecoration(labelText: 'Vendor Name'),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
                itemCount: filteredVendors.length,
                itemBuilder: (context, index) {
                  final vendor = filteredVendors[index];
                  return Column(
                      children: [
                        ListTile(
                          title: Text(
                            vendor.vendorId ?? '',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                          ),
                          subtitle: Text('Mob: ${vendor.mobileNumber ?? ''}'),
                          trailing: PopupMenuButton<String>(
                            itemBuilder: (context) {
                              return [
                                const PopupMenuItem(
                                  value: 'call',
                                  child: Text('Call'),
                                ),
                                const PopupMenuItem(
                                  value: 'view_edit',
                                  child: Text('View & Edit'),
                                ),
                                const PopupMenuItem(
                                  value: 'commodity_prices',
                                  child: Text('Commodity Prices'),
                                ),
                              ];
                            },
                            onSelected: (value) {
                              if (value == 'view_edit') {
                                Future.microtask(() {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          VendorEditDialog(vendor: vendor),
                                    ),
                                  );
                                });
                              } else if(value == 'call'){
                                String phoneNumber = vendor.mobileNumber.toString() ?? '';
                                _makePhoneCall(phoneNumber);
                              } else if (value == 'commodity_prices') {
                                // Perform action for View & Edit
                              }
                            },
                          ),
                        ),
                      ]
                  );
                }
            ),
          ),
        ],
      ),
    );
  }
}
