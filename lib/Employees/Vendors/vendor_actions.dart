import 'dart:convert';
import 'dart:io';
import '../../Utils/user_manager.dart';

import 'package:http/http.dart' as http;


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
    required String? location,
    required String? purpose,
    required File? contractDoc,
    required Map<String, int> selectedCommodities,
  }) async {
    return true;
  }
}