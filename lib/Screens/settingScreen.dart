import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';

class SettingScreen extends StatefulWidget {
  @override
  _SettingScreenState createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  final _firebaseAuth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  final _formKey = GlobalKey<FormState>();
  String? _userName;
  String? _userEmail;
  String? _userProfileImageUrl;
  File? _userProfileImageFile;
  bool _isDarkTheme = false;
  ThemeMode _themeMode = ThemeMode.system;

  @override
  void initState() {
    super.initState();
    _getUserProfile();
  }

  Future<void> _getUserProfile() async {
    final user = _firebaseAuth.currentUser;
    if (user != null) {
      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      if (userDoc.exists) {
        setState(() {
          _userName = userDoc.data()?['username'];
          _userEmail = userDoc.data()?['email'];
          _userProfileImageUrl = userDoc.data()?['profileImageUrl'];
        });
      }
    }
  }

  Future<void> _updateUserProfileImage() async {
    final imagePicker = ImagePicker();
    final pickedImage = await imagePicker.pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      final user = _firebaseAuth.currentUser;
      if (user != null) {
        setState(() {
          _userProfileImageFile = File(pickedImage.path);
        });

        final storageRef = FirebaseStorage.instance
            .ref()
            .child('user_profile_images')
            .child(user.uid + '.jpg');

        await storageRef.putFile(_userProfileImageFile!);

        final downloadUrl = await storageRef.getDownloadURL();

        await _firestore.collection('users').doc(user.uid).update({
          'profileImageUrl': downloadUrl,
        });

        setState(() {
          _userProfileImageUrl = downloadUrl;
        });
      }
    }
  }

  Future<void> _updateUserProfile() async {
    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState?.save();
      final user = _firebaseAuth.currentUser;
      if (user != null) {
        await _firestore.collection('users').doc(user.uid).update({
          'username': _userName,
          'email': _userEmail,
        });
      }
    }
  }

  void _toggleTheme(bool isDark) {
    setState(() {
      _isDarkTheme = isDark;
      _themeMode = _isDarkTheme ? ThemeMode.dark : ThemeMode.light;
    });
  }

  void _showPrivacyPolicy() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Privacy Policy'),
        content: Text('This is the privacy policy of the app.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  void _rateApp() async {
    const url = 'market://details?id=com.example.your_app_id';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  void _giveFeedback() async {
    const emailAddress = 'mailto:support@example.com';
    if (await canLaunch(emailAddress)) {
      await launch(emailAddress);
    } else {
      throw 'Could not launch $emailAddress';
    }
  }

  void _shareApp() {
    const shareMessage = 'Check out this awesome app!';
    Share.share(shareMessage);
  }

  void _launchUrl(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
        backgroundColor: Colors.blueGrey,
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/watercolor bg.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                GestureDetector(
                  onTap: _updateUserProfileImage,
                  child: CircleAvatar(
                    backgroundImage: _userProfileImageUrl != null
                        ? NetworkImage(_userProfileImageUrl!)
                        : AssetImage('assets/images/family.png') as ImageProvider,
                    radius: 50.0,
                  ),
                ),
                SizedBox(height: 20.0),
                TextFormField(
                  initialValue: _userName,
                  decoration: InputDecoration(labelText: 'Username'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your username';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _userName = value;
                  },
                ),
                TextFormField(
                  initialValue: _userEmail,
                  decoration: InputDecoration(labelText: 'Email'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _userEmail = value;
                  },
                ),
                SizedBox(height: 20.0),
                ElevatedButton(
                  onPressed: _updateUserProfile,
                  child: Text('Update Profile'),
                ),
                SizedBox(height: 20.0),
                ListTile(
                  title: Text('Privacy Policy'),
                  leading: Icon(Icons.security),
                  onTap: _showPrivacyPolicy,
                ),
                ListTile(
                  title: Text('Rate App'),
                  leading: Icon(Icons.star),
                  onTap: _rateApp,
                ),
                ListTile(
                  title: Text('Give Feedback'),
                  leading: Icon(Icons.feedback),
                  onTap: _giveFeedback,
                ),
                ListTile(
                  title: Text('Share App'),
                  leading: Icon(Icons.share),
                  onTap: _shareApp,
                ),
                SizedBox(height: 20.0),
                SwitchListTile(
                  title: Text('Dark Theme'),
                  value: _isDarkTheme,
                  onChanged: _toggleTheme,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
