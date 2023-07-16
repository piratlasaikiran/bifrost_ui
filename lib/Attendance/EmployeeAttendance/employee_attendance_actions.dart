import 'dart:convert';

import 'package:bifrost_ui/Utils/formatting_util.dart';

import '../../utils/user_manager.dart';

import 'package:http/http.dart' as http;

class EmployeeAttendanceDTO{
  final int id;
  final String site;
  final String employeeName;
  final String employeeType;
  final String enteredBy;
  final String attendanceDate;
  final String attendanceType;
  final bool makeTransaction;
  final String? bankAccount;

  EmployeeAttendanceDTO({
    required this.id,
    required this.site,
    required this.employeeName,
    required this.employeeType,
    required this.enteredBy,
    required this.attendanceDate,
    required this.attendanceType,
    required this.makeTransaction,
    required this.bankAccount,
  });
}

class EmployeeAttendanceActions {

  FormattingUtility formattingUtility = FormattingUtility();

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

  Future<List<EmployeeAttendanceDTO>> getAllEmployeeAttendance() async{
    UserManager userManager = UserManager();
    var url = Uri.parse('http://10.0.2.2:6852/bifrost/employee-attendance/');
    var headers = {'X-User-Id': userManager.username};
    var response = await http.get(url, headers: headers);
    List<dynamic> vendorAttendanceDTOs = jsonDecode(response.body);
    final List<EmployeeAttendanceDTO> employeeAttendances = vendorAttendanceDTOs.map((data) {
      return EmployeeAttendanceDTO(
        id: data['employee_attendance_id'] as int,
        employeeName: data['employee_name'] as String,
        employeeType: data['employee_type'] as String,
        site: data['site'] as String,
        enteredBy: data['entered_by'] as String,
        attendanceDate: formattingUtility.getDateStringFromLocalDate(data['attendance_date']),
        attendanceType: data['attendance_type'] as String,
        makeTransaction: data['make_transaction'] as bool,
        bankAccount: data['bank_account'] as String?,
      );
    }).toList();
    return employeeAttendances;
  }

  Future<bool> updateAttendance({
    required int existingAttendanceId,
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
        'http://10.0.2.2:6852/bifrost/employee-attendance/$existingAttendanceId/update-attendance');
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
    final response = await http.put(
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