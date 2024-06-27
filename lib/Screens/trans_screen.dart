import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_expandable_fab/flutter_expandable_fab.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:icons_flutter/icons_flutter.dart';
import 'package:meal_plan/Screens/Screensss/ProfileScreen.dart';

import '../models/expense_model.dart';
import '../models/income_model.dart';
import '../models/shared_expense_model.dart';
import '../widgets/expense_list.dart';
import '../widgets/overview.dart';
import '../widgets/side_drawer.dart';
import 'new_expense_screen.dart';
import 'new_income_screen.dart';
const Color primaryColor = Color(0xFFC71585); // Medium violet red
const Color secondaryColor = Color(0xFF87CEEB); // Sky blue

// ignore: must_be_immutable
class TransScreen extends StatefulWidget {
  TransScreen({
    super.key,
    this.isShared = false,
    this.sharedExpense,
  });

  final bool isShared;
  final SharedExpense? sharedExpense;
  List<Expense> registeredExpense = [];
  List<Income> registeredIncome = [];
  List<dynamic> transactions = [];

  @override
  State<StatefulWidget> createState() => _TransScreen();
}

class _TransScreen extends State<TransScreen> {
  final firestore = FirebaseFirestore.instance;
  var isFetching = true;
  final uid = FirebaseAuth.instance.currentUser!.uid;

  @override
  void dispose() {
    super.dispose();
  }

  void removeExpense(item) {
    if (widget.isShared) {
      firestore
          .collection("sharedExpenses")
          .doc(widget.sharedExpense!.id)
          .collection("expense")
          .doc(item.id)
          .delete();
      setState(() {
        widget.transactions.remove(item);
        widget.registeredExpense.remove(item);
      });
    } else {
      firestore
          .collection("users")
          .doc(uid)
          .collection("expense")
          .doc(item.id)
          .delete();
      setState(() {
        widget.transactions.remove(item);
        widget.registeredExpense.remove(item);
      });
    }
  }

  void removeIncome(item) {
    if (widget.isShared) {
      firestore
          .collection("sharedExpenses")
          .doc(widget.sharedExpense!.id)
          .collection("income")
          .doc(item.id)
          .delete();
    } else {
      firestore
          .collection("users")
          .doc(uid)
          .collection("income")
          .doc(item.id)
          .delete();
    }
    setState(() {
      widget.transactions.remove(item);
      widget.registeredIncome.remove(item);
    });
  }

  void orderTransactions() {
    widget.transactions.sort((a, b) {
      final dateA = DateFormat('dd/MM/y').parse(a.date.replaceAll(' ', ''));
      final dateB = DateFormat('dd/MM/y').parse(b.date.replaceAll(' ', ''));

      // Compare the dates first
      int dateComparison = dateB.compareTo(dateA);
      if (dateComparison != 0) {
        return dateComparison;
      }

      // If the dates are the same, compare the times
      final timeA = DateFormat('hh:mm a').parse(a.time);
      final timeB = DateFormat('hh:mm a').parse(b.time);
      // DateFormat.
      return timeB.compareTo(timeA);
    });
  }

  dynamic expenseData;
  dynamic incomeData;
  var incomeSnapShot;
  var expenseSnapShot;

  void loadItem() async {
    setState(() {
      isFetching = true;
    });

    final uid = FirebaseAuth.instance.currentUser!.uid;

    if (widget.isShared) {
      incomeSnapShot = await firestore
          .collection("sharedExpenses")
          .doc(widget.sharedExpense!.id)
          .collection("income")
          .get();

      expenseSnapShot = await firestore
          .collection("sharedExpenses")
          .doc(widget.sharedExpense!.id)
          .collection("expense")
          .get();
    } else {
      incomeSnapShot = await firestore
          .collection("users")
          .doc(uid)
          .collection("income")
          .get();

      expenseSnapShot = await firestore
          .collection("users")
          .doc(uid)
          .collection("expense")
          .get();
    }

    if (!mounted) {
      return; // Check if the widget is still mounted before proceeding
    }

    setState(() {
      isFetching = false;
    });

    if (expenseSnapShot.docs.isNotEmpty) {
      expenseData = expenseSnapShot.docs.asMap();
    }

    if (incomeSnapShot.docs.isNotEmpty) {
      incomeData = incomeSnapShot.docs.asMap();
    }

    final List<Income> incomeLoadedItem = [];
    final List<Expense> expenseLoadedItem = [];
    late ExpenseCategory eCategory;
    late IncomeCategory iCategory;

    if (widget.isShared) {
      if (expenseData != null) {
        for (final item in expenseData.entries) {
          eCategory = ExpenseCategory.values.firstWhere((element) {
            return element.toString().split('.').last == item.value['category'];
          });

          expenseLoadedItem.add(
            Expense(
              id: item.value['id'],
              title: item.value['title'],
              amount: item.value['amount'],
              category: eCategory,
              date: item.value['date'],
              time: item.value['time'],
              isShared: item.value['isShared'],
              username: item.value['username'],
            ),
          );
        }
      }

      if (incomeData != null) {
        for (final item in incomeData.entries) {
          iCategory = IncomeCategory.values.firstWhere((element) {
            return element.toString().split('.').last == item.value['category'];
          });

          incomeLoadedItem.add(
            Income(
              id: item.value['id'],
              title: item.value['title'],
              amount: item.value['amount'],
              category: iCategory,
              date: item.value['date'],
              time: item.value['time'],
              isShared: item.value['isShared'],
              username: item.value['username'],
            ),
          );
        }
      }
    } else {
      if (expenseData != null) {
        for (final item in expenseData.entries) {
          eCategory = ExpenseCategory.values.firstWhere((element) {
            return element.toString().split('.').last == item.value['category'];
          });

          expenseLoadedItem.add(
            Expense(
              id: item.value['id'],
              title: item.value['title'],
              amount: item.value['amount'],
              category: eCategory,
              date: item.value['date'],
              time: item.value['time'],
            ),
          );
        }
      }

      if (incomeData != null) {
        for (final item in incomeData.entries) {
          iCategory = IncomeCategory.values.firstWhere((element) {
            return element.toString().split('.').last == item.value['category'];
          });

          incomeLoadedItem.add(
            Income(
              id: item.value['id'],
              title: item.value['title'],
              amount: item.value['amount'],
              category: iCategory,
              date: item.value['date'],
              time: item.value['time'],
            ),
          );
        }
      }
    }

    if (!mounted) {
      return; // Check if the widget is still mounted before calling setState
    }

    setState(() {
      widget.registeredExpense = expenseLoadedItem;
      widget.registeredIncome = incomeLoadedItem;
      widget.transactions = [
        ...widget.registeredExpense,
        ...widget.registeredIncome
      ];
      orderTransactions();
    });
  }

  @override
  void initState() {
    loadItem();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    timeDilation = 1.2;
    return Scaffold(
      drawer: widget.isShared ? null : const ProfileScreen (),
      appBar: AppBar(
        title: Text(
            widget.isShared ? widget.sharedExpense!.title : 'Personal Expense'),
            backgroundColor:Colors.black26,
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/watercolor bg.jpg'), // Replace with your image file path
            fit: BoxFit.cover,

          ),
        ),
        child: isFetching
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Overview(
                    registeredExpense: widget.registeredExpense,
                    registeredIncome: widget.registeredIncome,

                  ),
                  const Divider(),
                  Expanded(
                    child: widget.isShared
                        ? ExpenseList(
                            transactions: widget.transactions,
                            registeredExpense: widget.registeredExpense,
                            registeredIncome: widget.registeredIncome,
                            removeExpense: removeExpense,
                            removeIncome: removeIncome,
                            isShared: true,
                          )
                        : ExpenseList(
                            transactions: widget.transactions,
                            registeredExpense: widget.registeredExpense,
                            registeredIncome: widget.registeredIncome,
                            removeExpense: removeExpense,
                            removeIncome: removeIncome,
                          ),
                  ),
                ],
              ),
      ),
      floatingActionButtonLocation: ExpandableFab.location,
      floatingActionButton: ExpandableFab(
        overlayStyle: ExpandableFabOverlayStyle(blur: 6),
        distance: 90,
        child: Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [
                Theme.of(context).colorScheme.tertiary,
                Theme.of(context).colorScheme.onPrimary,
                Theme.of(context).colorScheme.onSecondary,

              ],
                transform: const GradientRotation(pi/4),
            ),
          ),
          child: const Icon(
            MaterialCommunityIcons.plus,
            color: Colors.purpleAccent,
          ),
        ),
        children: [
          FloatingActionButton.extended(
            heroTag: 'Expense Screen',
            label: const Text('Expense'),
            icon: const Icon(MaterialCommunityIcons.bank_transfer_out),
            onPressed: () async {
              HapticFeedback.lightImpact();
              final newItem = await Navigator.push<Expense>(
                context,
                MaterialPageRoute(
                  builder: (context) => widget.isShared
                      ? NewExpenseScreen(
                          isShared: true,
                          sharedExpense: widget.sharedExpense,
                        )
                      : const NewExpenseScreen(),
                ),
              );

              if (newItem == null) {
                return;
              }

              setState(() {
                widget.registeredExpense.add(newItem);
                widget.transactions.add(newItem);
                orderTransactions();
              });
            },
          ),
          FloatingActionButton.extended(
            heroTag: 'Income Screen',
            label: const Text('Income'),
            icon: const Icon(MaterialCommunityIcons.bank_transfer_in),
            onPressed: () async {
              HapticFeedback.lightImpact();

              final newItem = await Navigator.push<Income>(
                context,
                MaterialPageRoute(
                  builder: (context) => widget.isShared
                      ? NewIncomeScreen(
                          isShared: true,
                          sharedExpense: widget.sharedExpense,
                        )
                      : const NewIncomeScreen(),
                ),
              );

              if (newItem == null) {
                return;
              }
              setState(() {
                widget.registeredIncome.add(newItem);
                widget.transactions.add(newItem);
                orderTransactions();
              });
            },
          ),
        ],
      ),
        backgroundColor:secondaryColor.withOpacity(0.2),


    );
  }
}
