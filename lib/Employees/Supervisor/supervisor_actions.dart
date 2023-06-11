import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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

    var request = http.MultipartRequest('POST', url);
    // var imageField = await http.MultipartFile.fromPath('aadhar', aadhar!.path);
    request.fields['createSupervisorPayload'] = jsonEncode(formData);
    // request.files.add(imageField);

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
