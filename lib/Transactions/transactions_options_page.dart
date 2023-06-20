import 'package:flutter/material.dart';

import 'add_transaction_dialog.dart';

class TransactionsOptionsPage extends StatelessWidget {
  const TransactionsOptionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transaction Options'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildCircularButton(
              icon: Icons.add,
              label: 'Add Transaction',
              onTap: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return const AddTransactionDialog();
                  },
                );
              },
              color: Colors.blue,
              borderColor: Colors.white,
            ),
            const SizedBox(height: 16.0),
            _buildCircularButton(
              icon: Icons.list,
              label: 'Manage \nTransactions',
              onTap: () {
                // perform action when pending balance is clicked
              },
              color: Colors.blue,
              borderColor: Colors.white,
            ),
            const SizedBox(height: 16.0),
          ],
        ),
      ),
    );
  }

  Widget _buildCircularButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required Color color,
    required Color borderColor,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 180.0,
        height: 180.0,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
          border: Border.all(color: borderColor, width: 2.0),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 48.0,
              color: Colors.white,
            ),
            const SizedBox(height: 8.0),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16.0,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
