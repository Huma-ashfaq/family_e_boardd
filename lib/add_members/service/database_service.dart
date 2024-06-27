import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseService {
  final String? uid;
  DatabaseService({this.uid});

  // Reference to the collections
  final CollectionReference userCollection = FirebaseFirestore.instance.collection('users');
  final CollectionReference groupCollection = FirebaseFirestore.instance.collection('groups');

  // Saving user data
  Future savingUserData(String fullName, String email, String familyCode) async {
    return await userCollection.doc(uid).set({
      'fullName': fullName,
      'email': email,
      'familyCode': familyCode,
      'groups': [],
    });
  }

  // Getting user groups
  Stream<DocumentSnapshot> getUserGroups() {
    return userCollection.doc(uid).snapshots();
  }

  // Creating a group with a 4-digit code
  Future createGroup(String userName, String uid, String groupName, String groupCode) async {
    DocumentReference groupDocumentReference = await groupCollection.add({
      'groupName': groupName,
      'admin': '${uid}_$userName',
      'members': [],
      'groupId': '',
      'groupCode': groupCode,
      'recentMessage': '',
      'recentMessageSender': '',
    });

    await groupDocumentReference.update({
      'members': FieldValue.arrayUnion(['${uid}_$userName']),
      'groupId': groupDocumentReference.id,
    });

    DocumentReference userDocumentReference = userCollection.doc(uid);
    return await userDocumentReference.update({
      'groups': FieldValue.arrayUnion(['${groupDocumentReference.id}_$groupName']),
    });
  }

  // Getting group members
  Stream<DocumentSnapshot> getGroupMembers(String groupId) {
    return groupCollection.doc(groupId).snapshots();
  }

  // Toggling group join
  Future toggleGroupJoin(String groupId, String userName, String groupName) async {
    DocumentReference userDocumentReference = userCollection.doc(uid);
    DocumentReference groupDocumentReference = groupCollection.doc(groupId);

    DocumentSnapshot userSnapshot = await userDocumentReference.get();
    List<dynamic> groups = await userSnapshot['groups'];

    if (groups.contains('${groupId}_$groupName')) {
      await userDocumentReference.update({
        'groups': FieldValue.arrayRemove(['${groupId}_$groupName'])
      });
      await groupDocumentReference.update({
        'members': FieldValue.arrayRemove(['${uid}_$userName'])
      });
    } else {
      await userDocumentReference.update({
        'groups': FieldValue.arrayUnion(['${groupId}_$groupName'])
      });
      await groupDocumentReference.update({
        'members': FieldValue.arrayUnion(['${uid}_$userName'])
      });
    }
  }

  // Getting group chats
  Future<Stream<QuerySnapshot>> getChats(String groupId) async {
    return groupCollection
        .doc(groupId)
        .collection('messages')
        .orderBy('time', descending: true)
        .snapshots();
  }

  // Getting group admin
  Future<String> getGroupAdmin(String groupId) async {
    DocumentReference docRef = groupCollection.doc(groupId);
    DocumentSnapshot docSnapshot = await docRef.get();
    return docSnapshot['admin'];
  }

  // Sending messages
  Future sendMessage(String groupId, Map<String, dynamic> chatMessageData) async {
    groupCollection.doc(groupId).collection('messages').add(chatMessageData);
    groupCollection.doc(groupId).update({
      'recentMessage': chatMessageData['message'],
      'recentMessageSender': chatMessageData['sender'],
      'recentMessageTime': chatMessageData['time'],
    });
  }

  // Getting user data
  Future<QuerySnapshot> gettingUserData(String email) async {
    return await userCollection.where('email', isEqualTo: email).get();
  }

  // Search groups by name
  Future<QuerySnapshot> searchByName(String groupName) async {
    return await groupCollection.where('groupName', isEqualTo: groupName).get();
  }

  // Check if user is joined to a group
  Future<bool> isUserJoined(String groupName, String groupId, String userName) async {
    DocumentSnapshot querySnapshot = await userCollection.doc(uid).get();
    List<dynamic> groups = querySnapshot['groups'];
    bool isJoined = groups.contains('${groupId}_$groupName');
    return isJoined;
  }

  // Verify group code
  Future<bool> verifyGroupCode(String groupCode) async {
    QuerySnapshot result = await groupCollection.where('groupCode', isEqualTo: groupCode).get();
    return result.docs.isNotEmpty;
  }
}
