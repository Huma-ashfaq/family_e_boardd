import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:meal_plan/Screens/Screensss/SettingScreen.dart';
import 'dart:io';

import '../Screens/invitations_screen.dart'; // Adjust import path as per your project structure

class SideDrawer extends StatefulWidget {
  const SideDrawer({Key? key}) : super(key: key);

  @override
  _SideDrawerState createState() => _SideDrawerState();
}

class _SideDrawerState extends State<SideDrawer> {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  File? _profileImage;

  Future<void> _pickProfileImage() async {
    final pickedImage =
    await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      setState(() {
        _profileImage = File(pickedImage.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context),
          const SizedBox(height: 16.0),
          _buildListTile(
            icon: Icons.privacy_tip,
            title: "Privacy Policy",
            onTap: () {
              _showPrivacyPolicyDialog(context);
            },
          ),
          _buildListTile(
            icon: Icons.star,
            title: "Rate App",
            onTap: () {
              _rateApp();
            },
          ),
          _buildListTile(
            icon: Icons.feedback,
            title: "Give Feedback",
            onTap: () {
              _giveFeedback();
            },
          ),
          _buildListTile(
            icon: Icons.share,
            title: "Share App",
            onTap: () {
              _shareApp();
            },
          ),
          _buildListTile(
            icon: Icons.logout,
            title: "Logout",
            onTap: () {
              _firebaseAuth.signOut();
            },
          ),
          const Spacer(),
          _buildListTile(
            icon: Icons.contact_support,
            title: "Contact Us",
            onTap: () {
              // Implement contact us logic
            },
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) => Container(
    color: Colors.teal,
    height: 150,
    alignment: Alignment.center,
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: _pickProfileImage,
          child: Stack(
            children: [
              CircleAvatar(
                radius: 35,
                backgroundImage: _profileImage != null
                    ? FileImage(_profileImage!)
                    : null,
                child: _profileImage == null
                    ? const Icon(Icons.person,
                    size: 45, color: Colors.white)
                    : null,
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.camera_alt,
                    size: 18,
                    color: Colors.purpleAccent,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8.0),
        Text(
          "Family eBoard",
          style: Theme.of(context).textTheme.headline6!.copyWith(
            color: Colors.white,
          ),
        ),
        const Text(
          "manage your budget here",
          style: TextStyle(color: Colors.white),
        ),
      ],
    ),
  );

  Widget _buildListTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) =>
      ListTile(
        leading: Icon(icon),
        title: Text(title),
        onTap: onTap,
      );

  void _showPrivacyPolicyDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Privacy Policy'),
        content: Text('Add your privacy policy text here.'),
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

  void _rateApp() {
    // Placeholder for rating app logic
  }

  void _giveFeedback() {
    // Placeholder for giving feedback logic
  }

  void _shareApp() {
    // Placeholder for sharing app logic
  }
}
