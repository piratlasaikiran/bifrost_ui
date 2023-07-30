import 'dart:convert';

import '../Utils/constants.dart';
import '../Utils/formatting_util.dart';
import '../../utils/user_manager.dart';

import 'package:http/http.dart' as http;

class SiteDTO{
  final String siteName;
  final String? address;
  final String? siteStatus;
  final List<String>? supervisors;
  final List<String>? vehicles;
  final String startDate;
  final String endDate;

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

  String backendIp = Constants().awsIpAddress;
  FormattingUtility formattingUtility = FormattingUtility();

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
      var url = Uri.parse('http://$backendIp:6852/bifrost/sites/create-new-site');
      var siteBody = {
        'site_name': siteName,
        'address': address,
        'site_status': siteStatus,
        'vehicles': vehicles,
        'supervisors': supervisors,
        'work_start_date': '${startDate?.year}-${startDate?.month.toString().padLeft(2, '0')}-${startDate?.day.toString().padLeft(2, '0')}',
        'work_end_date': (endDate != null) ? '${endDate.year}-${endDate.month.toString().padLeft(2, '0')}-${endDate.day.toString().padLeft(2, '0')}' : null,

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
    var url = Uri.parse('http://$backendIp:6852/bifrost/sites/');
    var headers = {'X-User-Id': userManager.username};
    var response = await http.get(url, headers: headers);
    List<dynamic> siteDTOs = jsonDecode(response.body);
    final List<SiteDTO> sites = siteDTOs.map((data) {
      return SiteDTO(
          siteName: data['site_name'] as String,
          address: data['address'] as String?,
          siteStatus: data['site_status'] as String?,
          supervisors: (data['supervisors'] as List<dynamic>?)?.map((supervisor) => supervisor as String).toList(),
          vehicles: (data['vehicles'] as List<dynamic>?)?.map((vehicle) => vehicle as String).toList(),
          startDate: formattingUtility.getDateStringFromLocalDate(data['work_start_date']),
        endDate: formattingUtility.getDateStringFromLocalDate(data['work_end_date']),
      );
    }).toList();
    return sites;
  }

  Future<List<String>> getSiteStatuses() async {
    UserManager userManager = UserManager();
    var url = Uri.parse('http://$backendIp:6852/bifrost/sites/get-statuses');
    var headers = {'X-User-Id': userManager.username};
    var response = await http.get(url, headers: headers);
    List<String> statuses = jsonDecode(response.body).cast<String>();
    return statuses;
  }

  Future<List<String>> getSiteNames() async {
    UserManager userManager = UserManager();
    var url = Uri.parse('http://$backendIp:6852/bifrost/sites/get-site-names');
    var headers = {'X-User-Id': userManager.username};
    var response = await http.get(url, headers: headers);
    List<String> siteNames = jsonDecode(response.body).cast<String>();
    return siteNames;
  }

  Future<bool> updateSite({
    required String initialSite,
    required String siteName,
    required String address,
    required String siteStatus,
    required List<String>? vehicles,
    required List<String>? supervisors,
    required DateTime? startDate,
    required DateTime? endDate,
  }) async {
    UserManager userManager = UserManager();
    var url = Uri.parse('http://$backendIp:6852/bifrost/sites/$initialSite/update-site');
    var siteBody = {
      'site_name': siteName,
      'address': address,
      'site_status': siteStatus,
      'vehicles': vehicles,
      'supervisors': supervisors,
      'work_start_date': '${startDate?.year}-${startDate?.month.toString().padLeft(2, '0')}-${startDate?.day.toString().padLeft(2, '0')}',
      'work_end_date': (endDate != null) ? '${endDate.year}-${endDate.month.toString().padLeft(2, '0')}-${endDate.day.toString().padLeft(2, '0')}' : null,
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
