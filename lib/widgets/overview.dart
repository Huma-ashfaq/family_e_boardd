import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/expense_model.dart';
import '../models/income_model.dart';


class Overview extends StatefulWidget {
  const Overview({
    super.key,
    required this.registeredExpense,
    required this.registeredIncome,
  });
  @override
  State<StatefulWidget> createState() {
    return _OverviewState();
  }

  final List<Expense> registeredExpense;
  final List<Income> registeredIncome;
}

class _OverviewState extends State<Overview> {
  double get availableMoney {
    var expense = 0.0;
    var income = 0.0;
    for (final item in widget.registeredExpense) {
      expense += item.amount;
    }
    for (final item in widget.registeredIncome) {
      income += item.amount;
    }
    return income - expense;
  }

  double get monthExpense {
    var expense = 0.0;
    for (final item in widget.registeredExpense) {
      if (DateFormat('dd/MM/y')
          .parse(item.date.replaceAll(' ', ''))
          .month ==
          DateTime
              .now()
              .month) {
        expense += item.amount;
      }
    }
    return expense;
  }

  double get dayExpense {
    var expense = 0.0;
    for (final item in widget.registeredExpense) {
      if (DateFormat('dd/MM/y')
          .parse(item.date.replaceAll(' ', ''))
          .day ==
          DateTime
              .now()
              .day) {
        expense += item.amount;
      }
    }
    return expense;
  }

  double get monthIncome {
    var expense = 0.0;
    for (final item in widget.registeredIncome) {
      if (DateFormat('dd/MM/y')
          .parse(item.date.replaceAll(' ', ''))
          .month ==
          DateTime
              .now()
              .month) {
        expense += item.amount;
      }
    }
    return expense;
  }

  double get dayIncome {
    var expense = 0.0;
    for (final item in widget.registeredIncome) {
      if (DateFormat('dd/MM/y')
          .parse(item.date.replaceAll(' ', ''))
          .day ==
          DateTime
              .now()
              .day) {
        expense += item.amount;
      }
    }
    return expense;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 230,
      child: Column(
        children: [
          const Divider(height: 1),
          const SizedBox(height: 5),
          IntrinsicHeight(
            child: Container(
              color: Colors.white,
              // Set the background color here
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Column(
                    children: [
                      Text(
                        'Total Expense',
                        style: TextStyle(
                          color: Colors.blueGrey,
                          fontSize: 20,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        DateFormat.MMMM().format(DateTime.now()),
                        style: TextStyle(
                          color: Theme
                              .of(context)
                              .colorScheme
                              .onBackground,
                          fontSize: 20,
                        ),
                      ),
                      Text(
                        'Rs $monthExpense',
                        style: const TextStyle(
                          color: Colors.blueGrey,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        ' Today ',
                        style: TextStyle(
                          color: Theme
                              .of(context)
                              .colorScheme
                              .onBackground,
                          fontSize: 20,
                        ),
                      ),
                      Text(
                        'Rs $dayExpense',
                        style: const TextStyle(
                          color: Colors.blueGrey,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const VerticalDivider(),
                  Column(
                    children: [
                      Text(
                        ' Total Income ',
                        style: TextStyle(
                          color: Colors.blueGrey,
                          fontSize: 20,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        DateFormat.MMMM().format(DateTime.now()),
                        style: TextStyle(
                          color: Theme
                              .of(context)
                              .colorScheme
                              .onBackground,
                          fontSize: 20,
                        ),
                      ),
                      Text(
                        'Rs $monthIncome',
                        style: const TextStyle(
                          color: Colors.blueGrey,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        ' Today ',
                        style: TextStyle(
                          color: Theme
                              .of(context)
                              .colorScheme
                              .onBackground,
                          fontSize: 20,
                        ),
                      ),
                      Text(
                        ' Rs $dayIncome',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blueGrey,
                          fontSize: 20,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 5),
          Container(
            color: Colors.grey.withOpacity(0.1),
            // Set the background color here
            child: Container(
              color: Colors.white.withOpacity(0.4),
              child: Column(
                children: [
                  Text(
                    'Available Money',
                    style: TextStyle(
                      color: Colors.purple,
                      fontSize: 20,
                    ),
                  ),
                  Text(
                    ' Rs $availableMoney',
                    style: TextStyle(
                      color: availableMoney > 0 ? Colors.blueGrey : Colors
                          .blueGrey,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
