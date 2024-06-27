import 'package:flutter/material.dart';
import 'package:icons_flutter/icons_flutter.dart';

enum IncomeCategory { salary, others, cash, upi }

Map<String, IconData> incomeCategoryIcon = {
  'salary': MaterialCommunityIcons.currency_usd,
  'cash': MaterialCommunityIcons.cash,
  'others': MaterialCommunityIcons.bank,
  'upi': MaterialCommunityIcons.bank_transfer,
  // 'salary': Icons.credit_card,
  // 'cash': Icons.payments_outlined,
  // 'others': Icons.currency_rupee,
  // 'upi': Icons.paypal,
};

class Income {
  Income({
    required this.id,
    required this.title,
    required this.amount,
    required this.category,
    required this.date,
    required this.time,
    this.isShared = false,
    this.username,
  }) : icon = incomeCategoryIcon[category.name]!;

  // final String date;

  final String title;
  final String? username;
  final String date;
  final String time;
  final double amount;
  final IncomeCategory category;
  final bool isShared;
  final String id;
  final IconData icon;
}
