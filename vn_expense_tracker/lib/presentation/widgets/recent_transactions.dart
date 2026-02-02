// lib/presentation/widgets/recent_transactions.dart
import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class RecentTransactions extends StatelessWidget {
  const RecentTransactions({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock data for demo
    final transactions = [
      {'title': 'Ăn trưa', 'amount': -120000.0, 'category': 'Ăn uống', 'date': 'Hôm nay'},
      {'title': 'Grab', 'amount': -50000.0, 'category': 'Di chuyển', 'date': 'Hôm nay'},
      {'title': 'Lương tháng 2', 'amount': 10000000.0, 'category': 'Lương', 'date': 'Hôm qua'},
      {'title': 'VinMart', 'amount': -350000.0, 'category': 'Mua sắm', 'date': 'Hôm qua'},
      {'title': 'Cafe', 'amount': -45000.0, 'category': 'Ăn uống', 'date': '28/01'},
    ];

    return Column(
      children: transactions.map((tx) {
        final amount = tx['amount'] as double;
        final isExpense = amount < 0;
        
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: (isExpense ? AppTheme.expenseColor : AppTheme.incomeColor)
                    .withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                isExpense ? Icons.arrow_downward : Icons.arrow_upward,
                color: isExpense ? AppTheme.expenseColor : AppTheme.incomeColor,
              ),
            ),
            title: Text(
              tx['title'] as String,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: Text(tx['category'] as String),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${isExpense ? '-' : '+'}${amount.abs().toStringAsFixed(0)} ₫',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: isExpense ? AppTheme.expenseColor : AppTheme.incomeColor,
                  ),
                ),
                Text(
                  tx['date'] as String,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
