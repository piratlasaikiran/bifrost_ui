import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:http_parser/http_parser.dart';

import '../../utils/user_manager.dart';

class SupervisorDTO {
  final String name;
  final int? mobileNumber;
  final String? bankAccountNumber;
  final int? salary;
  final bool? admin;
  final int? companyMobileNumber;
  final int? atmCardNumber;
  final int? otPay;


  SupervisorDTO({
    required this.name,
    required this.mobileNumber,
    required this.bankAccountNumber,
    required this.salary,
    required this.admin,
    required this.companyMobileNumber,
    required this.atmCardNumber,
    required this.otPay
  });
}

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

  Future<bool> updateSupervisor({
    required String existingSupervisor,
    required String? name,
    required String? mobileNumber,
    required String? bankAccountNumber,
    required double? salary,
    required bool? isAdmin,
    required File? aadhar,
    required String? companyMobileNumber,
    required String? atmCard,
    required double? otPay,
  }) async {
    UserManager userManager = UserManager();
    var url = Uri.parse('http://10.0.2.2:6852/bifrost/supervisors/$existingSupervisor/update-supervisor');
    var formData = {
      'name': name,
      'personal_mobile_num': mobileNumber,
      'bank_ac': bankAccountNumber,
      'salary': salary,
      'admin': isAdmin,
      'company_mob_num': companyMobileNumber,
      'atm_card': atmCard,
      'ot_pay': otPay
    };
    var jsonPart = http.MultipartFile.fromString(
      'createSupervisorPayload',
      jsonEncode(formData),
      contentType: MediaType('application', 'json'),
    );
    var request = http.MultipartRequest('PUT', url);
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

  Future<List<SupervisorDTO>> getAllSupervisors() async{
    UserManager userManager = UserManager();
    var url = Uri.parse('http://10.0.2.2:6852/bifrost/supervisors/');
    var headers = {'X-User-Id': userManager.username};
    var response = await http.get(url, headers: headers);
    List<dynamic> supervisorDTOs = jsonDecode(response.body);
    final List<SupervisorDTO> supervisors = supervisorDTOs.map((data) {
      return SupervisorDTO(
        name: data['name'] as String,
        mobileNumber: data['personal_mobile_num'] as int?,
        bankAccountNumber: data['bank_ac'] as String?,
        salary: data['salary'] as int?,
        admin: data['admin'] as bool?,
        companyMobileNumber: data['company_mob_num'] as int?,
        atmCardNumber: data['atm_card'] as int?,
        otPay: data['ot_pay'] as int?,
      );
    }).toList();
    return supervisors;
  }

  Future<List<String>> getSupervisorNames() async {
    UserManager userManager = UserManager();
    var url = Uri.parse('http://10.0.2.2:6852/bifrost/supervisors/get-supervisor-names');
    var headers = {'X-User-Id': userManager.username};
    var response = await http.get(url, headers: headers);
    List<String> supervisorNames = jsonDecode(response.body).cast<String>();
    return supervisorNames;
  }

  Future<File?> getAadhar(String supervisor) async {
    UserManager userManager = UserManager();
    var url = Uri.parse('http://10.0.2.2:6852/bifrost/supervisors/$supervisor/get-aadhar');
    var headers = {'X-User-Id': userManager.username};
    var response = await http.get(url, headers: headers);
    if (response.statusCode == 200) {
      List<int> fileBytes = response.bodyBytes;
      final tempDir = Directory.systemTemp.createTempSync();
      var tempPath = '${tempDir.path}/temp_file';
      var file = File(tempPath);
      await file.writeAsBytes(fileBytes);
      return file;
    }
    return null;
  }

  void deleteTemporaryLocation(File aadharImageLocation) {
    if (aadharImageLocation.existsSync()) {
      aadharImageLocation.deleteSync();
    }
  }
}
