// lib/screens/main_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dashboard/dashboard_screen.dart';
import 'history/history_screen.dart';
import 'statistics/statistics_screen.dart';
import 'settings/settings_screen.dart';
import 'add_transaction/add_transaction_screen.dart';
import '../utils/design_tokens.dart';

/// Main screen with bottom navigation and centered FAB
class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    DashboardScreen(),
    HistoryScreen(),
    SizedBox.shrink(), // Placeholder for FAB
    StatisticsScreen(),
    SettingsScreen(),
  ];

  final List<BottomNavigationBarItem> _navItems = const [
    BottomNavigationBarItem(
      icon: Icon(Icons.home_outlined),
      activeIcon: Icon(Icons.home),
      label: 'Tổng quan',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.calendar_today_outlined),
      activeIcon: Icon(Icons.calendar_today),
      label: 'Lịch sử',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.add, color: Colors.transparent),
      label: '',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.bar_chart_outlined),
      activeIcon: Icon(Icons.bar_chart),
      label: 'Thống kê',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.settings_outlined),
      activeIcon: Icon(Icons.settings),
      label: 'Cài đặt',
    ),
  ];

  void _onTabTapped(int index) {
    if (index == 2) {
      // FAB tapped - show add transaction modal
      _showAddTransactionModal();
    } else {
      setState(() {
        _currentIndex = index;
      });
    }
  }

  void _showAddTransactionModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.4,
        decoration: const BoxDecoration(
          color: DesignTokens.surfaceWhite,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(DesignTokens.radiusXLarge),
          ),
        ),
        padding: const EdgeInsets.all(DesignTokens.spacing24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: DesignTokens.textTertiary.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: DesignTokens.spacing24),
            
            // Title
            Text(
              'Giao dịch mới',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: DesignTokens.spacing24),
            
            // Quick action buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildQuickActionButton(
                  context,
                  icon: Icons.remove_circle_outline,
                  label: 'Chi tiêu',
                  color: DesignTokens.expenseRed,
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AddTransactionScreen(
                          initialType: 'expense',
                        ),
                      ),
                    );
                  },
                ),
                _buildQuickActionButton(
                  context,
                  icon: Icons.add_circle_outline,
                  label: 'Thu nhập',
                  color: DesignTokens.incomeGreen,
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AddTransactionScreen(
                          initialType: 'income',
                        ),
                      ),
                    );
                  },
                ),
                _buildQuickActionButton(
                  context,
                  icon: Icons.mic_outlined,
                  label: 'Giọng nói',
                  color: DesignTokens.pastelBlue,
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/voice-input');
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(DesignTokens.radiusMedium),
      child: Container(
        width: 100,
        padding: const EdgeInsets.symmetric(vertical: DesignTokens.spacing16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: color,
                size: 28,
              ),
            ),
            const SizedBox(height: DesignTokens.spacing8),
            Text(
              label,
              style: Theme.of(context).textTheme.labelMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        items: _navItems,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: DesignTokens.pastelBlue,
        unselectedItemColor: DesignTokens.textTertiary,
        showSelectedLabels: true,
        showUnselectedLabels: true,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTransactionModal,
        child: const Icon(Icons.add, size: DesignTokens.fabIconSize),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
