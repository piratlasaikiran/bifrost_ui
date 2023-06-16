import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:http_parser/http_parser.dart';

import '../../utils/user_manager.dart';

class DriverDTO {
  final String? name;
  final int? mobileNumber;
  final String? bankAccountNumber;
  final int? salary;
  final bool? admin;
  final int? otPayDay;
  final int? otPayDayNight;


  DriverDTO({
    required this.name,
    required this.mobileNumber,
    required this.bankAccountNumber,
    required this.salary,
    required this.admin,
    required this.otPayDay,
    required this.otPayDayNight
  });
}

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

  Future<List<DriverDTO>> getAllDrivers() async{
    UserManager userManager = UserManager();
    var url = Uri.parse('http://10.0.2.2:6852/bifrost/drivers/');
    var headers = {'X-User-Id': userManager.username};
    var response = await http.get(url, headers: headers);
    List<dynamic> driverDTOs = jsonDecode(response.body);
    final List<DriverDTO> drivers = driverDTOs.map((data) {
      return DriverDTO(
        name: data['name'] as String?,
        mobileNumber: data['personal_mobile_num'] as int?,
        bankAccountNumber: data['bank_ac'] as String?,
        salary: data['salary'] as int?,
        admin: data['admin'] as bool?,
        otPayDay: data['ot_pay_day'] as int?,
        otPayDayNight: data['ot_pay_day_night'] as int?
      );
    }).toList();
    return drivers;
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
