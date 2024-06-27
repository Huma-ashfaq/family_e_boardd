import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../helper/helper_function.dart';
import 'database_service.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // LOGIN
  Future loginWithUserNameandPassword(String email, String password) async {
    try {
      User user = (await _auth.signInWithEmailAndPassword(
          email: email, password: password))
          .user!;

      if (user != null) {
        // Call our database service to update the user database if needed
        return true;
      }
    } on FirebaseAuthException catch (e) {
      return e.message;
    }
  }

  // REGISTER
  Future registerUserWithEmailandPassword(
      String fullName, String email, String password, String familyCode) async {
    try {
      User user = (await _auth.createUserWithEmailAndPassword(
          email: email, password: password))
          .user!;

      if (user != null) {
        // Call our database service to update the user database
        await DatabaseService(uid: user.uid).savingUserData(fullName, email, familyCode);
        return true;
      }
      return "An error occurred while registering";
    } on FirebaseAuthException catch (e) {
      return e.message;
    }
  }

  // SIGN OUT
  Future signOut() async {
    try {
      await HelperFunctions.saveUserLoggedInStatus(false);
      await HelperFunctions.saveUserEmailSF("");
      await HelperFunctions.saveUserNameSF("");
      await _auth.signOut();
    } catch (e) {
      return null;
    }
  }
}
