import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

import '../models/income_model.dart';
import '../models/shared_expense_model.dart';


class NewIncomeScreen extends StatefulWidget {
  const NewIncomeScreen({
    super.key,
    this.sharedExpense,
    this.isShared = false,
  });

  final bool isShared;
  final SharedExpense? sharedExpense;

  @override
  State<StatefulWidget> createState() => _NewIncomeScreenState();
}

class _NewIncomeScreenState extends State<NewIncomeScreen> {
  final _formKey = GlobalKey<FormState>();

  String? enteredTitle;
  final uuid = const Uuid();
  double? enteredAmount;
  final firebaseAuth = FirebaseAuth.instance;

  IncomeCategory? enteredCategory;

  DateTime? _selectedDate = DateTime.now();
  TimeOfDay? _selectedTime = TimeOfDay.now();
  final firestore = FirebaseFirestore.instance;
  String? username;

  void getUsername() async {
    final uid = firebaseAuth.currentUser!.uid;
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
    final now = DateTime.now();
    final firstDate = DateTime(now.year - 1, now.month, now.day);
    final pickedDate = await showDatePicker(
        context: context,
        initialDate: now,
        firstDate: firstDate,
        lastDate: now);

    setState(() {
      _selectedDate = pickedDate;
    });
  }

  String get formattedDate => DateFormat.d()
      .addPattern('/')
      .add_M()
      .addPattern('/')
      .add_y()
      .format(_selectedDate!);

  void _showTimePicker() async {
    HapticFeedback.lightImpact();
    final now = TimeOfDay.now();
    final pickedTime = await showTimePicker(context: context, initialTime: now);

    setState(() {
      _selectedTime = pickedTime;
    });
  }

  String get formattedTime => _selectedTime!.format(context);

  void submit() async {
    HapticFeedback.lightImpact();
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final uid = FirebaseAuth.instance.currentUser!.uid;
      final id = uuid.v4();

      if (widget.isShared) {
        firestore
            .collection("sharedExpenses")
            .doc(widget.sharedExpense!.id)
            .collection("income")
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
            .collection("income")
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
            ? Income(
                id: id,
                title: enteredTitle!,
                amount: enteredAmount!,
                category: enteredCategory!,
                date: formattedDate,
                time: formattedTime,
                username: username,
                isShared: true,
              )
            : Income(
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

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: 'Income Screen',
      child: Scaffold(
        appBar: AppBar(
          title: const Text('New Income'),
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
                      labelText: 'Income Title',
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
                          ),
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onBackground,
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
                          value: IncomeCategory.cash,
                          items: [
                            for (final category in IncomeCategory.values)
                              DropdownMenuItem(
                                value: category,
                                child: Row(
                                  children: [
                                    Icon(
                                      incomeCategoryIcon[category.name],
                                    ),
                                    const SizedBox(width: 15),
                                    Text(
                                      category.name[0].toUpperCase() +
                                          category.name.substring(1),
                                      style: TextStyle(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSecondaryContainer),
                                    ),
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
