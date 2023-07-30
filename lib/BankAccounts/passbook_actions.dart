import 'dart:convert';

import 'package:http_parser/http_parser.dart';

import '../Transactions/transaction_actions.dart';
import '../../utils/user_manager.dart';

import 'package:http/http.dart' as http;

import '../Utils/constants.dart';

class PassBookDTO{
  final String accountName;
  final String accountType;
  final TransactionDTO transactionDTO;
  final int currentBalance;
  final int transactionAmount;
  final String transactionType;

  PassBookDTO({
    required this.accountName,
    required this.accountType,
    required this.transactionDTO,
    required this.currentBalance,
    required this.transactionAmount,
    required this.transactionType
  });
}

class PendingBalanceDTO{
  final String accountName;
  final TransactionDTO transactionDTO;
  final int pendingBalance;

  PendingBalanceDTO({
    required this.accountName,
    required this.transactionDTO,
    required this.pendingBalance
  });
}

class PassBookActions{

  String backendIp = Constants().awsIpAddress;

  TransactionActions transactionActions = TransactionActions();
  UserManager userManager = UserManager();

  Future<List<PassBookDTO>> getAllPassBookMainPages() async {
    var url = Uri.parse('http://$backendIp:6852/bifrost/transactions/passbook-main-pages');
    var headers = {'X-User-Id': userManager.username};
    var response = await http.get(url, headers: headers);
    List<dynamic> transactionDTOs = jsonDecode(response.body);
    final List<PassBookDTO> passBookMainPages = transactionDTOs.map((data) {
      return PassBookDTO(
        accountName: data['account_name'] as String,
        accountType: data['account_type'] as String,
        transactionDTO: transactionActions.getTransactionDTO(data['transaction']),
        currentBalance: data['current_balance'] as int,
        transactionAmount: data['transaction_amount'] as int,
        transactionType: data['transaction_type'] as String
      );
    }).toList();
    return passBookMainPages;
  }

  Future<List<PassBookDTO>> getPassBookEntries(String accountName) async {
    var url = Uri.parse('http://$backendIp:6852/bifrost/transactions/passbooks/$accountName');
    var headers = {'X-User-Id': userManager.username};
    var response = await http.get(url, headers: headers);
    List<dynamic> transactionDTOs = jsonDecode(response.body);
    final List<PassBookDTO> passBookEntries = transactionDTOs.map((data) {
      return PassBookDTO(
          accountName: data['account_name'] as String,
          accountType: data['account_type'] as String,
          transactionDTO: transactionActions.getTransactionDTO(data['transaction']),
          currentBalance: data['current_balance'] as int,
          transactionAmount: data['transaction_amount'] as int,
          transactionType: data['transaction_type'] as String
      );
    }).toList();
    return passBookEntries;
  }

  Future<List<PendingBalanceDTO>> getAllPendingBalancesForAllUsers() async {
    var url = Uri.parse('http://$backendIp:6852/bifrost/transactions/pending-balances');
    var headers = {'X-User-Id': userManager.username};
    var response = await http.get(url, headers: headers);
    List<dynamic> pendingBalanceDTOs = jsonDecode(response.body);
    final List<PendingBalanceDTO> pendingBalances = pendingBalanceDTOs.map((data) {
      return PendingBalanceDTO(
          accountName: data['account_name'] as String,
          transactionDTO: transactionActions.getTransactionDTO(data['transaction']),
          pendingBalance: data['pending_balance'] as int
      );
    }).toList();
    return pendingBalances;
  }

  Future<List<PendingBalanceDTO>> getPendingBalanceEntriesForAccount(String accountName) async {
    var url = Uri.parse('http://$backendIp:6852/bifrost/transactions/account-name/$accountName/account-pending-balances');
    var headers = {'X-User-Id': userManager.username};
    var response = await http.get(url, headers: headers);
    List<dynamic> pendingBalanceDTOs = jsonDecode(response.body);
    final List<PendingBalanceDTO> pendingBalances = pendingBalanceDTOs.map((data) {
      return PendingBalanceDTO(
          accountName: data['account_name'] as String,
          transactionDTO: transactionActions.getTransactionDTO(data['transaction']),
          pendingBalance: data['pending_balance'] as int
      );
    }).toList();
    return pendingBalances;
  }

  Future<bool> settlePendingBalanceForUser({
    required String accountName,
    required String mode,
    required String bankAccount,
    required String? remarks
  }) async {
    UserManager userManager = UserManager();
    var url = Uri.parse('http://$backendIp:6852/bifrost/transactions/account-name/$accountName/settle-pending-balance');
    var formData = {
      'payer': userManager.username,
      'payee': accountName,
      'remarks': remarks,
      'mode': mode,
      'bank_account': bankAccount
    };
    var jsonPart = http.MultipartFile.fromString(
      'settleBalancePayload',
      jsonEncode(formData),
      contentType: MediaType('application', 'json'),
    );
    var request = http.MultipartRequest('POST', url);

    request.headers['X-User-Id'] = userManager.username;
    request.files.add(jsonPart);

    var response = await request.send();
    if(response.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  }
}
