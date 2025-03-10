import 'package:appointement/config/routes/routes.dart';
import 'package:appointement/features/contacts/views/friends.dart';
import 'package:appointement/features/contacts/views/searchContact.dart';
import 'package:appointement/theme/theme.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ContactView extends StatefulWidget {
  const ContactView({super.key});

  @override
  State<ContactView> createState() => _ContactViewState();
}

class _ContactViewState extends State<ContactView> {
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
    phoneController.clear();
  } else {
    print("No user found to add.");
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Contact"),
        centerTitle: true,
        backgroundColor: Colors.white,
        actions: [
          Row(
            children: [
              IconButton(
                onPressed: () {
                  Navigator.of(context).pushNamed(AppRoutes.Finedcontact);
                },
                icon: Icon(Icons.add),
              ),
            ],
          )
        ],
      ),
      backgroundColor: TAppTheme.lightTheme.scaffoldBackgroundColor,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.only(left: 7, right: 7),
              child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: phoneController,
                        decoration: InputDecoration(
                          hintText: "Search",
                          prefixIcon: Icon(Icons.search, size: 15,),
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
                          )
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 5,
                    ),
                    Material(
                      color: Colors.lightBlueAccent,
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(12),
                        bottomRight: Radius.circular(12)
                      ),
                      child: IconButton(
                        icon: Icon(Icons.search, color: Colors.white,),
                        onPressed: (){
                          searchContact(context, phoneController);
                        },
                      ),
                    )
                  ],
                ),
            ),
            
          
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
                        icon: const Icon(Icons.check, color: Colors.green),
                        onPressed: (){
                          addContact(context);
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.red),
                        onPressed: (){
                          phoneController.clear();
                          setState(() {
                            searchedUser = null;
                          });
                        },
                      ),
                    ],
                  ),
                )
              ),

            Friends(),
          ],
        ),
      ),
    );
  }
}


/*

Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              margin: EdgeInsets.all(10),
              decoration: TAppTheme.lightBoxShadow,
              child: SearchButton(),
            ),
            TextButton(
              onPressed: (){
                Navigator.pushNamed(context, AppRoutes.FriendsRequestPgae);
              },
              child: Icon(Icons.contacts),
            ),
            Friends(),
            Expanded(
              child: AllContacts(),
            )
          ],
        ),
      ),



      */