import 'package:appointement/features/appointments/views/add_apointment.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Friends extends StatefulWidget {
  const Friends({super.key});

  @override
  State<Friends> createState() => _FriendsState();
}

class _FriendsState extends State<Friends> {
  // Method to fetch friends from Firestore
  Stream<List<Map<String, dynamic>>> getFriends() {
    final userId = FirebaseAuth.instance.currentUser?.uid;

    return FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .snapshots()
        .asyncMap((snapshot) async {
      if (snapshot.exists && snapshot.data()?['friends'] != null) {
        List<String> friendIds = List<String>.from(snapshot.data()?['friends']);

        // Fetch user details for each friend ID
        List<Map<String, dynamic>> friendData = await Future.wait(
          friendIds.map((id) async {
            DocumentSnapshot userSnapshot =
                await FirebaseFirestore.instance.collection('users').doc(id).get();
            if (userSnapshot.exists) {
              Map<String, dynamic> userData = userSnapshot.data() as Map<String, dynamic>;
              return {
                'id': id,
                'name': userData['name'] ?? 'Unknown',
                'profilePic': userData['profilePic'] ?? '',
              };
            }
            return {'id': id, 'name': 'Unknown'};
          }),
        );

        return friendData;
      }
      return [];
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: getFriends(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(
            child: Column(
              children: [
                Icon(Icons.contacts_rounded, size: 100,),
                Text('No Contacts found'),
              ],
            ),
          );
        }

        return SingleChildScrollView(
          child: Column(
            children: snapshot.data!.map((friend) {
              return ListTile(
                leading: (friend['profilePic']?.isNotEmpty ?? false)
                    ? CircleAvatar(backgroundImage: NetworkImage(friend['profilePic']))
                    : const CircleAvatar(child: Icon(Icons.person)),
                title: Text(friend['name']),
                trailing: IconButton(
                  icon: const Icon(Icons.add, color: Colors.grey),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AddAppointment(contact: friend['name'], id: friend['id']),
                      )
                    );
                  },
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }
}
