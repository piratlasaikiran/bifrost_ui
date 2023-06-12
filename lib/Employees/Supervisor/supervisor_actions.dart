import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:http_parser/http_parser.dart';

import '../../utils/user_manager.dart';

class SupervisorActions {

  Future<bool> saveSupervisor({
    required String? name,
    required String? mobileNumber,
    required String? bankAccountNumber,
    required double? salary,
    required bool? isAdmin,
    required File? aadhar,
    required String? companyMobileNumber,
    required String? atmCard,
    required String? vehicleNumber,
    required double? otPay,
  }) async {
    UserManager userManager = UserManager();
    var url = Uri.parse('http://10.0.2.2:6852/bifrost/supervisors/create-new-supervisor');
    var formData = {
      'name': name,
      'personal_mobile_num': mobileNumber,
      'bank_ac': bankAccountNumber,
      'salary': salary,
      'admin': isAdmin,
      'company_mob_num': companyMobileNumber,
      'atm_card': atmCard,
      'vehicle_num': vehicleNumber,
      'ot_pay': otPay
    };
    var jsonPart = http.MultipartFile.fromString(
      'createSupervisorPayload',
      jsonEncode(formData),
      contentType: MediaType('application', 'json'),
    );
    var request = http.MultipartRequest('POST', url);
    request.headers['X-User-Id'] = userManager.username;
    var imageField = await http.MultipartFile.fromPath('aadhar', aadhar!.path);

    request.files.add(jsonPart);
    request.files.add(imageField);

    var response = await request.send();
    if(response.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  }

  void updateSupervisor({
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
