// lib/screens/add_transaction/add_transaction_screen.dart
import 'package:flutter/material.dart';

class AddTransactionScreen extends StatelessWidget {
  final String initialType;
  
  const AddTransactionScreen({super.key, required this.initialType});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(initialType == 'income' ? 'Thu nhập' : 'Chi tiêu')),
      body: const Center(child: Text('Thêm giao dịch - To be implemented')),
    );
  }
}
