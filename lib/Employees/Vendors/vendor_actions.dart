import 'dart:convert';
import 'dart:io';
import 'package:http_parser/http_parser.dart';

import '../../Utils/formatting_util.dart';
import '../../Utils/user_manager.dart';

import 'package:http/http.dart' as http;

class VendorDTO{
  final String? vendorId;
  final String? location;
  final int? mobileNumber;
  final String? purpose;
  final Map<String, int> commodityCosts;

  VendorDTO({
    required this.vendorId,
    required this.location,
    required this.mobileNumber,
    required this.purpose,
    required this.commodityCosts
  });
}

class VendorAttendanceDTO{
  final String site;
  final String vendorId;
  final String enteredBy;
  final String attendanceDate;
  final Map<String, int> commodityAttendance;
  final bool makeTransaction;
  final String? bankAccount;

  VendorAttendanceDTO({
    required this.site,
    required this.vendorId,
    required this.enteredBy,
    required this.attendanceDate,
    required this.commodityAttendance,
    required this.makeTransaction,
    required this.bankAccount,
  });
}

class VendorActions{

  FormattingUtility formattingUtility = FormattingUtility();

  Future<bool> saveAttendance({
    required String vendorId,
    required String site,
    required Map<String, double> commodityAttendance,
    required DateTime attendanceDate,
    required bool makeTransaction,
    required String? bankAccount,
  }) async {
    UserManager userManager = UserManager();
    var url = Uri.parse('http://10.0.2.2:6852/bifrost/vendor-attendance/enter-attendance');
    var attendanceBody = {
      'site': site,
      'vendor_id': vendorId,
      'entered_by': userManager.username,
      'attendance_date': '${attendanceDate.year}-${attendanceDate.month.toString().padLeft(2, '0')}-${attendanceDate.day.toString().padLeft(2, '0')}',
      'commodity_attendance': commodityAttendance,
      'make_transaction': makeTransaction,
      'bank_account': bankAccount
    };
    final headers = {
      'Content-Type': 'application/json',
      'X-User-Id': userManager.username,
    };
    final response = await http.post(
      url,
      headers: headers,
      body: jsonEncode(attendanceBody),
    );

    if(response.statusCode == 200) {
      return true;
    } else {
      return false;
    }
}

  Future<List<String>> getVendorPurposes() async {
    UserManager userManager = UserManager();
    var url = Uri.parse('http://10.0.2.2:6852/bifrost/vendors/get-vendor-purposes');
    var headers = {'X-User-Id': userManager.username};
    var response = await http.get(url, headers: headers);
    List<String> vendorPurposes = jsonDecode(response.body).cast<String>();
    return vendorPurposes;
  }

  Future<Map<String, String>> getCommodityBaseUnits() async {
    UserManager userManager = UserManager();
    var url = Uri.parse('http://10.0.2.2:6852/bifrost/vendors/get-commodity-unit-types');
    var headers = {'X-User-Id': userManager.username};
    var response = await http.get(url, headers: headers);
    Map<String, String> decodedData = Map<String, String>.from(jsonDecode(response.body));
    return decodedData;
  }

  Future<Map<String, String>> getCommodityAttendanceUnits(String vendorId) async {
    UserManager userManager = UserManager();
    var url = Uri.parse('http://10.0.2.2:6852/bifrost/vendors/$vendorId/get-commodity-attendance-units');
    var headers = {'X-User-Id': userManager.username};
    var response = await http.get(url, headers: headers);
    Map<String, String> decodedData = Map<String, String>.from(jsonDecode(response.body));
    return decodedData;
  }


  Future<bool> saveVendor({
    required String? vendorId,
    required int? mobileNumber,
    required String? location,
    required String? purpose,
    required File? contractDoc,
    required Map<String, int> selectedCommodities,
  }) async {
    UserManager userManager = UserManager();
    var url = Uri.parse('http://10.0.2.2:6852/bifrost/vendors/create-new-vendor');
    var formData = {
      'vendor_id': vendorId,
      'mobile_number': mobileNumber,
      'purpose': purpose,
      'location': location,
      'commodity_costs': selectedCommodities,
    };
    var jsonPart = http.MultipartFile.fromString(
      'createVendorPayLoad',
      jsonEncode(formData),
      contentType: MediaType('application', 'json'),
    );
    var request = http.MultipartRequest('POST', url);
    var imageField = await http.MultipartFile.fromPath('contractDocument', contractDoc!.path);

    request.headers['X-User-Id'] = userManager.username;
    request.files.add(jsonPart);
    request.files.add(imageField);

    var response = await request.send();
    if(response.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  }

  Future<List<VendorDTO>> getAllVendors() async{
    UserManager userManager = UserManager();
    var url = Uri.parse('http://10.0.2.2:6852/bifrost/vendors/');
    var headers = {'X-User-Id': userManager.username};
    var response = await http.get(url, headers: headers);
    List<dynamic> vendorDTOs = jsonDecode(response.body);
    final List<VendorDTO> drivers = vendorDTOs.map((data) {
      return VendorDTO(
          vendorId: data['vendor_id'] as String?,
          location: data['location'] as String?,
          mobileNumber: data['mobile_number'] as int?,
          purpose: data['purpose'] as String?,
          commodityCosts: _convertToCommodityIntegerMap(data['commodity_costs']),
      );
    }).toList();
    return drivers;
  }

  Map<String, int> _convertToCommodityIntegerMap(Map<String, dynamic>? rawCommodityCosts) {
    Map<String, int> commodityCosts = {};
    if (rawCommodityCosts != null) {
      rawCommodityCosts.forEach((key, value) {
        if (value is int) {
          commodityCosts[key] = value;
        }
      });
    }
    return commodityCosts;
  }

  Future<List<String>> getVendorIds() async {
    UserManager userManager = UserManager();
    var url = Uri.parse('http://10.0.2.2:6852/bifrost/vendors/ids');
    var headers = {'X-User-Id': userManager.username};
    var response = await http.get(url, headers: headers);
    List<String> vendorIds = jsonDecode(response.body).cast<String>();
    return vendorIds;
  }

  Future<List<VendorAttendanceDTO>> getAllVendorAttendance() async{
    UserManager userManager = UserManager();
    var url = Uri.parse('http://10.0.2.2:6852/bifrost/vendor-attendance/');
    var headers = {'X-User-Id': userManager.username};
    var response = await http.get(url, headers: headers);
    List<dynamic> vendorAttendanceDTOs = jsonDecode(response.body);
    final List<VendorAttendanceDTO> vendorAttendances = vendorAttendanceDTOs.map((data) {
      return VendorAttendanceDTO(
        vendorId: data['vendor_id'] as String,
        site: data['site'] as String,
        enteredBy: data['entered_by'] as String,
        attendanceDate: formattingUtility.getDate(data['attendance_date']),
        commodityAttendance: _convertToCommodityIntegerMap(data['commodity_attendance']),
        makeTransaction: data['make_transaction'] as bool,
        bankAccount: data['bank_account'] as String?,
      );
    }).toList();
    return vendorAttendances;
  }
}