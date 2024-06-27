import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> addMember(BuildContext context, String name, String email) async {
    try {
      await _db.collection('members').add({
        'name': name,
        'email': email,
        'permissions': {'budget': 'view', 'meal': 'edit', 'settings': 'none'}
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Member added successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add member: $e')),
      );
    }
  }

  Future<void> updateMember(BuildContext context, String uid, Map<String, String> permissions) async {
    try {
      await _db.collection('members').doc(uid).update({'permissions': permissions});
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Member updated successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update member: $e')),
      );
    }
  }

  Future<void> deleteMember(BuildContext context, String uid) async {
    try {
      await _db.collection('members').doc(uid).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Member deleted successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete member: $e')),
      );
    }
  }

  Stream<QuerySnapshot> getMembers() {
    return _db.collection('members').snapshots();
  }
}
