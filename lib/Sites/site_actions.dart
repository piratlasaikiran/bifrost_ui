import 'dart:convert';

import '../Utils/user_manager.dart';

import 'package:http/http.dart' as http;

class SiteDTO{
  final String? siteName;
  final String? address;
  final String? siteStatus;
  final List<String>? supervisors;
  final List<String>? vehicles;
  final DateTime? startDate;
  final DateTime? endDate;

  SiteDTO({
    required this.siteName,
    required this.address,
    required this.siteStatus,
    required this.supervisors,
    required this.vehicles,
    required this.startDate,
    required this.endDate
});
}

class SiteActions{

  Future<bool> saveSite({
    required String siteName,
    required String address,
    required String siteStatus,
    required List<String> vehicles,
    required List<String> supervisors,
    required DateTime? startDate,
    required DateTime? endDate,
  }) async {
      UserManager userManager = UserManager();
      var url = Uri.parse('http://10.0.2.2:6852/bifrost/sites/create-new-site');
      var siteBody = {
        'site_name': siteName,
        'address': address,
        'site_status': siteStatus,
        'vehicles': vehicles,
        'supervisors': supervisors,
        'work_start_date': '${startDate?.year}-${startDate?.month.toString().padLeft(2, '0')}-${startDate?.day.toString().padLeft(2, '0')}',
        'work_end_date': '${endDate?.year}-${endDate?.month.toString().padLeft(2, '0')}-${endDate?.day.toString().padLeft(2, '0')}',
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

  Future<List<SiteDTO>> getAllSites() async {
    UserManager userManager = UserManager();
    var url = Uri.parse('http://10.0.2.2:6852/bifrost/sites/');
    var headers = {'X-User-Id': userManager.username};
    var response = await http.get(url, headers: headers);
    List<dynamic> siteDTOs = jsonDecode(response.body);
    final List<SiteDTO> sites = siteDTOs.map((data) {
      final processedStartDate = data['work_start_date'] is String
          ? DateTime.parse(data['work_start_date'] as String)
          : null;
      final processedEndDate = data['work_end_date'] is String
          ? DateTime.parse(data['work_end_date'] as String)
          : null;
      return SiteDTO(
          siteName: data['site_name'] as String?,
          address: data['address'] as String?,
          siteStatus: data['site_status'] as String?,
          supervisors: (data['supervisors'] as List<dynamic>?)?.map((supervisor) => supervisor as String).toList(),
          vehicles: (data['vehicles'] as List<dynamic>?)?.map((vehicle) => vehicle as String).toList(),
          startDate: processedStartDate,
        endDate: processedEndDate,
      );
    }).toList();
    return sites;
  }

  Future<List<String>> getSiteStatuses() async {
    UserManager userManager = UserManager();
    var url = Uri.parse('http://10.0.2.2:6852/bifrost/sites/get-statuses');
    var headers = {'X-User-Id': userManager.username};
    var response = await http.get(url, headers: headers);
    List<String> statuses = jsonDecode(response.body).cast<String>();
    return statuses;
  }

  Future<List<String>> getSiteNames() async {
    UserManager userManager = UserManager();
    var url = Uri.parse('http://10.0.2.2:6852/bifrost/sites/get-site-names');
    var headers = {'X-User-Id': userManager.username};
    var response = await http.get(url, headers: headers);
    List<String> siteNames = jsonDecode(response.body).cast<String>();
    return siteNames;
  }

}