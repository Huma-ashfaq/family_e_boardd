import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../add_members/ingredinets.dart';
import '../../add_members/pages/home_page.dart';
import '../../models/Modelss/Colors.dart';
import '../main_screen.dart';
import 'Home_screen.dart';
import 'ProfileScreen.dart';
import 'SettingScreen.dart';
import 'add_meal_screen.dart';
class NavBarRoots extends StatefulWidget {
  const NavBarRoots({Key? key}) : super(key: key);

  @override
  State<NavBarRoots> createState() => _NavBarRootsState();
}

class _NavBarRootsState extends State<NavBarRoots> {
  int _selectedIndex = 0;
  final _screens = [
    //Home Screen
    Searchrecipe(),
    //Schedule Screen
    const ProfileScreen(),
//meal screen
    AddMealScreen(),
    //Setting Screen
    const SettingScreen(),
    HomePage(),

    IngredientsPage(),



    //chatting screen
    // FamilyGroupChat(),
    // MemberHomeScreen (),
    // SearchScreen(),

  ];
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/watercolor bg.jpg'), // Replace with your image file path
          fit: BoxFit.cover,
        ),
      ),
      child: Scaffold(
        body: _screens[_selectedIndex],
        bottomNavigationBar: SizedBox(
          height: 58,
          child: ClipRRect(
            borderRadius: const BorderRadius.only(topRight: Radius.circular(30),topLeft: Radius.circular(30)),
            child: BottomNavigationBar(
              backgroundColor: Theme.of(context).brightness == Brightness.light ? Colors.grey : Colors.black,
              type: BottomNavigationBarType.fixed,
              selectedItemColor: Theme.of(context).brightness == Brightness.light ? MyColors.cyan : Colors.white,
              unselectedItemColor: Colors.white60,
              showUnselectedLabels: false,
              selectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
              currentIndex: _selectedIndex,
              onTap: (index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
              items: const [
                BottomNavigationBarItem(
                    icon: Icon(Icons.restaurant,), label: "Home"),
                BottomNavigationBarItem(
                    icon: Icon(Icons.person_3_outlined), label: "Profile"),
                BottomNavigationBarItem(
                    icon: Icon(CupertinoIcons.add_circled_solid,), label: "Add Meal"),
                BottomNavigationBarItem(
                    icon: Icon(CupertinoIcons.settings), label: "Settings"),
                BottomNavigationBarItem(
                    icon: Icon(CupertinoIcons.chat_bubble_text_fill), label: "chatting"),
                BottomNavigationBarItem(
                    icon: Icon(Icons.group_add), label: ""),

              ],
            ),
          ),
        ),
      ),
    );
  }
}
