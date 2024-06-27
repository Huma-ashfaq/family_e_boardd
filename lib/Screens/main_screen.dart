import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:meal_plan/Screens/main_module_screen.dart';
import 'package:meal_plan/Screens/shared_expense_screen.dart';
import 'package:meal_plan/Screens/trans_screen.dart';
import 'package:icons_flutter/icons_flutter.dart';
import 'package:meal_plan/add_members/pages/auth/search_page.dart';
import '../add_members/ingredinets.dart';
import '../add_members/pages/home_page.dart';
import 'Screensss/add_meal_screen.dart';
 // Make sure to import the AddMemberScreen

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  var _selectedPageIndex = 0;
  final List<Widget> _pages = [
   
    TransScreen(),
    const SharedExpense_Screen(),
    const AddMealScreen(),
    IngredientsPage(),
    const SearchPagee(), // Add the AddMemberScreen here
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedPageIndex],
      bottomNavigationBar: BottomNavigationBar(
        onTap: (index) {
          setState(() {
            _selectedPageIndex = index;
          });
        },
        currentIndex: _selectedPageIndex,
        items: const [

          BottomNavigationBarItem(
            icon: Icon(MaterialCommunityIcons.swap_horizontal_bold),
            label: 'Personal Expense',
          ),
          BottomNavigationBarItem(
            icon: Icon(MaterialCommunityIcons.account_group),
            label: 'Shared Expenses',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.add_circled_solid),
            label: "Add Meal",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.format_list_numbered_rounded),
            label: "List Ingredients",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.group_add),
            label: "Add Member",
          ),
        ],
        backgroundColor: Colors.white, // Ensure the background color is set
        selectedItemColor: Colors.blue, // You can set the color you prefer
        unselectedItemColor: Colors.grey,
      ),
    );
  }
}
