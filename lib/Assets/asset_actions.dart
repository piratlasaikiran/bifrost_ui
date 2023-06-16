import 'dart:convert';

import '../Utils/user_manager.dart';
import 'package:http/http.dart' as http;

class AssetDTO {
  final String assetType;
  final String assetName;
  final String location;
  final DateTime? startDate;
  final DateTime? endDate;

  AssetDTO({
    required this.assetType,
    required this.assetName,
    required this.location,
    required this.startDate,
    required this.endDate,
  });
}

class AssetActions{

  Future<List<AssetDTO>> getAllAssetLocations() async {
    UserManager userManager = UserManager();
    var url = Uri.parse('http://10.0.2.2:6852/bifrost/asset-locations/');
    var headers = {'X-User-Id': userManager.username};
    var response = await http.get(url, headers: headers);
    List<dynamic> assetDTOs = jsonDecode(response.body);
    final List<AssetDTO> assets = assetDTOs.map((data) {
      final processedStartDate = data['start_date'] is String
          ? DateTime.parse(data['start_date'] as String)
          : null;
      final processedEndDate = data['end_date'] is String
          ? DateTime.parse(data['end_date'] as String)
          : null;
      return AssetDTO(
        assetName: data['asset_name'] as String,
        assetType: data['asset_type'] as String,
        location: data['location'] as String,
        startDate: processedStartDate,
        endDate: processedEndDate,
      );
    }).toList();
    return assets;
  }

  Future<bool> saveAssetLocation({
    required String assetType,
    required String assetName,
    required String location,
    required DateTime startDate,
    required DateTime? endDate
  }) async{
    UserManager userManager = UserManager();
    var url = Uri.parse('http://10.0.2.2:6852/bifrost/asset-locations/create-asset-location');
    var siteBody = {
      'asset_type': assetType,
      'asset_name': assetName,
      'location': location,
      'start_date': '${startDate.year}-${startDate.month.toString().padLeft(2, '0')}-${startDate.day.toString().padLeft(2, '0')}',
      'end_date': '${endDate?.year}-${endDate?.month.toString().padLeft(2, '0')}-${endDate?.day.toString().padLeft(2, '0')}',
    };
    final headers = {
      'Content-Type': 'application/json',
      'X-User-Id': userManager.username,
    };
    final response = await http.post(
      url,
      headers: headers,
      body: jsonEncode(siteBody),
    );
    if(response.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  }
}
