import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

import '../models/expense_model.dart';
import '../models/shared_expense_model.dart';


class NewExpenseScreen extends StatefulWidget {
  const NewExpenseScreen({
    super.key,
    this.sharedExpense,
    this.isShared = false,
  });
  final bool isShared;
  final SharedExpense? sharedExpense;

  @override
  State<StatefulWidget> createState() => _NewExpenseScreenState();
}

class _NewExpenseScreenState extends State<NewExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  final firestore = FirebaseFirestore.instance;
  final uuid = const Uuid();
  final firebaseAuth = FirebaseAuth.instance;
  String? enteredTitle;
  double? enteredAmount;
  ExpenseCategory? enteredCategory;
  DateTime? _selectedDate = DateTime.now();
  TimeOfDay? _selectedTime = TimeOfDay.now();
  String? uid;

  String? username;

  void getUsername() async {
    uid = firebaseAuth.currentUser!.uid;
    final snapshot = await firestore.collection('users').doc(uid).get();
    username = snapshot
        .data()!
        .entries
        .firstWhere((element) => element.key == 'username')
        .value;
  }

  @override
  void initState() {
    if (widget.isShared) {
      getUsername();
    }
    super.initState();
  }

  void _showDatePicker() async {
    HapticFeedback.lightImpact();
    final now = DateTime.now();
    final firstDate = DateTime(now.year - 1, now.month, now.day);
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: firstDate,
      lastDate: now,
    );

    setState(() {
      _selectedDate = pickedDate;
    });
  }

  void _showTimePicker() async {
    HapticFeedback.lightImpact();
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    setState(() {
      _selectedTime = pickedTime;
    });
  }

  String get formattedDate => DateFormat.d()
      .addPattern('/')
      .add_M()
      .addPattern('/')
      .add_y()
      .format(_selectedDate!);

  String get formattedTime => _selectedTime!.format(context);

  void submit() async {
    HapticFeedback.lightImpact();
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      uid = FirebaseAuth.instance.currentUser!.uid;

      final id = uuid.v4();
      if (widget.isShared) {
        firestore
            .collection("sharedExpenses")
            .doc(widget.sharedExpense!.id)
            .collection("expense")
            .doc(id)
            .set({
          'id': id,
          'title': enteredTitle,
          'amount': enteredAmount,
          'category': enteredCategory!.name,
          'date': formattedDate,
          'time': formattedTime,
          'username': username,
          'isShared': true,
        });
      } else {
        firestore
            .collection("users")
            .doc(uid)
            .collection("expense")
            .doc(id)
            .set({
          'id': id,
          'title': enteredTitle,
          'amount': enteredAmount,
          'category': enteredCategory!.name,
          'date': formattedDate,
          'time': formattedTime
        });
      }

      if (!context.mounted) {
        return;
      }

      Navigator.pop(
        context,
        widget.isShared
            ? Expense(
                id: id,
                title: enteredTitle!,
                amount: enteredAmount!,
                category: enteredCategory!,
                date: formattedDate,
                time: formattedTime,
                username: username,
                isShared: true,
              )
            : Expense(
                id: id,
                title: enteredTitle!,
                amount: enteredAmount!,
                category: enteredCategory!,
                date: formattedDate,
                time: formattedTime,
              ),
      );
    }
  }
  Color _getIconColor(ExpenseCategory category) {
    switch (category) {
      case ExpenseCategory.food:
        return Colors.green; // Set color for food category
      case ExpenseCategory.education:
        return Colors.blue; // Set color for education category
      case ExpenseCategory.entertainment:
        return Colors.purple; // Set color for entertainment category
      case ExpenseCategory.transport:
        return Colors.orange; // Set color for transport category
      case ExpenseCategory.health:
        return Colors.red; // Set color for health category
      case ExpenseCategory.shopping:
        return Colors.deepOrange; // Set color for shopping category
      case ExpenseCategory.others:
        return Colors.grey; // Set color for others category
      case ExpenseCategory.upi:
        return Colors.teal; // Set color for UPI category
      case ExpenseCategory.cash:
        return Colors.amber; // Set color for cash category
      default:
        return Colors.black; // Default color
    }
  }


  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: 'Expense Screen',
      child: Scaffold(
        appBar: AppBar(
          title: const Text('New Expense'),
          backgroundColor: Colors.blueGrey,
        ),
        body: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/watercolor bg.jpg'), // Replace with your image file path
              fit: BoxFit.cover,
            ),
          ),
          child: Form(
            key: _formKey,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Expense Title',
                    ),
                    textCapitalization: TextCapitalization.sentences,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter title';
                      }
                      return null;
                    },
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onBackground,
                    ),
                    onSaved: (newValue) {
                      enteredTitle = newValue;
                    },
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: TextFormField(
                          decoration: const InputDecoration(
                            labelText: 'Amount',
                            prefixText: 'RS ',
                            labelStyle: TextStyle(color: Colors.blue), // Change label text color to blue
                            prefixStyle: TextStyle(color: Colors.green), // Change prefix text color to green
                          ),
                          style: TextStyle(
                            color: Colors.black26,
                          ),
                          validator: (value) {
                            if (value == null ||
                                value.trim().isEmpty ||
                                double.tryParse(value) == null) {
                              return 'Please enter valid amount';
                            }
                            return null;
                          },
                          keyboardType: TextInputType.number,
                          onSaved: (newValue) {
                            enteredAmount = double.tryParse(newValue!);
                          },
                        ),
                      ),
                      const SizedBox(
                        width: 20,
                      ),
                      Expanded(
                        child: DropdownButtonFormField(
                          dropdownColor:
                              Colors.white,
                          onChanged: (value) {
                            enteredCategory = value;
                          },
                          onSaved: (newValue) {
                            enteredCategory = newValue;
                          },
                          value: ExpenseCategory.food,

                          items: [
                            for (final category in ExpenseCategory.values)
                              DropdownMenuItem(
                                value: category,
                                child: Row(
                                  children: [
                                    Icon(
                                      expenseCategoryIcon[category.name],
                                      color: _getIconColor(category),
                                    ),
                                    const SizedBox(width: 15),
                                    Text(
                                      category.name[0].toUpperCase() +
                                          category.name.substring(1),
                                      style: TextStyle(
                                        color: _getIconColor(category),

                                      ),
                                    )

                                  ],
                                ),
                              ),
                          ],
                        ),

                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      TextButton.icon(
                        onPressed: _showDatePicker,
                        label: Text(
                          _selectedDate == null
                              ? 'No date selected'
                              : formattedDate,
                        ),
                        icon: const Icon(Icons.calendar_month),
                      ),
                      TextButton.icon(
                        onPressed: _showTimePicker,
                        label: Text(
                          _selectedTime == null
                              ? 'No date selected'
                              : formattedTime,
                        ),
                        icon: const Icon(Icons.access_time),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Spacer(),
                      TextButton(
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          Navigator.pop(context);
                        },
                        child: const Text('Cancel'),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: submit,
                        style: ElevatedButton.styleFrom(
                            backgroundColor:Colors.cyan,

                            foregroundColor:
                                Theme.of(context).colorScheme.onPrimaryContainer),
                        child: const Text('Submit'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
