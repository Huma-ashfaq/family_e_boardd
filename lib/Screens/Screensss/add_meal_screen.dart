import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'add_meal_image_picker_screen.dart';

class AddMealScreen extends StatefulWidget {
  const AddMealScreen({Key? key}) : super(key: key);

  @override
  State<AddMealScreen> createState() => _AddMealScreenState();
}

class _AddMealScreenState extends State<AddMealScreen> {
  String? valueChoose;
  List<String> mealList = ["Breakfast", "Lunch", "Dinner", "Snacks", "Dessert"];
  final _formKey = GlobalKey<FormState>();
  final mealNameController = TextEditingController();

  Future<void> _openGoogleRecipe() async {
    String searchQuery = '${mealNameController.text} recipe';
    final Uri url = Uri.https('www.google.com', '/search', {'q': searchQuery});

    if (await canLaunch(url.toString())) {
      await launch(url.toString());
    } else {
      throw 'Could not launch $url';
    }
  }

  Future<void> addMeal() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    try {
      await FirebaseFirestore.instance
          .collection("addMealData")
          .doc(DateTime.now().microsecondsSinceEpoch.toString())
          .set({
        'meal_name': mealNameController.text.trim(),
        'category': valueChoose,
        'create_time': DateTime.now().toString(),
        'current_id': FirebaseAuth.instance.currentUser!.uid,
      });
      print('Meal Added');

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Success"),
            content: const Text("Meal successfully saved!"),
            actions: <Widget>[
              TextButton(
                child: const Text("OK"),
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                  Navigator.pop(context); // Pop the current screen
                },
              ),
            ],
          );
        },
      );
    } catch (e) {
      print('Error saving meal: $e');
      Fluttertoast.showToast(
        msg: "Failed to save meal: $e",
        backgroundColor: Colors.redAccent,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        automaticallyImplyLeading: false,
        title: DefaultTextStyle(
          style: GoogleFonts.kalam(
            textStyle: TextStyle(
              color: Theme.of(context).brightness == Brightness.light
                  ? Colors.teal
                  : Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          child: AnimatedTextKit(
            animatedTexts: [
              WavyAnimatedText("Add Meal"),
            ],
            isRepeatingAnimation: false,
          ),
        ),
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/watercolor bg.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(
                  height: 10,
                ),
                Stack(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 15, vertical: 30),
                      child: Container(
                        decoration: BoxDecoration(
                            color: Theme.of(context).brightness == Brightness.light
                                ? Colors.teal.shade100
                                : Colors.black54,
                            borderRadius: BorderRadius.circular(20)),
                        width: MediaQuery.of(context).size.width,
                        child: Padding(
                          padding: const EdgeInsets.all(18.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding:
                                const EdgeInsets.symmetric(horizontal: 30),
                                child: Text(
                                  "Category",
                                  style: TextStyle(
                                      color: Theme.of(context).brightness ==
                                          Brightness.light
                                          ? Colors.cyan
                                          : Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 9),
                                child: DropdownButtonFormField<String>(
                                  decoration: const InputDecoration(
                                    enabledBorder: UnderlineInputBorder(
                                      borderSide:
                                      BorderSide(color: Colors.purple),
                                    ),
                                  ),
                                  dropdownColor:
                                  Theme.of(context).brightness == Brightness.light
                                      ? Colors.teal.shade100
                                      : Colors.black,
                                  style: TextStyle(
                                    color: Theme.of(context).brightness ==
                                        Brightness.light
                                        ? Colors.purple
                                        : Colors.white,
                                    fontSize: 18,
                                  ),
                                  value: valueChoose,
                                  onChanged: (newValue) {
                                    setState(() {
                                      valueChoose = newValue!;
                                    });
                                  },
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return "Please enter Category";
                                    }
                                    return null;
                                  },
                                  items: mealList.map((valueItem) {
                                    return DropdownMenuItem<String>(
                                      value: valueItem,
                                      child: Text(valueItem),
                                    );
                                  }).toList(),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 30, vertical: 5),
                                child: Text(
                                  "Meal name",
                                  style: TextStyle(
                                      color: Theme.of(context).brightness ==
                                          Brightness.light
                                          ? Colors.cyan
                                          : Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 6),
                                child: TextFormField(
                                  controller: mealNameController,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return "Please enter Meal name";
                                    }
                                    return null;
                                  },
                                  cursorColor: Colors.purple,
                                  decoration: InputDecoration(
                                    hintText: "Enter meal name",
                                    contentPadding: const EdgeInsets.symmetric(
                                        vertical: 15.0, horizontal: 20.0),
                                    filled: true,
                                    fillColor: Colors.teal.withOpacity(0.6),
                                    border: OutlineInputBorder(
                                        borderSide: const BorderSide(
                                            color: Colors.cyan),
                                        borderRadius:
                                        BorderRadius.circular(10)),
                                    focusedBorder: OutlineInputBorder(
                                        borderSide: const BorderSide(
                                            color: Colors.purple),
                                        borderRadius:
                                        BorderRadius.circular(10)),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                FloatingActionButton(
                  onPressed: _openGoogleRecipe,
                  backgroundColor:
                  Theme.of(context).brightness == Brightness.light
                      ? Colors.teal
                      : Colors.black26,
                  child: const Icon(Icons.search),
                ),
                const ImagePickerScreen()
              ],
            ),
          ),
        ),
      ),
    );
  }
}
