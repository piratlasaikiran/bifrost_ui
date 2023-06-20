import 'dart:convert';
import 'dart:io';
import 'package:http_parser/http_parser.dart';

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

class VendorActions{
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
          commodityCosts: _convertToCommodityCosts(data['commodity_costs']),
      );
    }).toList();
    return drivers;
  }

  Map<String, int> _convertToCommodityCosts(Map<String, dynamic>? rawCommodityCosts) {
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
}