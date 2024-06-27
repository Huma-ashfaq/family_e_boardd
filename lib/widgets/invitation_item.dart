import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/invitation_model.dart';

// ignore: must_be_immutable
class InvitationItem extends StatelessWidget {
  InvitationItem({
    super.key,
    required this.invitationDetails,
    required this.removeInvitation,
  });

  final Invitation invitationDetails;
  final void Function(String id) removeInvitation;
  final firestore = FirebaseFirestore.instance;
  final firebasAuth = FirebaseAuth.instance;
  String? uid;

  void acceptInvitation() {
    firestore.collection('users').doc(uid).update({
      'sharedExpense':
          FieldValue.arrayUnion([invitationDetails.sharedExpenseId])
    });
    removeInvitation(invitationDetails.invitationId);
  }

  @override
  Widget build(BuildContext context) {
    uid = firebasAuth.currentUser!.uid;
    return Container(
      height: 80,
      padding: const EdgeInsets.fromLTRB(20, 0, 10, 0),
      // color: Colors.red,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                invitationDetails.sharedExpenseTitle,
                style: Theme.of(context).textTheme.titleMedium!.copyWith(
                    color: Theme.of(context).colorScheme.onBackground),
              ),
              Text(
                "Invited by ${invitationDetails.senderUsername}",
                style: Theme.of(context).textTheme.labelSmall!.copyWith(
                    color: Theme.of(context).colorScheme.onBackground),
              ),
            ],
          ),
          const Spacer(),
          TextButton(
            onPressed: () {
              removeInvitation(invitationDetails.invitationId);
            },
            child: const Text("Deny"),
          ),
          const SizedBox(width: 10),
          TextButton(
            onPressed: acceptInvitation,
            child: const Text("Accept"),
          ),
        ],
      ),
    );
  }
}
