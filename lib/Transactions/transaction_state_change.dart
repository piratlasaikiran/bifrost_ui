import 'package:bifrost_ui/Transactions/transaction_actions.dart';
import 'package:flutter/material.dart';

class TransactionStateChange extends StatefulWidget {
  final TransactionDTO transaction;

  const TransactionStateChange({Key? key, required this.transaction}) : super(key: key);


  @override
  _TransactionStateChange createState() => _TransactionStateChange();
}

class _TransactionStateChange extends State<TransactionStateChange> {
  TransactionActions transactionActions = TransactionActions();

  String? _selectedStatus;

  @override
  void initState() {
    super.initState();
  }

  Future<List<String>> _fetchValidStatuses() async {
    final transactionStateChangeMap = await transactionActions.getStatusChangeMap();
    return transactionStateChangeMap[widget.transaction.status] ?? [];
  }

  Future<void> _updateTransactionStatus() async {
    final result = await transactionActions.updateTransactionStatus(
        transactionId: widget.transaction.transactionId,
        desiredStatus: _selectedStatus);

    if(result){
      Future.microtask(() {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Success'),
              content: const Text('Status updated successfully.'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).pop();
                  },
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
      });
    } else {
      Future.microtask(() {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Failure'),
              content: const Text('Failed to update status.'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
      });
    }
  }



  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<String>>(
      future: _fetchValidStatuses(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        } else if (snapshot.hasError) {
          return AlertDialog(
            title: const Text('Error'),
            content: const Text('Failed to fetch valid statuses.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('OK'),
              ),
            ],
          );
        } else if (snapshot.data == null || snapshot.data!.isEmpty) {
          return AlertDialog(
            title: const Text('Change Status'),
            content: const Text('Status change is not allowed for this Transaction'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('OK'),
              ),
            ],
          );
        } else {
          final validStatuses = snapshot.data!;
          return AlertDialog(
            title: const Text('Change Status'),
            content: SingleChildScrollView(
              child: ListBody(
                children: validStatuses.map((status) {
                  return RadioListTile<String>(
                    title: Text(status),
                    value: status,
                    groupValue: _selectedStatus,
                    onChanged: (String? value) {
                      setState(() {
                        _selectedStatus = value;
                      });
                    },
                  );
                }).toList(),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: _selectedStatus == null || _selectedStatus!.isEmpty ? null : _updateTransactionStatus,
                // Disable the button if no status is selected
                child: const Text('Update'),
              ),
            ],
          );
        }
      },
    );
  }

}
