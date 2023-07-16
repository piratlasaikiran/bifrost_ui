import 'dart:convert';

import '../Utils/formatting_util.dart';
import '../../utils/user_manager.dart';
import 'package:http/http.dart' as http;

class AssetLocationDTO {
  final int assetLocationId;
  final String assetType;
  final String assetName;
  final String location;
  final String startDate;
  final String? endDate;

  AssetLocationDTO({
    required this.assetLocationId,
    required this.assetType,
    required this.assetName,
    required this.location,
    required this.startDate,
    required this.endDate,
  });
}

class AssetOwnershipDTO {
  final int assetOwnershipId;
  final String assetType;
  final String assetName;
  final String currentOwner;
  final String startDate;
  final String? endDate;

  AssetOwnershipDTO({
    required this.assetOwnershipId,
    required this.assetType,
    required this.assetName,
    required this.currentOwner,
    required this.startDate,
    required this.endDate,
  });
}

class AssetActions{

  FormattingUtility formattingUtility = FormattingUtility();

  Future<List<AssetLocationDTO>> getAllAssetLocations() async {
    UserManager userManager = UserManager();
    var url = Uri.parse('http://10.0.2.2:6852/bifrost/asset-management/asset-locations');
    var headers = {'X-User-Id': userManager.username};
    var response = await http.get(url, headers: headers);
    List<dynamic> assetLocationDTOs = jsonDecode(response.body);
    final List<AssetLocationDTO> assetLocations = assetLocationDTOs.map((data) {
      return AssetLocationDTO(
        assetLocationId: data['asset_location_id'] as int,
        assetName: data['asset_name'] as String,
        assetType: data['asset_type'] as String,
        location: data['location'] as String,
        startDate: formattingUtility.getDateStringFromLocalDate(data['start_date']),
        endDate: data['end_date'] != null ? formattingUtility.getDateStringFromLocalDate(data['end_date']) : '',
      );
    }).toList();
    return assetLocations;
  }

  Future<List<AssetOwnershipDTO>> getAllAssetOwnerships() async {
    UserManager userManager = UserManager();
    var url = Uri.parse('http://10.0.2.2:6852/bifrost/asset-management/asset-ownerships');
    var headers = {'X-User-Id': userManager.username};
    var response = await http.get(url, headers: headers);
    List<dynamic> assetOwnershipDTOs = jsonDecode(response.body);
    final List<AssetOwnershipDTO> assetOwnerships = assetOwnershipDTOs.map((data) {
      return AssetOwnershipDTO(
        assetOwnershipId: data['asset_ownership_id'] as int,
        assetName: data['asset_name'] as String,
        assetType: data['asset_type'] as String,
        currentOwner: data['cur_owner'] as String,
        startDate: formattingUtility.getDateStringFromLocalDate(data['start_date']),
        endDate: data['end_date'] != null ? formattingUtility.getDateStringFromLocalDate(data['end_date']) : '',
      );
    }).toList();
    return assetOwnerships;
  }

  Future<bool> saveAssetLocation({
    required String assetType,
    required String assetName,
    required String location,
    required DateTime startDate,
    required DateTime? endDate
  }) async{
    UserManager userManager = UserManager();
    var url = Uri.parse('http://10.0.2.2:6852/bifrost/asset-management/create-asset-location');
    var siteBody = {
      'asset_type': assetType,
      'asset_name': assetName,
      'location': location,
      'start_date': '${startDate.year}-${startDate.month.toString().padLeft(2, '0')}-${startDate.day.toString().padLeft(2, '0')}',
      'end_date': (endDate != null) ? '${endDate.year}-${endDate.month.toString().padLeft(2, '0')}-${endDate.day.toString().padLeft(2, '0')}' : null,
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

  Future<bool> updateAssetLocation({
    required int assetLocationId,
    required String assetType,
    required String assetName,
    required String location,
    required DateTime startDate,
    required DateTime? endDate
  }) async{
    UserManager userManager = UserManager();
    var url = Uri.parse('http://10.0.2.2:6852/bifrost/asset-management/$assetLocationId/update-asset-location');
    var siteBody = {
      'asset_location_id': assetLocationId,
      'asset_type': assetType,
      'asset_name': assetName,
      'location': location,
      'start_date': '${startDate.year}-${startDate.month.toString().padLeft(2, '0')}-${startDate.day.toString().padLeft(2, '0')}',
      'end_date': (endDate != null) ? '${endDate.year}-${endDate.month.toString().padLeft(2, '0')}-${endDate.day.toString().padLeft(2, '0')}' : null,
    };
    final headers = {
      'Content-Type': 'application/json',
      'X-User-Id': userManager.username,
    };
    final response = await http.put(
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

  Future<bool> saveAssetOwnership({
    required String assetType,
    required String assetName,
    required String currentOwner,
    required DateTime startDate,
    required DateTime? endDate
  }) async{
    UserManager userManager = UserManager();
    var url = Uri.parse('http://10.0.2.2:6852/bifrost/asset-management/create-asset-ownership');
    var siteBody = {
      'asset_type': assetType,
      'asset_name': assetName,
      'cur_owner': currentOwner,
      'start_date': '${startDate.year}-${startDate.month.toString().padLeft(2, '0')}-${startDate.day.toString().padLeft(2, '0')}',
      'end_date': (endDate != null) ? '${endDate.year}-${endDate.month.toString().padLeft(2, '0')}-${endDate.day.toString().padLeft(2, '0')}' : null,
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

  Future<bool> updateAssetOwnership({
    required int assetOwnershipId,
    required String assetType,
    required String assetName,
    required String currentOwner,
    required DateTime startDate,
    required DateTime? endDate
  }) async{
    UserManager userManager = UserManager();
    var url = Uri.parse('http://10.0.2.2:6852/bifrost/asset-management/$assetOwnershipId/update-asset-ownership');
    var siteBody = {
      'asset_ownership_id': assetOwnershipId,
      'asset_type': assetType,
      'asset_name': assetName,
      'cur_owner': currentOwner,
      'start_date': '${startDate.year}-${startDate.month.toString().padLeft(2, '0')}-${startDate.day.toString().padLeft(2, '0')}',
      'end_date': (endDate != null) ? '${endDate.year}-${endDate.month.toString().padLeft(2, '0')}-${endDate.day.toString().padLeft(2, '0')}' : null,
    };
    final headers = {
      'Content-Type': 'application/json',
      'X-User-Id': userManager.username,
    };
    final response = await http.put(
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
