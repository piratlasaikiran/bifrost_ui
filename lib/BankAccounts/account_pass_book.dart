import 'package:bifrost_ui/BankAccounts/passbook_actions.dart';
import 'package:flutter/material.dart';


class AccountPassBook extends StatefulWidget {
  final String accountName;

  const AccountPassBook({Key? key, required this.accountName})
      : super(key: key);

  @override
  _AccountPassBook createState() => _AccountPassBook();
}

class _AccountPassBook extends State<AccountPassBook> {

  List<PassBookDTO> passBookEntries = [];
  PassBookActions passBookActions = PassBookActions();
  TextEditingController accountNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchPassBookEntries();
  }

  Future<void> _fetchPassBookEntries() async {
    final passBookEntriesForAccount = await passBookActions.getPassBookEntries(widget.accountName);
    setState(() {
      passBookEntries = passBookEntriesForAccount;
    });

  }

  @override
  void dispose() {
    accountNameController.dispose();
    super.dispose();
  }

  void applyFilters() {
    setState(() {
      _fetchPassBookEntries();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text('${widget.accountName} \'s PassBook')
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
              itemCount: passBookEntries.length,
              itemBuilder: (context, index) {
                final passBookEntry = passBookEntries[index];
                return GestureDetector(
                  onTap: () {
                    // Navigator.push(
                    //   context,
                    //   MaterialPageRoute(
                    //     builder: (context) => AccountPassBook(accountName: passBook.accountName),
                    //   ),
                    // );
                  },
                  child: Column(
                    children: [
                      ListTile(
                        title: Text(
                          passBookEntry.transactionType == 'DEBIT' ? passBookEntry.transactionDTO.destination : passBookEntry.transactionDTO.source,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
                        ),
                        subtitle: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Chip(
                                      label: Text(passBookEntry.transactionDTO.purpose ?? ''),
                                      backgroundColor: Colors.blue,
                                      labelStyle: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 8,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Chip(
                                      label: Text(passBookEntry.transactionDTO.mode ?? ''),
                                      backgroundColor: Colors.orange,
                                      labelStyle: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 8,
                                      ),
                                    )
                                  ],
                                ),
                              ],
                            ),
                            Column(
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.currency_rupee_rounded),
                                    const SizedBox(width: 4),
                                    Text(
                                      passBookEntry.transactionType == 'DEBIT' ? '-' : '+',
                                      style: TextStyle(
                                        color: passBookEntry.transactionType == 'DEBIT'
                                            ? Colors.red
                                            : Colors.green,
                                        fontSize: 20,
                                      ),
                                    ),
                                    Text(
                                      passBookEntry.transactionAmount.toString() ?? '',
                                      style: TextStyle(
                                        color: passBookEntry.transactionType == 'DEBIT'
                                            ? Colors.red
                                            : Colors.green,
                                        fontSize: 20,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  passBookEntry.currentBalance.toString() ?? '',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.black54,
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