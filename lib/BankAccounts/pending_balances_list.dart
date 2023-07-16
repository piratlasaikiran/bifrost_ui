import 'package:bifrost_ui/BankAccounts/passbook_actions.dart';
import 'package:flutter/material.dart';

import 'account_pass_book.dart';
import 'account_pending_balances.dart';


class PendingBalancesList extends StatefulWidget {
  final List<PendingBalanceDTO> pendingBalances;

  const PendingBalancesList({Key? key, required this.pendingBalances})
      : super(key: key);

  @override
  _PendingBalancesList createState() => _PendingBalancesList();
}

class _PendingBalancesList extends State<PendingBalancesList> {

  List<PendingBalanceDTO> filteredPendingBalances = [];

  TextEditingController accountNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    filteredPendingBalances = widget.pendingBalances;
  }

  @override
  void dispose() {
    accountNameController.dispose();
    super.dispose();
  }

  void applyFilters() {
    setState(() {
      final filterAccountName = accountNameController.text.toLowerCase();

      filteredPendingBalances = widget.pendingBalances.where((pendingBalanceAccount) {
        final accountName = pendingBalanceAccount.accountName.toLowerCase();

        return accountName.contains(filterAccountName);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Balances'),
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
              itemCount: filteredPendingBalances.length,
              itemBuilder: (context, index) {
                final userPendingBalance = filteredPendingBalances[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AccountPendingBalance(accountName: userPendingBalance.accountName),
                      ),
                    );
                  },
                  child: Column(
                    children: [
                      ListTile(
                        title: Text(
                          userPendingBalance.accountName ?? '',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                        subtitle: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.currency_rupee_rounded),
                                const SizedBox(width: 4),
                                Text(
                                  userPendingBalance.pendingBalance.toString() ?? '',
                                  style: TextStyle(
                                    color: userPendingBalance.pendingBalance > 0
                                        ? Colors.green
                                        : userPendingBalance.pendingBalance < 0
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