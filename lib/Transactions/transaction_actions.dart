import 'dart:convert';
import 'dart:io';
import 'package:http_parser/http_parser.dart';

import '../Utils/formatting_util.dart';
import '../Utils/user_manager.dart';
import 'package:http/http.dart' as http;

class TransactionDTO{
  final int transactionId;
  final String source;
  final String destination;
  final int amount;
  final String purpose;
  final String? remarks;
  final String transactionDate;
  final String status;
  final String mode;
  final String? bankAccount;

  TransactionDTO({
    required this.transactionId,
    required this.source,
    required this.destination,
    required this.amount,
    required this.purpose,
    required this.remarks,
    required this.transactionDate,
    required this.status,
    required this.mode,
    required this.bankAccount
  });
}


class TransactionActions{

  FormattingUtility formattingUtility = FormattingUtility();

  Future<bool> saveTransaction({
    required String? source,
    required String? destination,
    required int? amount,
    required File? bill,
    required String? purpose,
    required String? mode,
    required String? bankAccount,
    required DateTime? transactionDate,
    required String? remarks
  }) async {
    UserManager userManager = UserManager();
    var url = Uri.parse('http://10.0.2.2:6852/bifrost/transactions/create-new-transaction');
    var formData = {
      'source': source,
      'destination': destination,
      'amount': amount,
      'purpose': purpose,
      'remarks': remarks,
      'transaction_date': '${transactionDate!.year}-${transactionDate.month.toString().padLeft(2, '0')}-${transactionDate.day.toString().padLeft(2, '0')}',
      'mode': mode,
      'bank_account': bankAccount
    };
    var jsonPart = http.MultipartFile.fromString(
      'createTransactionPayload',
      jsonEncode(formData),
      contentType: MediaType('application', 'json'),
    );
    var request = http.MultipartRequest('POST', url);
    if(bill != null){
      var billField = await http.MultipartFile.fromPath('bill', bill!.path);
      request.files.add(billField);
    }

    request.headers['X-User-Id'] = userManager.username;
    request.files.add(jsonPart);

    var response = await request.send();
    if(response.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  }

  Future<List<TransactionDTO>> getAllTransactions() async {
    UserManager userManager = UserManager();
    var url = Uri.parse('http://10.0.2.2:6852/bifrost/transactions/');
    var headers = {'X-User-Id': userManager.username};
    var response = await http.get(url, headers: headers);
    List<dynamic> transactionDTOs = jsonDecode(response.body);
    final List<TransactionDTO> transactions = transactionDTOs.map((data) {
      return getTransactionDTO(data);
    }).toList();
    return transactions;
  }

  TransactionDTO getTransactionDTO(data) {
    return TransactionDTO(
      transactionId: data['transaction_id'] as int,
      source: data['source'] as String,
      destination: data['destination'] as String,
      amount: data['amount'] as int,
      purpose: data['purpose'] as String,
      remarks: data['remarks'] as String?,
      status: data['status'] as String,
      mode: data['mode'] as String,
      bankAccount: data['bank_account'] as String?,
      transactionDate: formattingUtility.getDateFromLocalDate(data['transaction_date']),
    );
  }

  Future<List<String>> getModes() async {
    UserManager userManager = UserManager();
    var url = Uri.parse('http://10.0.2.2:6852/bifrost/transactions/transaction-modes');
    var headers = {'X-User-Id': userManager.username};
    var response = await http.get(url, headers: headers);
    List<String> modes = jsonDecode(response.body).cast<String>();
    return modes;
  }

  Future<List<String>> getStatuses() async {
    UserManager userManager = UserManager();
    var url = Uri.parse('http://10.0.2.2:6852/bifrost/transactions/transaction-statuses');
    var headers = {'X-User-Id': userManager.username};
    var response = await http.get(url, headers: headers);
    List<String> statuses = jsonDecode(response.body).cast<String>();
    return statuses;
  }

  Future<List<String>> getPurposes() async {
    UserManager userManager = UserManager();
    var url = Uri.parse('http://10.0.2.2:6852/bifrost/transactions/transaction-purposes');
    var headers = {'X-User-Id': userManager.username};
    var response = await http.get(url, headers: headers);
    List<String> purposes = jsonDecode(response.body).cast<String>();
    return purposes;
  }

  Future<bool> updateTransaction({
    required int transactionId,
    required String? source,
    required String? destination,
    required int? amount,
    required File? bill,
    required String? purpose,
    required String? mode,
    required String? bankAccount,
    required DateTime? transactionDate,
    required String? remarks
  }) async {
    UserManager userManager = UserManager();
    var url = Uri.parse('http://10.0.2.2:6852/bifrost/transactions/$transactionId/update-transaction');
    var formData = {
      'source': source,
      'destination': destination,
      'amount': amount,
      'purpose': purpose,
      'remarks': remarks,
      'transaction_date': '${transactionDate!.year}-${transactionDate.month.toString().padLeft(2, '0')}-${transactionDate.day.toString().padLeft(2, '0')}',
      'mode': mode,
      'bank_account': bankAccount
    };
    var jsonPart = http.MultipartFile.fromString(
      'createTransactionPayload',
      jsonEncode(formData),
      contentType: MediaType('application', 'json'),
    );
    var request = http.MultipartRequest('PUT', url);
    if(bill != null){
      var billField = await http.MultipartFile.fromPath('bill', bill!.path);
      request.files.add(billField);
    }

    request.headers['X-User-Id'] = userManager.username;
    request.files.add(jsonPart);

    var response = await request.send();
    if(response.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  }

  Future<File?> getBill(int transactionId) async {
    UserManager userManager = UserManager();
    var url = Uri.parse('http://10.0.2.2:6852/bifrost/transactions/$transactionId/get-bill');
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

  Future<bool> updateTransactionStatus({
    required int transactionId,
    required String? desiredStatus,
  }) async {
    UserManager userManager = UserManager();
    var url = Uri.parse('http://10.0.2.2:6852/bifrost/transactions/$transactionId/update-transaction-status');
    var statusChangeRequestBodyBody = {
      'transaction_id': transactionId,
      'desired_status': desiredStatus,
    };
    final headers = {
      'Content-Type': 'application/json',
      'X-User-Id': userManager.username,
    };
    final response = await http.post(
      url,
      headers: headers,
      body: jsonEncode(statusChangeRequestBodyBody),
    );
    if(response.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  }

  Future<Map<String, List<String>>> getStatusChangeMap() async {
    UserManager userManager = UserManager();
    var url = Uri.parse('http://10.0.2.2:6852/bifrost/transactions/state-changes');
    var headers = {'X-User-Id': userManager.username};
    var response = await http.get(url, headers: headers);
    Map<String, dynamic> responseMap = jsonDecode(response.body);
    Map<String, List<String>> statusChangesMap = {};
    responseMap.forEach((key, value) {
      if (value is List) {
        statusChangesMap[key] = List<String>.from(value);
      }
    });
    return statusChangesMap;
  }
}
