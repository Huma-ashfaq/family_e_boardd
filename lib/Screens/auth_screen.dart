import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:icons_flutter/icons_flutter.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<StatefulWidget> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  var isAuthenticating = false;
  var isLogin = true;
  final _formKey = GlobalKey<FormState>();
  late String _enteredEmail;
  late String _enteredPassword;
  late String _enteredUsername;
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  final firebaseAuth = FirebaseAuth.instance;
  final fireStore = FirebaseFirestore.instance;

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      try {
        setState(() {
          isAuthenticating = true;
        });

        if (isLogin) {
          // User login
          await firebaseAuth.signInWithEmailAndPassword(
              email: _enteredEmail, password: _enteredPassword);
        } else {
          // User signup
          final userCredentials = await firebaseAuth.createUserWithEmailAndPassword(
              email: _enteredEmail, password: _enteredPassword);

          // Save user information to Firestore
          await _saveUserToFirestore(userCredentials.user!.uid);
        }

        setState(() {
          isAuthenticating = false;
        });
      } on FirebaseAuthException catch (error) {
        if (!mounted) {
          return;
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              error.code.toString()[0].toUpperCase() +
                  error.code.toString().substring(1).replaceAll('-', ' '),
            ),
          ),
        );
        setState(() {
          isAuthenticating = false;
        });
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error.toString()),
          ),
        );
        setState(() {
          isAuthenticating = false;
        });
      }
    }
  }

  Future<void> _saveUserToFirestore(String uid) async {
    // Save user information to Firestore
    await fireStore.collection('users').doc(uid).set({
      'email': _enteredEmail,
      'username': _enteredUsername,
    });
  }

  Future<void> _resetPassword() async {
    final email = _emailController.text;
    if (email.isEmpty || !email.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter a valid email address to reset password.'),
        ),
      );
      return;
    }

    try {
      await firebaseAuth.sendPasswordResetEmail(email: email);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Password reset email sent! Check your email.'),
        ),
      );
    } on FirebaseAuthException catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            error.code.toString()[0].toUpperCase() +
                error.code.toString().substring(1).replaceAll('-', ' '),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget content = Padding(
      padding: const EdgeInsets.fromLTRB(50, 25, 50, 0),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            Text(
              isLogin ? 'Login' : 'Signup',
              style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
            ),
            TextFormField(
              decoration: const InputDecoration(labelText: 'Email'),
              controller: _emailController,
              style: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimaryContainer),
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null ||
                    !value.contains('@') ||
                    value.trim().isEmpty) {
                  return 'Enter a valid email';
                }
                return null;
              },
              onSaved: (newValue) {
                _enteredEmail = newValue!;
              },
            ),
            if (!isLogin)
              TextFormField(
                decoration: const InputDecoration(labelText: 'Username'),
                controller: _usernameController,
                style: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimaryContainer),
                validator: (value) {
                  if (value == null || value.trim().length < 3) {
                    return 'Username must be greater than 2 characters';
                  }
                  return null;
                },
                onSaved: (newValue) {
                  _enteredUsername = newValue!;
                },
              ),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Password',
              ),
              controller: _passwordController,
              style: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimaryContainer),
              obscureText: true,
              validator: (value) {
                if (value == null || value.trim().length < 6) {
                  return 'Password must be at least 6 characters';
                }
                return null;
              },
              onSaved: (newValue) {
                _enteredPassword = newValue!;
              },
            ),
            if (!isLogin)
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Confirm Password',
                ),
                style: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimaryContainer),
                obscureText: true,
                validator: (value) {
                  if (value == null ||
                      value.trim().length < 6 ||
                      _passwordController.text != value) {
                    return 'Passwords do not match';
                  }
                  return null;
                },
                onSaved: (newValue) {
                  _enteredPassword = newValue!;
                },
              ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromRGBO(191, 96, 165, 1.0),
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
              ),
              child: isAuthenticating
                  ? SizedBox(
                height: 25,
                width: 25,
                child: CircularProgressIndicator(
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
              )
                  : Text(isLogin ? 'Login' : 'Signup'),
            ),
            const SizedBox(height: 5),
            TextButton(
              onPressed: () {
                setState(() {
                  _usernameController.clear();
                  _passwordController.clear();
                  _emailController.clear();
                  isLogin = !isLogin;
                });
              },
              child: Text(
                isLogin ? 'Create an account' : 'Already a user? Login!',
                style: TextStyle(
                  color: const Color.fromRGBO(191, 96, 165, 1.0),
                ),
              ),
            ),
            if (isLogin)
              TextButton(
                onPressed: _resetPassword,
                child: Text(
                  'Forgot Password?',
                  style: TextStyle(
                    color: const Color.fromRGBO(191, 96, 165, 1.0),
                  ),
                ),
              ),
          ],
        ),
      ),
    );

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/watercolor bg.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 60),
              Icon(
                MaterialCommunityIcons.flower_tulip_outline,
                size: 200,
                color: const Color.fromRGBO(191, 96, 165, 1.0),
              ),
              Text(
                ' Family e Board',
                style: Theme.of(context)
                    .textTheme
                    .displayMedium!
                    .copyWith(color: Theme.of(context).colorScheme.onBackground),
              ),
              const SizedBox(height: 30),
              content,
            ],
          ),
        ),
      ),
    );
  }
}
