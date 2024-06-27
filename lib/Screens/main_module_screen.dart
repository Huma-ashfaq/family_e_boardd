import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:meal_plan/Screens/Screensss/ProfileScreen.dart';
import 'package:meal_plan/Screens/Screensss/add_meal_screen.dart';
import 'package:meal_plan/Screens/main_screen.dart';
import 'package:meal_plan/Screens/new_expense_screen.dart';
import 'package:meal_plan/Screens/new_income_screen.dart';
import 'package:meal_plan/Screens/new_shared_expense_screen.dart';
import 'package:meal_plan/add_members/ingredinets.dart';
import 'package:meal_plan/add_members/pages/auth/search_page.dart';
import 'package:meal_plan/add_members/pages/home_page.dart';
import 'package:meal_plan/screens/auth_screen.dart';
import 'package:meal_plan/to-do-list/screen/home.dart';


const DEVELOPER_EMAIL_1 = 'Huma@gmail.com';
const DEVELOPER_EMAIL_2 = 'Memoona@gmail.com';

ThemeMode _themeMode = ThemeMode.system;

class ModuleScreen extends StatefulWidget {
  @override
  _ModuleScreenState createState() => _ModuleScreenState();
}

class _ModuleScreenState extends State<ModuleScreen> {
  final _firebaseAuth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  String? _userName;
  String? _userEmail;
  String? _userProfileImageUrl;
  File? _userProfileImageFile;

  @override
  void initState() {
    super.initState();
    _checkAuthState();
  }

  Future<void> _checkAuthState() async {
    final currentUser = _firebaseAuth.currentUser;
    if (currentUser == null) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => AuthScreen()),
      );
    } else {
      _getUserProfile();
    }
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

  Future<void> _signOut() async {
    await _firebaseAuth.signOut();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => AuthScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Family eBoard'),
        backgroundColor: Colors.blueGrey,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            UserAccountsDrawerHeader(
              accountName: Text(_userName ?? ''),
              accountEmail: Text(_userEmail ?? ''),
              currentAccountPicture: GestureDetector(
                onTap: _updateUserProfileImage,
                child: CircleAvatar(
                  backgroundImage: _userProfileImageUrl != null
                      ? NetworkImage(_userProfileImageUrl!)
                      : AssetImage('assets/images/family.png') as ImageProvider,
                  radius: 15.0,
                ),
              ),
              decoration: BoxDecoration(
                color: Colors.teal,
              ),
            ),
            ListTile(
              title: Text('To-do-list'),
              leading: Icon(Icons.list_alt_rounded),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Home_Screen()),
                );
              },
            ),
            ListTile(
              title: Text('Settings'),
              leading: Icon(Icons.settings),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ProfileScreen()),
                );
              },
            ),
            ListTile(
              title: Text('About Us'),
              leading: Icon(Icons.info),
              onTap: () {
                Navigator.pop(context);
                showAboutUsDialog(context);
              },
            ),
            Divider(),
            ListTile(
              title: Text('Theme'),
              leading: Icon(Icons.brightness_4),
              trailing: Switch(
                value: _themeMode == ThemeMode.dark,
                onChanged: (value) {
                  setState(() {
                    _themeMode = value ? ThemeMode.dark : ThemeMode.light;
                  });
                },
              ),
            ),
            ListTile(
              title: Text('Logout'),
              leading: Icon(Icons.exit_to_app),
              onTap: _signOut,
            ),
          ],
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/watercolor bg.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          children: [
            UserProfileSection(
              userName: _userName ?? '',
              userEmail: _userEmail ?? '',
              userProfileImageUrl: _userProfileImageUrl,
              onUpdateProfileImage: _updateUserProfileImage,
            ),
            SizedBox(height: 20.0),
            Expanded(
              child: ListView(
                padding: EdgeInsets.all(16.0),
                children: [
                  ModuleCard(
                    title: 'Main Screen',
                    imageUrl: 'assets/images/main screen.png',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const MainScreen()),
                      );
                    },
                  ),
                  ModuleCard(
                    title: 'Expense',
                    imageUrl: 'assets/images/expenses.png',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => NewExpenseScreen()),
                      );
                    },
                  ),
                  ModuleCard(
                    title: 'Income',
                    imageUrl: 'assets/images/incomee.jpg',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => NewIncomeScreen()),
                      );
                    },
                  ),
                  ModuleCard(
                    title: 'Shared Expenses',
                    imageUrl: 'assets/images/sharedExpense.jpg',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => NewSharedExpenseScreen()),
                      );
                    },
                  ),
                  ModuleCard(
                    title: 'Meal',
                    imageUrl: 'assets/images/meal time.png',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => AddMealScreen()),
                      );
                    },
                  ),
                  ModuleCard(
                    title: 'chatBox',
                    imageUrl: 'assets/images/chat.png',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => SearchPagee()),
                      );
                    },
                  ),
                  ModuleCard(
                    title: 'Budget check',
                    imageUrl: 'assets/images/list.png',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => IngredientsPage()),
                      );
                    },
                  ),
                  ModuleCard(
                    title: 'To do list',
                    imageUrl: 'assets/images/list.png',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => Home_Screen()),
                      );
                    },
                  ),

                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void showAboutUsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('About Us'),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('This app was developed by:'),
            SizedBox(height: 16.0),
            Text(DEVELOPER_EMAIL_1),
            SizedBox(height: 8.0),
            Text(DEVELOPER_EMAIL_2),
          ],
        ),
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
}

class UserProfileSection extends StatelessWidget {
  final String userName;
  final String userEmail;
  final String? userProfileImageUrl;
  final VoidCallback onUpdateProfileImage;

  const UserProfileSection({
    Key? key,
    required this.userName,
    required this.userEmail,
    this.userProfileImageUrl,
    required this.onUpdateProfileImage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.teal,
      padding: EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: onUpdateProfileImage,
                child: CircleAvatar(
                  backgroundImage: userProfileImageUrl != null
                      ? NetworkImage(userProfileImageUrl!)
                      : AssetImage('assets/images/family.png') as ImageProvider,
                  radius: 30.0,
                ),
              ),
              SizedBox(width: 16.0),
              Text(
                userName,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.0),
          Text(
            userEmail,
            style: TextStyle(
              color: Colors.white,
              fontSize: 16.0,
            ),
          ),
        ],
      ),
    );
  }
}

class ModuleCard extends StatelessWidget {
  final String title;
  final String imageUrl;
  final VoidCallback onPressed;

  const ModuleCard({
    Key? key,
    required this.title,
    required this.imageUrl,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8.0),
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: AssetImage(imageUrl),
        ),
        title: Text(title),
        onTap: onPressed,
      ),
    );
  }
}
