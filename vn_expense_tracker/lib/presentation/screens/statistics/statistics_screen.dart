// lib/presentation/screens/statistics/statistics_screen.dart
import 'package:flutter/material.dart';

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Thống kê')),
      body: const Center(child: Text('Thống kê chi tiêu')),
    );
  }
}
