import 'package:bifrost_ui/BankAccounts/passbook_actions.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:multi_select_flutter/dialog/multi_select_dialog_field.dart';
import 'package:multi_select_flutter/util/multi_select_item.dart';
import 'package:multi_select_flutter/util/multi_select_list_type.dart';

import '../Transactions/transaction_actions.dart';
import '../Utils/formatting_util.dart';

class AccountPassBook extends StatefulWidget {
  final String accountName;

  const AccountPassBook({Key? key, required this.accountName}) : super(key: key);

  @override
  _AccountPassBook createState() => _AccountPassBook();
}

class _AccountPassBook extends State<AccountPassBook> {
  List<PassBookDTO> passBookEntries = [];
  List<PassBookDTO> initialPassBookEntries = [];

  PassBookActions passBookActions = PassBookActions();
  TransactionActions transactionActions = TransactionActions();
  FormattingUtility formattingUtility = FormattingUtility();

  int filterAmount = 0;
  DateTime? filterTransactionStartDate;
  DateTime? filterTransactionEndDate;
  List<String> selectedModes = [];
  List<String> selectedPurposes = [];

  final TextEditingController amountController = TextEditingController();
  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();

  List<String> availableModes = [];
  List<String> availablePurposes = [];

  @override
  void initState() {
    super.initState();
    _fetchPassBookEntries();
    _fetchTransactionPurposes();
    _fetchTransactionModes();
  }

  Future<void> _fetchPassBookEntries() async {
    final passBookEntriesForAccount =
    await passBookActions.getPassBookEntries(widget.accountName);
    setState(() {
      passBookEntries = passBookEntriesForAccount;
      initialPassBookEntries = passBookEntriesForAccount;
    });
  }

  void _fetchTransactionPurposes() async {
    final transactionPurposes = await transactionActions.getPurposes();
    setState(() {
      availablePurposes = transactionPurposes;
    });
  }

  void _fetchTransactionModes() async {
    final transactionModes = await transactionActions.getModes();
    setState(() {
      availableModes = transactionModes;
    });
  }

  Future<void> _selectTransactionsStartDate() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: filterTransactionStartDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: Colors.blue, // Head color
            hintColor: Colors.blue, // Selection color
            colorScheme: const ColorScheme.light(primary: Colors.blue),
            buttonTheme: const ButtonThemeData(
              textTheme: ButtonTextTheme.primary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      setState(() {
        filterTransactionStartDate = pickedDate;
        _startDateController.text = DateFormat('yyyy-MM-dd').format(pickedDate);
      });
    }
  }


  Future<void> _selectTransactionsEndDate() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: filterTransactionEndDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: Colors.blue, // Head color
            hintColor: Colors.blue, // Selection color
            colorScheme: const ColorScheme.light(primary: Colors.blue),
            buttonTheme: const ButtonThemeData(
              textTheme: ButtonTextTheme.primary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      setState(() {
        filterTransactionEndDate = pickedDate;
      });
      _endDateController.text = DateFormat('yyyy-MM-dd').format(pickedDate);
    }
  }

  void applyFilters() {
    setState(() {
      passBookEntries = initialPassBookEntries.where((passBookEntry) {
        final isAmountMatch = filterAmount == 0 || passBookEntry.transactionAmount == filterAmount;
        final isModeMatch = selectedModes.isEmpty ||
            selectedModes.contains(passBookEntry.transactionDTO.mode);
        final isPurposeMatch = selectedPurposes.isEmpty ||
            selectedPurposes.contains(passBookEntry.transactionDTO.purpose);
        final isTransactionStartDateMatch =
            filterTransactionStartDate == null || formattingUtility.getDateInDateTimeFormat(passBookEntry.transactionDTO.transactionDate).isAfter(filterTransactionStartDate!);
        final isTransactionEndDateMatch =
            filterTransactionEndDate == null || formattingUtility.getDateInDateTimeFormat(passBookEntry.transactionDTO.transactionDate).isBefore(filterTransactionEndDate!);

        return isAmountMatch &&
            isModeMatch &&
            isPurposeMatch &&
            isTransactionStartDateMatch &&
            isTransactionEndDateMatch;
      }).toList();
    });
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
                  decoration: const InputDecoration(labelText: 'Amount'),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    setState(() {
                      filterAmount = int.tryParse(value) ?? 0;
                    });
                  },
                ),
                MultiSelectDialogField(
                  title: const Text('Transaction Modes'),
                  buttonText: const Text('Transaction Modes'),
                  items: availableModes
                      .map((mode) => MultiSelectItem<String>(mode, mode))
                      .toList(),
                  listType: MultiSelectListType.CHIP,
                  initialValue: selectedModes,
                  onConfirm: (List<String> values) {
                    setState(() {
                      selectedModes = values;
                    });
                  },
                ),
                MultiSelectDialogField(
                  title: const Text('Transaction Purpose'),
                  buttonText: const Text('Transaction Purpose'),
                  items: availablePurposes
                      .map((purpose) => MultiSelectItem<String>(purpose, purpose))
                      .toList(),
                  listType: MultiSelectListType.CHIP,
                  initialValue: selectedPurposes,
                  onConfirm: (List<String> values) {
                    setState(() {
                      selectedPurposes = values;
                    });
                  },
                ),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Start Date',
                        ),
                        onTap: _selectTransactionsStartDate,
                        readOnly: true,
                        controller: _startDateController,

                      ),
                    ),
                    IconButton(
                      onPressed: _selectTransactionsStartDate,
                      icon: const Icon(Icons.calendar_today),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'End Date',
                        ),
                        onTap: _selectTransactionsEndDate,
                        readOnly: true,
                        controller: _endDateController,
                      ),
                    ),
                    IconButton(
                      onPressed: _selectTransactionsEndDate,
                      icon: const Icon(Icons.calendar_today),
                    ),
                  ],
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

  void clearFilters() {
    setState(() {
      filterAmount = 0;
      selectedModes = [];
      selectedPurposes = [];
      filterTransactionStartDate = null;
      filterTransactionEndDate = null;
      passBookEntries = initialPassBookEntries;

      _startDateController.clear();
      _endDateController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.accountName}\'s PassBook'),
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
        children: [
          Expanded(
            child: ListView.separated(
              itemCount: passBookEntries.length,
              separatorBuilder: (context, index) => Divider(color: Colors.grey[800]),
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
                  child: ListTile(
                    title: Text(
                      passBookEntry.transactionType == 'DEBIT'
                          ? passBookEntry.transactionDTO.destination
                          : passBookEntry.transactionDTO.source,
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
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            const Icon(Icons.calendar_month_outlined),
                            const SizedBox(width: 4),
                            Text(
                              DateFormat('dd-MM-yyyy').format(formattingUtility.getDateInDateTimeFormat(passBookEntry.transactionDTO.transactionDate)),
                              style: const TextStyle(fontSize: 12),
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
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
