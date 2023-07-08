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
        final vendorName = vendor.name.toLowerCase();
        return (vendorId.contains(filterVendorName) || vendorName.contains(filterVendorName));
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

  void _showCommodityPricesDialog(VendorDTO vendor) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Commodity Prices'),
          content: SingleChildScrollView(
            child: ListBody(
              children: vendor.commodityCosts.entries.map((entry) {
                return Text('${entry.key}: ${entry.value}');
              }).toList(),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
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
                            vendor.name ?? '',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('ID: ${vendor.vendorId ?? ''}'),
                              Text('Site: ${vendor.location ?? ''}'),
                              const SizedBox(height: 6.0),
                              Wrap(
                                spacing: 8.0,
                                runSpacing: 4.0,
                                children: vendor.purposes.map((purpose) {
                                  return Chip(label: Text(purpose));
                                }).toList(),
                              ),
                            ],
                          ),
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
                                _showCommodityPricesDialog(vendor);
                              }
                            },
                          ),
                        ),
                        const Divider(
                          color: Colors.grey,
                          thickness: 1.0,
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
