import 'dart:convert';
import 'dart:io';
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

    return true;

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