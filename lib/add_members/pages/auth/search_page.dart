import 'dart:math'; // Import for Random
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../helper/helper_function.dart';
import '../../service/database_service.dart';
import '../../widgets/widgetsa.dart';
import '../chat_page.dart';

class SearchPagee extends StatefulWidget {
  const SearchPagee({super.key});

  @override
  State<SearchPagee> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPagee> {
  TextEditingController searchController = TextEditingController();
  TextEditingController codeController = TextEditingController();
  TextEditingController groupNameController = TextEditingController();
  bool _isLoading = false;
  QuerySnapshot? searchSnapshot;
  bool hasUserSearched = false;
  String userName = "";
  User? user;
  bool isJoined = false;
  bool isCreateNewFamily = false;
  bool isJoinExistingFamily = false;

  @override
  void initState() {
    super.initState();
    getCurrentUserIdandName();
  }

  getCurrentUserIdandName() async {
    await HelperFunctions.getUserNameFromSF().then((value) {
      if (value != null) {
        setState(() {
          userName = value;
        });
      }
    });
    user = FirebaseAuth.instance.currentUser;
  }

  getName(String r) {
    return r.substring(r.indexOf("_") + 1);
  }

  String getId(String res) {
    return res.substring(0, res.indexOf("_"));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.teal,
        title: Text(
          "Search",
          style: TextStyle(
              fontSize: 27, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/images/watercolor bg.jpg"),
              fit: BoxFit.cover,
            ),
          ),
          child: Column(
            children: [
              Container(
                color: Colors.teal,
                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: searchController,
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                            border: InputBorder.none,
                            hintText: "Search groups.....",
                            hintStyle:
                            TextStyle(color: Colors.white, fontSize: 16)),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        initiateSearchMethod();
                      },
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(40),
                        ),
                        child: const Icon(Icons.search),
                      ),
                    )
                  ],
                ),
              ),
              CheckboxListTile(
                title: Text("Create New Family"),
                value: isCreateNewFamily,
                onChanged: (bool? value) {
                  setState(() {
                    isCreateNewFamily = value!;
                    if (isCreateNewFamily) isJoinExistingFamily = false;
                  });
                },
              ),
              CheckboxListTile(
                title: Text("Join Existing Family"),
                value: isJoinExistingFamily,
                onChanged: (bool? value) {
                  setState(() {
                    isJoinExistingFamily = value!;
                    if (isJoinExistingFamily) isCreateNewFamily = false;
                  });
                },
              ),
              if (isJoinExistingFamily)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: TextField(
                    controller: codeController,
                    decoration: InputDecoration(
                      hintText: "Enter 4-digit code",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              _isLoading
                  ? Center(
                child: CircularProgressIndicator(
                  color: Colors.teal,
                ),
              )
                  : groupList(),
            ],
          ),
        ),
      ),
      floatingActionButton: isCreateNewFamily
          ? FloatingActionButton(
        onPressed: () {
          showGroupNameDialog();
        },
        child: Icon(Icons.add),
      )
          : null,
    );
  }

  void initiateSearchMethod() async {
    if (searchController.text.isNotEmpty) {
      setState(() {
        _isLoading = true;
      });
      await DatabaseService()
          .searchByName(searchController.text)
          .then((snapshot) {
        setState(() {
          searchSnapshot = snapshot;
          _isLoading = false;
          hasUserSearched = true;
        });
      }).catchError((error) {
        setState(() {
          _isLoading = false;
        });
        HelperFunctions.showSnackBar(context, Colors.red, "Error: $error");
      });
    }
  }

  Widget groupList() {
    return hasUserSearched && searchSnapshot != null
        ? ListView.builder(
      shrinkWrap: true,
      itemCount: searchSnapshot!.docs.length,
      itemBuilder: (context, index) {
        return groupTile(
          userName,
          searchSnapshot!.docs[index]['groupId'],
          searchSnapshot!.docs[index]['groupName'],
          searchSnapshot!.docs[index]['admin'],
        );
      },
    )
        : Container();
  }

  Widget groupTile(
      String userName, String groupId, String groupName, String admin) {
    return ListTile(
      contentPadding:
      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      leading: CircleAvatar(
        radius: 30,
        backgroundColor: Colors.teal,
        child: Text(
          groupName.substring(0, 1).toUpperCase(),
          style: const TextStyle(color: Colors.white),
        ),
      ),
      title: Text(
        groupName,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Text("Admin: ${getName(admin)}"),
      trailing: InkWell(
        onTap: () async {
          await joinGroup(groupId, groupName);
        },
        child: isJoined
            ? Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Colors.black87,
            border: Border.all(color: Colors.white, width: 1),
          ),
          padding: const EdgeInsets.symmetric(
              horizontal: 20, vertical: 10),
          child: const Text(
            "Joined",
            style: TextStyle(color: Colors.white),
          ),
        )
            : Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Colors.teal,
          ),
          padding: const EdgeInsets.symmetric(
              horizontal: 20, vertical: 10),
          child: const Text(
            "Join Now",
            style: TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }

  Future<void> joinGroup(String groupId, String groupName) async {
    setState(() {
      _isLoading = true;
    });

    // Verify OTP code
    bool isCodeValid =
    await DatabaseService().verifyGroupCode(codeController.text);

    if (isCodeValid) {
      await DatabaseService(uid: user!.uid)
          .toggleGroupJoin(groupId, userName, groupName)
          .then((value) {
        setState(() {
          isJoined = true;
          _isLoading = false;
        });

        // Navigate to ChatPage
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatPage(
              groupId: groupId,
              groupName: groupName,
              userName: userName,
            ),
          ),
        );
      }).catchError((error) {
        setState(() {
          _isLoading = false;
        });
        HelperFunctions.showSnackBar(context, Colors.red, "Error: $error");
      });
    } else {
      setState(() {
        _isLoading = false;
      });
      HelperFunctions.showSnackBar(context, Colors.red, "Invalid code");
    }
  }

  void showGroupNameDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Enter Group Name"),
          content: TextField(
            controller: groupNameController,
            decoration: InputDecoration(hintText: "Group Name"),
          ),
          actions: [
            TextButton(
              child: Text("Cancel"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text("Create"),
              onPressed: () {
                Navigator.of(context).pop();
                createNewFamilyGroup();
              },
            ),
          ],
        );
      },
    );
  }

  void createNewFamilyGroup() async {
    if (groupNameController.text.isNotEmpty) {
      setState(() {
        _isLoading = true;
      });

      // Generate a random 4-digit code
      String groupCode =
      (1000 + (Random().nextInt(9000))).toString();

      await DatabaseService(uid: user!.uid)
          .createGroup(
        userName,
        user!.uid,
        groupNameController.text,
        groupCode,
      )
          .then((value) {
        setState(() {
          _isLoading = false;
          isCreateNewFamily = false; // Reset the checkbox after creation
          groupNameController.clear();
        });
        HelperFunctions.showSnackBar(
            context,
            Colors.green,
            "Group created successfully with code: $groupCode");
      }).catchError((error) {
        setState(() {
          _isLoading = false;
        });
        HelperFunctions.showSnackBar(
            context, Colors.red, "Error: $error");
      });
    } else {
      HelperFunctions.showSnackBar(
          context, Colors.red, "Group name cannot be empty");
    }
  }
}
