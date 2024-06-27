import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:icons_flutter/icons_flutter.dart';
import 'main_module_screen.dart';

class SignupScreen extends StatefulWidget {
  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _familyCodeController = TextEditingController();
  final _auth = FirebaseAuth.instance;
  bool _isCreatingFamily = false;
  String? _generatedFamilyCode;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/background.jpg', // Replace with your background image
            fit: BoxFit.cover,
          ),
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
            child: Container(
              color: Colors.black.withOpacity(0.5),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Create Account',
                  style: TextStyle(
                    fontSize: 32.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 32.0),
                TextField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    hintText: 'Email',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: EdgeInsets.all(16.0),
                  ),
                ),
                SizedBox(height: 16.0),
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    hintText: 'Password',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: EdgeInsets.all(16.0),
                  ),
                ),
                SizedBox(height: 16.0),
                SwitchListTile(
                  title: Text(
                    'Create a new family group',
                    style: TextStyle(color: Colors.white),
                  ),
                  value: _isCreatingFamily,
                  onChanged: (value) {
                    setState(() {
                      _isCreatingFamily = value;
                    });
                  },
                ),
                if (!_isCreatingFamily) ...[
                  TextField(
                    controller: _familyCodeController,
                    decoration: InputDecoration(
                      hintText: 'Family Code',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: EdgeInsets.all(16.0),
                    ),
                  ),
                  SizedBox(height: 16.0),
                ],
                ElevatedButton(
                  onPressed: () async {
                    await _signupUser();
                    _showFamilyCodeDialog(); // Show dialog after signing up
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.deepPurpleAccent,
                    padding: EdgeInsets.all(16.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  child: const Text('Sign Up'),
                ),
                SizedBox(height: 16.0),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('Already have an account? Login'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _signupUser() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final familyCode = _familyCodeController.text.trim();

    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;
      if (user != null) {
        // Save user data to Firestore
        if (_isCreatingFamily) {
          // Create a new family group
          final familyId = await _createNewFamily();
          // Save user with familyId
          await _saveUserToFirestore(user.uid, familyId);
        } else {
          // Join an existing family group
          if (familyCode.isNotEmpty) {
            // Validate family code and save user with familyId
            await _joinExistingFamily(user.uid, familyCode);
          } else {
            // Handle error for missing family code
            throw Exception('Family code is required to join an existing family group.');
          }
        }
      }
    } catch (e) {
      // Handle signup error
      print('Signup error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Signup failed. Please try again.')),
      );
    }
  }

  Future<String> _createNewFamily() async {
    // Implement Firestore logic to create a new family and return the familyId
    final familyRef = FirebaseFirestore.instance.collection('families').doc();
    await familyRef.set({
      'name': 'New Family',
      'members': [],
    });
    return familyRef.id;
  }

  Future<void> _saveUserToFirestore(String uid, String familyId) async {
    // Implement Firestore logic to save user data with the familyId
    await FirebaseFirestore.instance.collection('users').doc(uid).set({
      'familyId': familyId,
      'email': _emailController.text.trim(),
    });
  }

  Future<void> _joinExistingFamily
      (String uid, String familyCode) async {
    // Implement Firestore logic to join an existing family
    final familyRef = FirebaseFirestore.instance.collection('families').doc(familyCode);
    final familyDoc = await familyRef.get();
    if (familyDoc.exists) {
      await familyRef.update({
        'members': FieldValue.arrayUnion([uid]),
      });
      await _saveUserToFirestore(uid, familyCode);
    } else {
      throw Exception('Invalid family code.');
    }
  }

  void _showFamilyCodeDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Family Code'),
          content: Text('Your family code is: $_generatedFamilyCode'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }
}

