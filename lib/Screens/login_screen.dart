// import 'dart:ui';
//
// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
//
// import 'main_module_screen.dart';
//
// class LoginScreen extends StatefulWidget {
//   @override
//   _LoginScreenState createState() => _LoginScreenState();
// }
//
// class _LoginScreenState extends State<LoginScreen> {
//   final _emailController = TextEditingController();
//   final _passwordController = TextEditingController();
//   final _auth = FirebaseAuth.instance;
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Stack(
//         fit: StackFit.expand,
//         children: [
//           Image.asset(
//             'assets/images/watercolor bg.jpg', // Replace with your background image
//             fit: BoxFit.cover,
//           ),
//     //       BackdropFilter(
//     //         filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
//     //         child: Container(
//     //           color: Colors.black.withOpacity(0.5),
//     // ),
//     //       ),
//           Padding(
//             padding: EdgeInsets.all(16.0),
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               crossAxisAlignment: CrossAxisAlignment.stretch,
//               children: [
//                 const Text(
//                   'Welcome Back!',
//                   style: TextStyle(
//                     fontSize: 32.0,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.white,
//                   ),
//                   textAlign: TextAlign.center,
//                 ),
//                 SizedBox(height: 32.0),
//                 TextField(
//                   controller: _emailController,
//                   decoration: InputDecoration(
//                     hintText: 'Email',
//                     filled: true,
//                     fillColor: Colors.white,
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(8.0),
//                       borderSide: BorderSide.none,
//                     ),
//                     contentPadding: EdgeInsets.all(16.0),
//                   ),
//                 ),
//                 SizedBox(height: 16.0),
//                 TextField(
//                   controller: _passwordController,
//                   obscureText: true,
//                   decoration: InputDecoration(
//                     hintText: 'Password',
//                     filled: true,
//                     fillColor: Colors.white,
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(8.0),
//                       borderSide: BorderSide.none,
//                     ),
//                     contentPadding: EdgeInsets.all(16.0),
//                   ),
//                 ),
//                 SizedBox(height: 32.0),
//                 ElevatedButton(
//                   onPressed: _loginUser,
//                   style: ElevatedButton.styleFrom(
//                     foregroundColor: Colors.white,
//                     backgroundColor: Colors.deepPurpleAccent,
//                     padding: EdgeInsets.all(16.0),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(8.0),
//                     ),
//                   ),
//                   child: const Text('Login'),
//                 ),
//                 SizedBox(height: 16.0),
//                 TextButton(
//                   onPressed: () {
//                     Navigator.pushNamed(context, '/signup');
//                   },
//                   child: Text('Don\'t have an account? Sign up'),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Future<void> _loginUser() async {
//     final email = _emailController.text.trim();
//     final password = _passwordController.text.trim();
//
//     try {
//       await _auth.signInWithEmailAndPassword(
//         email: email,
//         password: password,
//       );
//       // Navigate to the main module screen or other actions
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(builder: (context) => ModuleScreen()),
//       );
//     } catch (e) {
//       // Handle login error
//       print('Login error: $e');
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Login failed. Please try again.')),
//       );
//     }
//   }
// }