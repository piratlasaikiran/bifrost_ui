import 'dart:convert';
import '../Utils/user_manager.dart';
import 'package:http/http.dart' as http;

class BankAccountActions{
  Future<List<String>> getAccountNickNames() async {
    UserManager userManager = UserManager();
    var url = Uri.parse('http://10.0.2.2:6852/bifrost/bank-accounts/nick-names');
    var headers = {'X-User-Id': userManager.username};
    var response = await http.get(url, headers: headers);
    List<String> purposes = jsonDecode(response.body).cast<String>();
    return purposes;
  }

  Future<List<String>> getATMCards() async {
    UserManager userManager = UserManager();
    var url = Uri.parse('http://10.0.2.2:6852/bifrost/bank-accounts/atm-cards');
    var headers = {'X-User-Id': userManager.username};
    var response = await http.get(url, headers: headers);
    var formattedResponse = jsonDecode(response.body) as List<dynamic>;
    var atmCards = formattedResponse.map((value) => value.toString()).toList();
    return atmCards;
  }
}