import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:http_parser/http_parser.dart';

import '../../utils/user_manager.dart';

class DriverActions {

  Future<bool> saveDriver({
    required String? name,
    required String? mobileNumber,
    required String? bankAccountNumber,
    required double? salary,
    required bool? isAdmin,
    required File? aadhar,
    required File? license,
    required double? otPayDay,
    required double? otPayDayNight
  }) async {
    UserManager userManager = UserManager();
    var url = Uri.parse('http://10.0.2.2:6852/bifrost/drivers/create-new-driver');
    var formData = {
      'name': name,
      'personal_mobile_num': mobileNumber,
      'bank_ac': bankAccountNumber,
      'salary': salary,
      'admin': isAdmin,
      'ot_pay_day': otPayDay,
      'ot_pay_day_night': otPayDayNight
    };
    var jsonPart = http.MultipartFile.fromString(
      'createDriverPayload',
      jsonEncode(formData),
      contentType: MediaType('application', 'json'),
    );
    var request = http.MultipartRequest('POST', url);
    var aadharImageField = await http.MultipartFile.fromPath('aadhar', aadhar!.path);
    var licenseImageField = await http.MultipartFile.fromPath('license', license!.path);

    request.headers['X-User-Id'] = userManager.username;
    request.files.add(jsonPart);
    request.files.add(aadharImageField);
    request.files.add(licenseImageField);

    var response = await request.send();
    if(response.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  }

  void updateDriver({
    required String supervisorId,
    required String name,
    required String mobileNumber,
    required String bankAccountNumber,
    required double salary,
    required String aadhar,
  }) {
    // Perform update supervisor logic here
    // Use the provided parameters for updating supervisor data
    // Example: API calls, database operations, etc.
  }
}
