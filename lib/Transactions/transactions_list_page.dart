import 'package:bifrost_ui/Transactions/transaction_actions.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:multi_select_flutter/dialog/multi_select_dialog_field.dart';
import 'package:multi_select_flutter/util/multi_select_item.dart';
import 'package:multi_select_flutter/util/multi_select_list_type.dart';

import '../BankAccounts/bank_account_actions.dart';
import '../Employees/Driver/driver_actions.dart';
import '../Employees/Supervisor/supervisor_actions.dart';
import '../Employees/Vendors/vendor_actions.dart';
import '../Utils/formatting_util.dart';

class TransactionListPage extends StatefulWidget {
  final List<TransactionDTO> transactions;

  const TransactionListPage({Key? key, required this.transactions}) : super(key: key);

  @override
  _TransactionListPageState createState() => _TransactionListPageState();
}

class _TransactionListPageState extends State<TransactionListPage> {
  TransactionActions transactionActions = TransactionActions();
  SupervisorActions supervisorActions = SupervisorActions();
  FormattingUtility formattingUtility = FormattingUtility();

  List<TransactionDTO> filteredTransactions = [];
  int filterAmount = 0;
  DateTime? filterTransactionStartDate;
  DateTime? filterTransactionEndDate;
  List<String> selectedModes = [];
  List<String> selectedStatues = [];
  List<String> selectedBankAccounts = [];
  List<String> selectedPurposes = [];
  List<String> selectedSources = [];
  List<String> selectedDestinations = [];

  List<String> availableModes = [];
  List<String> availableStatuses = [];
  List<String> availableBankAccounts = [];
  List<String> availablePurposes = [];
  List<String> availableSources = [];
  List<String> availableDestinations = [];

  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();


  @override
  void initState() {
    super.initState();
    _fetchTransactionPurposes();
    _fetchTransactionModes();
    _fetchBankAccounts();
    _fetchSources();
    _fetchDestinations();
    filteredTransactions = widget.transactions;
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

  void _fetchBankAccounts() async {
    BankAccountActions bankAccountActions = BankAccountActions();
    final accountNames = await bankAccountActions.getAccountNickNames();
    setState(() {
      availableBankAccounts = accountNames;
      availableBankAccounts.add("My Account");
    });
  }

  void _fetchSources() async {
    final supervisors = await supervisorActions.getSupervisorNames();
    setState(() {
      availableSources = supervisors;
    });
  }

  void _fetchDestinations() async {
    final supervisors = await supervisorActions.getSupervisorNames();

    DriverActions driverActions = DriverActions();
    final drivers = await driverActions.getDriverNames();

    VendorActions vendorActions = VendorActions();
    final vendors = await vendorActions.getVendorIds();

    setState(() {
      availableDestinations = supervisors;
      availableDestinations.addAll(drivers);
      availableDestinations.addAll(vendors);
    });
  }

  void applyFilters() {
    setState(() {
      filteredTransactions = widget.transactions.where((transaction) {
        final isSourceMatch = selectedSources.isEmpty ||
            selectedSources.contains(transaction.source.toLowerCase());
        final isDestinationMatch = selectedDestinations.isEmpty ||
            selectedDestinations.contains(transaction.destination.toLowerCase());
        final isAmountMatch = filterAmount == 0 || transaction.amount == filterAmount;
        final isModeMatch = selectedModes.isEmpty ||
            selectedModes.contains(transaction.mode.toLowerCase());
        final isStatusMatch = selectedStatues.isEmpty ||
            selectedStatues.contains(transaction.status.toLowerCase());
        final isBankAccountMatch = selectedBankAccounts.isEmpty ||
            selectedBankAccounts.contains(transaction.bankAccount!.toLowerCase());
        final isPurposeMatch = selectedPurposes.isEmpty ||
            selectedPurposes.contains(transaction.purpose.toLowerCase());
        final isTransactionStartDateMatch =
            filterTransactionStartDate == null || formattingUtility.getDateInDateTimeFormat(transaction.transactionDate).isAfter(filterTransactionStartDate!);
        final isTransactionEndDateMatch =
            filterTransactionEndDate == null || formattingUtility.getDateInDateTimeFormat(transaction.transactionDate).isBefore(filterTransactionEndDate!);

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
      selectedSources = [];
      selectedDestinations = [];
      filterAmount = 0;
      selectedModes = [];
      selectedStatues = [];
      selectedBankAccounts = [];
      selectedPurposes = [];
      filterTransactionStartDate = null;
      filterTransactionEndDate = null;
      filteredTransactions = widget.transactions;

      _startDateController.clear();
      _endDateController.clear();
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
          Text('Date: ${transaction.transactionDate}'),
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
                MultiSelectDialogField(
                  title: const Text('Source'),
                  buttonText: const Text('Source'),
                  items: availableSources
                      .map((source) => MultiSelectItem<String>(source, source))
                      .toList(),
                  listType: MultiSelectListType.CHIP,
                  initialValue: selectedSources,
                  onConfirm: (List<String> values) {
                    setState(() {
                      selectedSources = values;
                    });
                  },
                ),
                MultiSelectDialogField(
                  title: const Text('Destination'),
                  buttonText: const Text('Destination'),
                  items: availableDestinations
                      .map((destination) => MultiSelectItem<String>(destination, destination))
                      .toList(),
                  listType: MultiSelectListType.CHIP,
                  initialValue: selectedDestinations,
                  onConfirm: (List<String> values) {
                    setState(() {
                      selectedDestinations = values;
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
                  title: const Text('Transaction Status'),
                  buttonText: const Text('Transaction Status'),
                  items: availableStatuses
                      .map((status) => MultiSelectItem<String>(status, status))
                      .toList(),
                  listType: MultiSelectListType.CHIP,
                  initialValue: selectedStatues,
                  onConfirm: (List<String> values) {
                    setState(() {
                      selectedStatues = values;
                    });
                  },
                ),
                MultiSelectDialogField(
                  title: const Text('Bank Account'),
                  buttonText: const Text('Bank Account'),
                  items: availableBankAccounts
                      .map((bankAccount) => MultiSelectItem<String>(bankAccount, bankAccount))
                      .toList(),
                  listType: MultiSelectListType.CHIP,
                  initialValue: selectedBankAccounts,
                  onConfirm: (List<String> values) {
                    setState(() {
                      selectedBankAccounts = values;
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
