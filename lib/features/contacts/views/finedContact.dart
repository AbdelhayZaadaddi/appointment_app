import 'package:appointement/features/contacts/views/searchContact.dart';
import 'package:appointement/theme/theme.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Finedcontact extends StatefulWidget {
  const Finedcontact({super.key});

  @override
  State<Finedcontact> createState() => _Finedcontact();
}

class _Finedcontact extends State<Finedcontact> {
  SearchForContact searchForContact = SearchForContact();
  final TextEditingController phoneController = TextEditingController();
  QueryDocumentSnapshot? searchedUser;

  void searchContact(BuildContext context, TextEditingController phoneNumber) async {
    String number = phoneNumber.text.trim();
    print(number);

    var user = await searchForContact.searchUserByPhoneNumber(context, number);

    if (user != null) {
      setState(() {
        searchedUser = user;
      });
      print(searchedUser!['name']);
      print(searchedUser!.id);
    }
  }

  void addContact(BuildContext context) async {
  if (searchedUser != null) {
    print(searchedUser!.id);
    searchForContact.addContact_(context, searchedUser!.id);
    setState(() {
      searchedUser = null;
    });
  } else {
    print("No user found to add.");
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Add Contact"),
        centerTitle: true,
        backgroundColor: Colors.white,
      ),
      backgroundColor: TAppTheme.lightTheme.scaffoldBackgroundColor,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              margin: EdgeInsets.all(10),
              child: TextField(
                controller: phoneController,
                decoration: InputDecoration(
                  hintText: "Search",
                  prefixIcon: Icon(Icons.search, size: 15),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.grey,
                      width: 0.5
                    )
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.grey,
                      width: 0.9
                    )
                  ),
                  contentPadding: EdgeInsets.all(8)
                ),
                style: TextStyle(fontSize: 15),
              ),
            ),

            TextButton(
              child: Text("Search"),
              onPressed: () {
                searchContact(context, phoneController);
              },
            ),

            // Display the user data if found
            if (searchedUser != null)
              Container(
                child: ListTile(
                  leading: (searchedUser!['imageUrl']?.isNotEmpty ?? false)
                    ? CircleAvatar(backgroundImage: NetworkImage(searchedUser!['profilePic']))
                    : const CircleAvatar(child: Icon(Icons.person)),
                  title: Text(searchedUser!['name']),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.add, color: Colors.green),
                        onPressed: (){
                          addContact(context);
                        },
                      ),
                    ],
                  ),
                )
              ),
          ],
        ),
      ),
    );
  }
}
