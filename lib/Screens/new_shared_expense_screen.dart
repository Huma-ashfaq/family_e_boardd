import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../models/shared_expense_model.dart';

class NewSharedExpenseScreen extends StatefulWidget {
  const NewSharedExpenseScreen({super.key});
  @override
  State<StatefulWidget> createState() => _NewSharedExpenseScreenState();
}

class _NewSharedExpenseScreenState extends State {
  // Variables
  final uuid = const Uuid();
  final _newSharedExpenseFormKey = GlobalKey<FormState>();
  TextEditingController inviteeEmail = TextEditingController();
  String? enteredTitle;
  List<String> membersEmail = [];
  final firestore = FirebaseFirestore.instance;
  final firebaseAuth = FirebaseAuth.instance;
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

  void addMember() {
    if (_newSharedExpenseFormKey.currentState!.validate()) {
      _newSharedExpenseFormKey.currentState!.save();
    }
  }

  @override
  void initState() {
    getUsername();
    super.initState();
  }

  void createSharedExpense() {
    final uid = firebaseAuth.currentUser!.uid;
    final id = uuid.v4();
    firestore.collection("sharedExpenses").doc(id).set({
      'title': enteredTitle,
      'membersEmail': membersEmail,
    });
    firestore.collection('users').doc(uid).update({
      'sharedExpense': FieldValue.arrayUnion([id])
    });
    firestore.collection('invitations').doc().set({
      'senderUid': uid,
      'recipientEmail': membersEmail,
      'sharedExpenseId': id,
      'senderUsername': username,
      'sharedExpenseTitle': enteredTitle,
    });
    Navigator.pop(
      context,
      SharedExpense(id: id, title: enteredTitle!, membersEmail: membersEmail),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Variables

    return Scaffold(
      appBar: AppBar(
        title: const Text("New Expense"),
        backgroundColor: Colors.blueGrey,
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/watercolor bg.jpg'), // Replace with your image file path
            fit: BoxFit.cover,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            children: [
              Form(
                key: _newSharedExpenseFormKey,
                child: Column(
                  children: [
                    TextFormField(
                      decoration: const InputDecoration(labelText: "Title"),
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.onBackground),
                      validator: (str) {
                        if (str == null || str.isEmpty) {
                          return "Invalid title";
                        }
                        return null;
                      },
                      onSaved: (newValue) {
                        enteredTitle = newValue;
                      },
                    ),
                    TextFormField(
                      keyboardType: TextInputType.emailAddress,
                      controller: inviteeEmail,
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.onBackground),
                      decoration: const InputDecoration(
                        labelText: "Invitee Email",
                      ),
                      validator: (str) {
                        if (str == null || str.isEmpty || !str.contains("@")) {
                          return "Invalid Email";
                        }
                        return null;
                      },
                      onSaved: (newValue) {
                        setState(() {
                          membersEmail.add(newValue!);
                          inviteeEmail.text = "";
                        });
                      },
                    ),
                  ],
                ),
              ),
              Container(
                height: 100,
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Theme.of(context).colorScheme.primary,
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                margin: const EdgeInsets.fromLTRB(0, 30, 0, 10),
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Members",
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.onBackground),
                    ),
                    Expanded(
                      child: membersEmail.length == 0
                          ? Center(
                              child: Text(
                                "No members added",
                                style: TextStyle(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .surfaceTint),
                              ),
                            )
                          : ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: membersEmail.length,
                              itemBuilder: (context, index) {
                                return Container(
                                  padding:
                                      const EdgeInsets.fromLTRB(10, 3, 10, 3),
                                  margin:
                                      const EdgeInsets.fromLTRB(0, 10, 10, 10),
                                  decoration: BoxDecoration(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .secondaryContainer,
                                      borderRadius: BorderRadius.circular(10)),
                                  child: Center(
                                      child: Text(
                                    membersEmail[index],
                                    style: TextStyle(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSecondaryContainer),
                                  )),
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  Spacer(),
                  TextButton(
                    onPressed: addMember,
                    child: const Text("Add Member"),
                  ),
                  const SizedBox(
                    width: 20,
                  ),
                  ElevatedButton(
                    onPressed: membersEmail.isEmpty ? null : createSharedExpense,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.cyan,
                      foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    ),
                    child: const Text("Invite"),
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
