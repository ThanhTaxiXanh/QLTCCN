// lib/screens/dashboard/dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../utils/design_tokens.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tổng quan'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: DesignTokens.pagePadding,
        child: Column(
          children: [
            const SizedBox(height: DesignTokens.spacing16),
            _buildDateHeader(context),
            const SizedBox(height: DesignTokens.spacing20),
            _buildWalletCard(context),
            const SizedBox(height: DesignTokens.spacing20),
            _buildQuickActions(context),
            const SizedBox(height: DesignTokens.spacing20),
            _buildTodaySummary(context),
            const SizedBox(height: DesignTokens.spacing20),
            _buildRecentTransactions(context),
          ],
        ),
      ),
    );
  }

  Widget _buildDateHeader(BuildContext context) {
    return Card(
      child: Padding(
        padding: DesignTokens.cardPadding,
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Tháng 2 - 2026', style: Theme.of(context).textTheme.labelMedium),
                  Text('2', style: Theme.of(context).textTheme.displayMedium),
                  const Text('Sự kiện Dương Lịch', style: TextStyle(color: DesignTokens.expenseRed)),
                ],
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('Tháng 12 - Ất Tỵ', style: Theme.of(context).textTheme.labelMedium),
                  Text('15', style: Theme.of(context).textTheme.displayMedium),
                  const Text('Rằm tháng Chạp', style: TextStyle(color: DesignTokens.expenseRed)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWalletCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: DesignTokens.walletGradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: DesignTokens.cardRadius,
      ),
      padding: DesignTokens.cardPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.account_balance_wallet, color: Colors.white),
              const SizedBox(width: DesignTokens.spacing8),
              const Text('Demo', style: TextStyle(color: Colors.white)),
              const Spacer(),
              Icon(Icons.arrow_drop_down, color: Colors.white),
            ],
          ),
          const SizedBox(height: DesignTokens.spacing16),
          Text('10,000₫', style: Theme.of(context).textTheme.displayLarge?.copyWith(color: Colors.white)),
          const SizedBox(height: DesignTokens.spacing8),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: DesignTokens.spacing12,
              vertical: DesignTokens.spacing4,
            ),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.2),
              borderRadius: BorderRadius.circular(DesignTokens.radiusSmall),
            ),
            child: const Text('+100.0% so với tháng trước', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildQuickAction(Icons.mic, 'Nhập bằng\ngiọng nói'),
        _buildQuickAction(Icons.shopping_cart, 'Nhập\nChi tiêu'),
        _buildQuickAction(Icons.account_balance, 'Nhập\nThu nhập'),
        _buildQuickAction(Icons.flag, 'Thiết lập\nMục tiêu'),
      ],
    );
  }

  Widget _buildQuickAction(IconData icon, String label) {
    return Column(
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: DesignTokens.pastelBlue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(DesignTokens.radiusMedium),
          ),
          child: Icon(icon, color: DesignTokens.pastelBlue),
        ),
        const SizedBox(height: DesignTokens.spacing8),
        Text(label, textAlign: TextAlign.center, style: const TextStyle(fontSize: DesignTokens.fontSizeXS)),
      ],
    );
  }

  Widget _buildTodaySummary(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Card(
            color: DesignTokens.expenseRed.withOpacity(0.1),
            child: Padding(
              padding: DesignTokens.cardPadding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Chi phí'),
                  const SizedBox(height: DesignTokens.spacing8),
                  Text('10,000₫', style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: DesignTokens.expenseRed)),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: DesignTokens.spacing12),
        Expanded(
          child: Card(
            color: DesignTokens.incomeGreen.withOpacity(0.1),
            child: Padding(
              padding: DesignTokens.cardPadding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Thu nhập'),
                  const SizedBox(height: DesignTokens.spacing8),
                  Text('20,000₫', style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: DesignTokens.incomeGreen)),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRecentTransactions(BuildContext context) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: DesignTokens.cardPadding,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Giao dịch gần đây', style: Theme.of(context).textTheme.titleLarge),
                TextButton(onPressed: () {}, child: const Text('Xem tất cả')),
              ],
            ),
          ),
          ListTile(
            leading: const CircleAvatar(child: Icon(Icons.restaurant)),
            title: const Text('Demo Expense Category'),
            subtitle: const Text('Hôm nay'),
            trailing: Text('-10,000₫', style: TextStyle(color: DesignTokens.expenseRed, fontWeight: FontWeight.w600)),
          ),
          ListTile(
            leading: const CircleAvatar(child: Icon(Icons.attach_money)),
            title: const Text('Demo Income Category'),
            subtitle: const Text('Hôm nay'),
            trailing: Text('+20,000₫', style: TextStyle(color: DesignTokens.incomeGreen, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}
