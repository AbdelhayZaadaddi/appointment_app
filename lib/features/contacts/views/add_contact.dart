import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AddContact extends StatefulWidget {
  const AddContact({super.key});

  @override
  State<AddContact> createState() => _AddContactState();
}

class _AddContactState extends State<AddContact> {

  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController nameController = TextEditingController();

  DocumentSnapshot? searchedUser;
  List<QueryDocumentSnapshot> searchedUsers = [];

  /// Search for user by phone number
  Future<void> searchUserByPhoneNumber() async {
    String phoneNumber = phoneController.text.trim();

    if (phoneNumber.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please enter a phone number")),
      );
      return;
    }

    final usersRef = FirebaseFirestore.instance.collection('users');
    final querySnapshot = await usersRef.where('phoneNumber', isEqualTo: phoneNumber).get();

    if (querySnapshot.docs.isNotEmpty) {
      setState(() {
        searchedUser = querySnapshot.docs.first;
      });
    } else {
      setState(() {
        searchedUser = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("User not found")),
      );
    }
  }

  Future<void> searchUserByName() async {
  String userName = nameController.text.trim();

  if (userName.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Please enter a name")),
    );
    return;
  }

  final usersRef = FirebaseFirestore.instance.collection('users');
  final querySnapshot = await usersRef
      .where('name', isGreaterThanOrEqualTo: userName)
      .where('name', isLessThan: userName + 'z') // 'z' ensures the upper bound
      .get();

  if (querySnapshot.docs.isNotEmpty) {
    setState(() {
      searchedUsers = querySnapshot.docs; // Store all matching users
    });
  } else {
    setState(() {
      searchedUsers = []; // Clear the list if no users are found
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("No users found starting with: $userName")),
    );
  }
}


  /// Search for ser by email
  Future<void> searchUserByEmail() async {
    String email = emailController.text.trim();

    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please enter a email address")),
      );
      return;
    }

    final usersRef = FirebaseFirestore.instance.collection('users');
    final querySnapshot = await usersRef.where('email', isEqualTo: email).get();

    if (querySnapshot.docs.isNotEmpty) {
      setState(() {
        searchedUser = querySnapshot.docs.first;
      });
    } else {
      setState(() {
        searchedUser = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("User not found")),
      );
    }
  }

  /// Send friend request
  Future<void> sendFriendRequest(String receiverId) async {
    final senderId = FirebaseAuth.instance.currentUser?.uid;

    if (senderId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("You must be logged in to send a friend request")),
      );
      return;
    }

    final receiverRef = FirebaseFirestore.instance.collection('users').doc(receiverId);

    await receiverRef.update({
      'friendRequests': FieldValue.arrayUnion([senderId])
    });

    await FirebaseFirestore.instance.collection('notifications').add({
      'receiverId': receiverId,
      'senderId': senderId,
      'type': 'friend_request',
      'message': 'You have a new friend request!',
      'timestamp': FieldValue.serverTimestamp(),
      'isRead': false,
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Friend request sent!")),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Find Contact'),
        backgroundColor: Colors.white,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Search by Name
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: "Enter a Friend's name",
                  prefixIcon: Icon(Icons.search),
                  floatingLabelBehavior: FloatingLabelBehavior.never,
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),

            SizedBox(height: 10),

            // Search by Phone Number
            /*
            TextField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: "Enter phone number",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),

            */
            // Search by Email
            /*
            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: "Enter email address",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            */


            // Search Buttons
            /*
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                
                ElevatedButton(
                  onPressed: searchUserByPhoneNumber,
                  child: Text("Search by Phone"),
                ),
                ElevatedButton(
                  onPressed: searchUserByEmail,
                  child: Text("Search by Email"),
                ),
              ],
            ),
            */

            ElevatedButton(
              onPressed: searchUserByName,
              child: Text("Search by Name"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white
              ),
            ),
            SizedBox(height: 20),

            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white
                ),
                child: ListView.builder(
                  itemCount: searchedUsers.length,
                  itemBuilder: (context, index) {
                    var user = searchedUsers[index].data() as Map<String, dynamic>;
                    return Card(
                      margin: EdgeInsets.symmetric(vertical: 5),
                      color: Colors.white,
                      child: ListTile(
                        title: Text(user['name']),
                        subtitle: Text(user['email'] ?? user['phoneNumber']),
                        trailing: ElevatedButton(
                          onPressed: () => sendFriendRequest(searchedUsers[index].id),
                          child: Text("Send Request", style: TextStyle(color: Colors.black54),),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white
                          ),
                        ),
                      ),
                    );
                  },
                ),
              )
            ),
          ],
        ),
      ),
    );
  }
}