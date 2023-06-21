import 'dart:convert';
import 'dart:io';
import 'package:http_parser/http_parser.dart';

import '../Utils/user_manager.dart';
import 'package:http/http.dart' as http;


class TransactionActions{
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

  Future<List<String>> getModes() async {
    UserManager userManager = UserManager();
    var url = Uri.parse('http://10.0.2.2:6852/bifrost/transactions/transaction-modes');
    var headers = {'X-User-Id': userManager.username};
    var response = await http.get(url, headers: headers);
    List<String> modes = jsonDecode(response.body).cast<String>();
    return modes;
  }

  Future<List<String>> getPurposes() async {
    UserManager userManager = UserManager();
    var url = Uri.parse('http://10.0.2.2:6852/bifrost/transactions/transaction-purposes');
    var headers = {'X-User-Id': userManager.username};
    var response = await http.get(url, headers: headers);
    List<String> purposes = jsonDecode(response.body).cast<String>();
    return purposes;
  }

}