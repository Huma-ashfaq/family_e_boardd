import 'package:flutter/material.dart';
import 'package:icons_flutter/icons_flutter.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

enum ExpenseCategory {
  food,
  entertainment,
  education,
  transport,
  health,
  shopping,
  upi,
  cash,
  others
}

Map<String, dynamic> expenseCategoryIcon = {
  'food': MaterialCommunityIcons.hamburger,
  'education': MaterialCommunityIcons.school,
  'entertainment': MaterialCommunityIcons.theater,
  'transport': MaterialCommunityIcons.bus,
  'health': MaterialCommunityIcons.hospital_box,
  'shopping': MaterialCommunityIcons.shopping,
  'others': MaterialCommunityIcons.bank,
  'upi': MaterialCommunityIcons.bank_transfer,
  'cash': MaterialCommunityIcons.cash,
};

class Expense {
  Expense({
    required this.id,
    required this.title,
    required this.amount,
    required this.category,
    required this.date,
    required this.time,
    this.isShared = false,
    this.username,
  }) : icon = expenseCategoryIcon[category.toString().split('.').last]!,
        color = _getCategoryColor(category);

  final String id;
  final String title;
  final double amount;
  final ExpenseCategory category;
  final String date;
  final String time;
  final bool isShared;
  final String? username;
  final IconData icon;
  final Color color;

  static Color _getCategoryColor(ExpenseCategory category) {
    switch (category) {
      case ExpenseCategory.food:
        return Colors.green;
      case ExpenseCategory.education:
        return Colors.blue;
      case ExpenseCategory.entertainment:
        return Colors.purple;
      case ExpenseCategory.transport:
        return Colors.orange;
      case ExpenseCategory.health:
        return Colors.red;
      case ExpenseCategory.shopping:
        return Colors.deepOrange;
      case ExpenseCategory.others:
        return Colors.grey;
      case ExpenseCategory.upi:
        return Colors.teal;
      case ExpenseCategory.cash:
        return Colors.amber;
    }
  }
}
