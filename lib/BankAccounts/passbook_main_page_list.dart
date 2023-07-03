import 'package:bifrost_ui/BankAccounts/passbook_actions.dart';
import 'package:flutter/material.dart';

import 'account_pass_book.dart';


class PassBookMainPageListPage extends StatefulWidget {
  final List<PassBookDTO> passBookMainPages;

  const PassBookMainPageListPage({Key? key, required this.passBookMainPages})
      : super(key: key);

  @override
  _PassBookMainPageListPage createState() => _PassBookMainPageListPage();
}

class _PassBookMainPageListPage extends State<PassBookMainPageListPage> {

  List<PassBookDTO> filteredPassBooks = [];

  TextEditingController accountNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    filteredPassBooks = widget.passBookMainPages;
  }

  @override
  void dispose() {
    accountNameController.dispose();
    super.dispose();
  }

  void applyFilters() {
    setState(() {
      final filterAccountName = accountNameController.text.toLowerCase();

      filteredPassBooks = widget.passBookMainPages.where((passBookMainPage) {
        final accountName = passBookMainPage.accountName.toLowerCase();

        return accountName.contains(filterAccountName);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PassBooks'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(right: 20.0),
                        child: TextField(
                          controller: accountNameController,
                          onChanged: (_) => applyFilters(),
                          decoration: const InputDecoration(labelText: 'Account Name'),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Divider(color: Colors.grey[800]),
          Expanded(
            child: ListView.builder(
              itemCount: filteredPassBooks.length,
              itemBuilder: (context, index) {
                final passBook = filteredPassBooks[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AccountPassBook(accountName: passBook.accountName),
                      ),
                    );
                  },
                  child: Column(
                    children: [
                      ListTile(
                        title: Text(
                          passBook.accountName ?? '',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                        subtitle: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(passBook.accountType ?? ''),
                                  ],
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                const Icon(Icons.currency_rupee_rounded),
                                const SizedBox(width: 4),
                                Text(
                                  passBook.currentBalance.toString() ?? '',
                                  style: TextStyle(
                                    color: passBook.currentBalance > 0
                                        ? Colors.green
                                        : passBook.currentBalance < 0
                                        ? Colors.red
                                        : Colors.black,
                                    fontSize: 20,
                                  ),
                                ),
                              ],
                            ),

                          ],
                        ),
                      ),
                      const Divider(color: Colors.grey),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}