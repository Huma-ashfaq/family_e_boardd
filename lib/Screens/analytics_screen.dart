import 'package:flutter/material.dart';
import '../models/expense_model.dart';
import '../models/income_model.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({
    super.key,
    required this.registeredExpense,
    required this.registeredIncome,
    required this.transactions,

  });
  final List<Income> registeredIncome;
  final List<Expense> registeredExpense;
  final List<dynamic> transactions;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Analytics'),
      ),
    );
  }
}
