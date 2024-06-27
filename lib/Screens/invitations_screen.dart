import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/invitation_model.dart';
import '../widgets/invitation_item.dart';

class InvitationsScreen extends StatefulWidget {
  const InvitationsScreen({super.key});
  @override
  State<StatefulWidget> createState() => _InvitationsScreenState();
}

class _InvitationsScreenState extends State {
  final firestore = FirebaseFirestore.instance;
  final uid = FirebaseAuth.instance.currentUser!.uid;
  List<Invitation> invitationsList = [];
  String? email;
  bool isFetching = false;

  void removeInvitation(id) {
    firestore.collection('invitations').doc(id).update({
      'recipientEmail': FieldValue.arrayRemove([email])
    });

    setState(() {
      invitationsList.removeWhere((element) => element.invitationId == id);
    });
  }

  Future<String> getEmail() async {
    setState(() {
      isFetching = true;
    });
    final snapshot = await firestore.collection('users').doc(uid).get();

    email = (snapshot
        .data()!
        .entries
        .firstWhere((element) => element.key == 'email')
        .value);
    return email!;
  }

  void getInvitations() async {
    email = await getEmail();
    final snapshot = await firestore
        .collection('invitations')
        .where(
          'recipientEmail',
          arrayContains: email,
        )
        .get();

    // print(snapshot);
    // snapshot.docs.asMap().entries.any((element) {
    //   print(element.value.data());
    //   print(email);
    //   return true;
    // });

    setState(() {
      isFetching = false;
    });

    String? sharedExpenseId;
    String? senderUid;
    String? senderUsername;
    String? sharedExpenseTitle;

    if (snapshot.docs.isNotEmpty) {
      for (final invitations in snapshot.docs) {
        final invitationsMap = invitations.data();
        sharedExpenseId = invitationsMap['sharedExpenseId'];
        senderUid = invitationsMap['senderUid'];
        senderUsername = invitationsMap['senderUsername'];
        sharedExpenseTitle = invitationsMap['sharedExpenseTitle'];

        setState(() {
          invitationsList.add(Invitation(
            invitationId: invitations.id,
            sharedExpenseId: sharedExpenseId!,
            senderUid: senderUid!,
            senderUsername: senderUsername!,
            sharedExpenseTitle: sharedExpenseTitle!,
          ));
        });
      }
    }
  }

  @override
  void initState() {
    getInvitations();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Invitations'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          isFetching
              ? const Center(
                  child: CircularProgressIndicator(),
                )
              : invitationsList.isEmpty
                  ? Center(
                      child: Text(
                        "No Invitations",
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.onBackground),
                      ),
                    )
                  : Expanded(
                      child: ListView.builder(
                        itemCount: invitationsList.length,
                        itemBuilder: (context, index) => InvitationItem(
                          removeInvitation: removeInvitation,
                          key: ValueKey(invitationsList[index].invitationId),
                          invitationDetails: invitationsList[index],
                        ),
                      ),
                    )
        ],
      ),
    );
  }
}
