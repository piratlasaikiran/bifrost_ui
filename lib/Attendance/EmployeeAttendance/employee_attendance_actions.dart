import 'dart:convert';

import '../../Utils/user_manager.dart';

import 'package:http/http.dart' as http;

class EmployeeAttendanceActions {
  Future<List<String>> getEmployeeTypes() async {
    UserManager userManager = UserManager();
    var url = Uri.parse(
        'http://10.0.2.2:6852/bifrost/employee-attendance/employee-types');
    var headers = {'X-User-Id': userManager.username};
    var response = await http.get(url, headers: headers);
    List<String> employeeTypes = jsonDecode(response.body).cast<String>();
    return employeeTypes;
  }

  Future<List<String>> getAttendanceTypes() async {
    UserManager userManager = UserManager();
    var url = Uri.parse(
        'http://10.0.2.2:6852/bifrost/employee-attendance/attendance-types');
    var headers = {'X-User-Id': userManager.username};
    var response = await http.get(url, headers: headers);
    List<String> attendanceTypes = jsonDecode(response.body).cast<String>();
    return attendanceTypes;
  }

  Future<bool> saveAttendance({
    required String employeeType,
    required String employeeName,
    required String site,
    required String attendanceType,
    required DateTime attendanceDate,
    required bool makeTransaction,
    required String? bankAccount,
  }) async {
    UserManager userManager = UserManager();
    var url = Uri.parse(
        'http://10.0.2.2:6852/bifrost/employee-attendance/enter-attendance');
    var attendanceBody = {
      'site': site,
      'employee_name': employeeName,
      'employee_type': employeeType,
      'entered_by': userManager.username,
      'attendance_date': '${attendanceDate.year}-${attendanceDate.month
          .toString().padLeft(2, '0')}-${attendanceDate.day.toString().padLeft(
          2, '0')}',
      'attendance_type': attendanceType,
      'make_transaction': makeTransaction,
      'bank_account': bankAccount
    };
    final headers = {
      'Content-Type': 'application/json',
      'X-User-Id': userManager.username,
    };
    final response = await http.post(
      url,
      headers: headers,
      body: jsonEncode(attendanceBody),
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  }
}