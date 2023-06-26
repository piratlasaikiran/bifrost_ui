import 'package:bifrost_ui/Employees/Supervisor/supervisor_actions.dart';
import 'package:bifrost_ui/Employees/Vendors/vendor_actions.dart';
import 'package:flutter/material.dart';

class VendorAttendanceListPage extends StatelessWidget {
  final List<VendorAttendanceDTO> vendorAttendances;

  const VendorAttendanceListPage({Key? key, required this.vendorAttendances}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vendor Attendances'),
      ),
      body: ListView.separated(
        itemCount: vendorAttendances.length,
        separatorBuilder: (context, index) => Divider(color: Colors.grey[800]),
        itemBuilder: (context, index) {
          return VendorAttendanceTile(vendorAttendance: vendorAttendances[index]);
        },
      ),
    );
  }
}

class VendorAttendanceTile extends StatelessWidget {
  final VendorAttendanceDTO vendorAttendance;

  const VendorAttendanceTile({Key? key, required this.vendorAttendance}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        vendorAttendance.vendorId ?? '',
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
      ),
      subtitle: Text('Date: ${vendorAttendance.attendanceDate ?? ''}')
    );
  }
}
