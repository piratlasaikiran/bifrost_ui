import 'package:bifrost_ui/Transactions/transaction_actions.dart';
import 'package:flutter/material.dart';

class TransactionListPage extends StatefulWidget {
  final List<TransactionDTO> transactions;

  const TransactionListPage({Key? key, required this.transactions}) : super(key: key);

  @override
  _TransactionListPageState createState() => _TransactionListPageState();
}

class _TransactionListPageState extends State<TransactionListPage> {
  List<TransactionDTO> filteredTransactions = [];
  String filterSource = '';
  String filterDestination = '';
  int filterAmount = 0;
  String filterMode = '';
  String filterStatus = '';
  String filterBankAccount = '';
  String filterPurpose = '';
  DateTime? filterTransactionStartDate;
  DateTime? filterTransactionEndDate;

  @override
  void initState() {
    super.initState();
    filteredTransactions = widget.transactions;
  }

  void applyFilters() {
    setState(() {
      filteredTransactions = widget.transactions.where((transaction) {
        final isSourceMatch = filterSource.isEmpty ||
            transaction.source.toLowerCase().contains(filterSource.toLowerCase());
        final isDestinationMatch = filterDestination.isEmpty ||
            transaction.destination.toLowerCase().contains(filterDestination.toLowerCase());
        final isAmountMatch = filterAmount == 0 || transaction.amount == filterAmount;
        final isModeMatch = filterMode.isEmpty ||
            transaction.mode.toLowerCase().contains(filterMode.toLowerCase());
        final isStatusMatch = filterStatus.isEmpty ||
            transaction.status.toLowerCase().contains(filterStatus.toLowerCase());
        final isBankAccountMatch = filterBankAccount.isEmpty ||
            transaction.bankAccount.toLowerCase().contains(filterBankAccount.toLowerCase());
        final isPurposeMatch = filterPurpose.isEmpty ||
            transaction.purpose.toLowerCase().contains(filterPurpose.toLowerCase());
        final isTransactionStartDateMatch =
            filterTransactionStartDate == null || transaction.transactionDate == filterTransactionStartDate;
        final isTransactionEndDateMatch =
            filterTransactionEndDate == null || transaction.transactionDate == filterTransactionEndDate;

        return isSourceMatch &&
            isDestinationMatch &&
            isAmountMatch &&
            isModeMatch &&
            isStatusMatch &&
            isBankAccountMatch &&
            isPurposeMatch &&
            isTransactionStartDateMatch &&
            isTransactionEndDateMatch;
      }).toList();
    });
  }

  void clearFilters() {
    setState(() {
      filterSource = '';
      filterDestination = '';
      filterAmount = 0;
      filterMode = '';
      filterStatus = '';
      filterBankAccount = '';
      filterPurpose = '';
      filterTransactionStartDate = null;
      filterTransactionEndDate = null;
      filteredTransactions = widget.transactions;
    });
  }

  String toCamelCase(String text) {
    final words = text.split('_');

    final capitalizedWords = words.map((word) {
      final firstLetter = word.substring(0, 1).toUpperCase();
      final remainingLetters = word.substring(1).toLowerCase();
      return '$firstLetter$remainingLetters';
    }).toList();

    return capitalizedWords.join();
  }



  Widget buildTransactionItem(TransactionDTO transaction) {
    IconData statusIcon;
    Color statusColor;

    if (transaction.status == 'CHECKED') {
      statusIcon = Icons.check_circle;
      statusColor = Colors.green;
    } else if (transaction.status == 'REJECTED') {
      statusIcon = Icons.cancel;
      statusColor = Colors.red;
    } else {
      statusIcon = Icons.info;
      statusColor = Colors.grey;
    }

    return ListTile(
      title: Row(
        children: [
          Text(transaction.source),
          const SizedBox(width: 6),
          const Icon(Icons.arrow_forward),
          const SizedBox(width: 6),
          Text(transaction.destination),
        ],
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Amount: ${transaction.amount}'),
        ],
      ),



      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(statusIcon, color: statusColor),
          const SizedBox(width: 8),
          Text(toCamelCase(transaction.status)),
          const SizedBox(width: 8),
          PopupMenuButton<String>(
            itemBuilder: (context) => [
              const PopupMenuItem<String>(
                value: 'view_edit',
                child: Text('View & Edit'),
              ),
              const PopupMenuItem<String>(
                value: 'change_status',
                child: Text('Change Status'),
              ),
            ],
            onSelected: (value) {
              if (value == 'view_edit') {
                // Handle view & edit action
              }else if (value == 'change_status') {
                // Handle view & edit action
              }
            },
          ),
        ],
      ),
    );
  }



  void showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Select Filters'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  decoration: const InputDecoration(labelText: 'Source'),
                  onChanged: (value) {
                    setState(() {
                      filterSource = value;
                    });
                  },
                ),
                TextField(
                  decoration: const InputDecoration(labelText: 'Destination'),
                  onChanged: (value) {
                    setState(() {
                      filterDestination = value;
                    });
                  },
                ),
                TextField(
                  decoration: const InputDecoration(labelText: 'Amount'),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    setState(() {
                      filterAmount = int.tryParse(value) ?? 0;
                    });
                  },
                ),
                TextField(
                  decoration: const InputDecoration(labelText: 'Mode'),
                  onChanged: (value) {
                    setState(() {
                      filterMode = value;
                    });
                  },
                ),
                TextField(
                  decoration: const InputDecoration(labelText: 'Status'),
                  onChanged: (value) {
                    setState(() {
                      filterStatus = value;
                    });
                  },
                ),
                TextField(
                  decoration: const InputDecoration(labelText: 'Bank AC'),
                  onChanged: (value) {
                    setState(() {
                      filterBankAccount = value;
                    });
                  },
                ),
                TextField(
                  decoration: const InputDecoration(labelText: 'Purpose'),
                  onChanged: (value) {
                    setState(() {
                      filterPurpose = value;
                    });
                  },
                ),
                TextField(
                  decoration: const InputDecoration(labelText: 'Start Date'),
                  readOnly: true,
                  onTap: () async {
                    final selectedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    setState(() {
                      filterTransactionStartDate = selectedDate;
                    });
                  },
                ),
                TextField(
                  decoration: const InputDecoration(labelText: 'End Date'),
                  readOnly: true,
                  onTap: () async {
                    final selectedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    setState(() {
                      filterTransactionEndDate = selectedDate;
                    });
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Cancel button
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                applyFilters(); // Apply button
                Navigator.of(context).pop();
              },
              child: const Text('Apply'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transactions'),
        actions: [
          PopupMenuButton<String>(
            itemBuilder: (context) => [
              const PopupMenuItem<String>(
                value: 'select_filters',
                child: Text('Select Filters'),
              ),
              const PopupMenuItem<String>(
                value: 'reset_filters',
                child: Text('Reset Filters'),
              ),
            ],
            onSelected: (value) {
              if (value == 'select_filters') {
                showFilterDialog(); // Show filter dialog
              } else if (value == 'reset_filters') {
                clearFilters();
              }
            },
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ListView.separated(
              itemCount: filteredTransactions.length,
              itemBuilder: (context, index) {
                final transaction = filteredTransactions[index];
                return buildTransactionItem(transaction);
              },
              separatorBuilder: (context, index) {
                return const Divider(
                  color: Colors.grey,
                  thickness: 1.0,
                );
              },
            ),
          ),
        ],
      ),

    );
  }
}
