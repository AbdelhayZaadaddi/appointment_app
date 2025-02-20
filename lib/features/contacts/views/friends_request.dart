import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class FriendsRequest extends StatefulWidget {
  const FriendsRequest({super.key});

  @override
  State<FriendsRequest> createState() => _FriendsRequestState();
}

class _FriendsRequestState extends State<FriendsRequest> {

  Stream<List<Map<String, dynamic>>> getFriendRequests() {
    final userId = FirebaseAuth.instance.currentUser?.uid;

    return FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .snapshots()
        .asyncMap((snapshot) async {
      if (snapshot.exists && snapshot.data()?['friendRequests'] != null) {
        List<String> friendIds = List<String>.from(snapshot.data()?['friendRequests']);

        List<Map<String, dynamic>> friendData = await Future.wait(
          friendIds.map((id) async {
            DocumentSnapshot userSnapshot = await FirebaseFirestore.instance.collection('users').doc(id).get();
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

  Future<void> acceptFriendRequest(String friendId) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    final userRef = FirebaseFirestore.instance.collection('users').doc(userId);
    final friendRef = FirebaseFirestore.instance.collection('users').doc(friendId);

    // Accept Friend Request
    await FirebaseFirestore.instance.runTransaction((transaction) async {
      transaction.update(userRef, {
        'friends': FieldValue.arrayUnion([friendId]),
        'friendRequests': FieldValue.arrayRemove([friendId])
      });
      transaction.update(friendRef, {
        'friends': FieldValue.arrayUnion([userId])
      });
    });

    // Add a notification
    await FirebaseFirestore.instance.collection('notifications').add({
      'receiverId': friendId,
      'senderId': userId,
      'type': 'Friend Request Accepted',
      'message': 'Your Friend request have been accepted ',
      'timestamp': FieldValue.serverTimestamp(),
      'isRead': false,
    });

    print(friendId);

    print("Friend request accepted!");
  }

  Future<void> rejectFriendRequest(String friendId) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    final userRef = FirebaseFirestore.instance.collection('users').doc(userId);
    await userRef.update({
      'friendRequests': FieldValue.arrayRemove([friendId])
    });

    print("Friend request rejected!");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Friend Requests'),
        backgroundColor: Colors.white,
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: getFriendRequests(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No friend requests"));
          }

          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              var friend = snapshot.data![index];
              return ListTile(
                leading: (friend['profilePic']?.isNotEmpty ?? false)
                    ? CircleAvatar(backgroundImage: NetworkImage(friend['profilePic']))
                    : const CircleAvatar(child: Icon(Icons.person)),
                title: Text(friend['name']),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.check, color: Colors.green),
                      onPressed: () => acceptFriendRequest(friend['id']),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.red),
                      onPressed: () => rejectFriendRequest(friend['id']),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}


/*

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class FriendsRequest extends StatefulWidget {
  const FriendsRequest({super.key});

  @override
  State<FriendsRequest> createState() => _FriendsRequestState();
}

class _FriendsRequestState extends State<FriendsRequest> {

  /*

  Stream<List<String>> getFriendRequests() {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    return FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .snapshots()
        .map((snapshot) {
          if (snapshot.exists && snapshot.data()?['friendRequests'] != null) {
            return List<String>.from(snapshot.data()?['friendRequests']);
          }
          return [];
        });
  }
*/

  Stream<List<Map<String, dynamic>>> getFriendRequests() {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    
    return FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .snapshots()
        .asyncMap((snapshot) async {
          if (snapshot.exists && snapshot.data()?['friendRequests'] != null) {
            List<String> friendIds = List<String>.from(snapshot.data()?['friendRequests']);
            
            // Fetch user details for each friend ID
            List<Map<String, dynamic>> friendData = await Future.wait(
              friendIds.map((id) async {
                DocumentSnapshot userSnapshot = 
                    await FirebaseFirestore.instance.collection('users').doc(id).get();
                if (userSnapshot.exists) {
                  return {
                    'id': id,
                    'name': userSnapshot.data()?['name'] ?? 'Unknown',
                    'profilePic': userSnapshot.data()?['profilePic'] ?? '', // Optional
                  };
                }
                return {'id': id, 'name': 'Unknown'};
              })
            );

            return friendData;
          }
          return [];
        });
  }


  Future<void> acceptFriendRequest(String friendId) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    final userRef = FirebaseFirestore.instance.collection('users').doc(userId);
    final friendRef = FirebaseFirestore.instance.collection('users').doc(friendId);

    await FirebaseFirestore.instance.runTransaction((transaction) async {
      transaction.update(userRef, {
        'friends': FieldValue.arrayUnion([friendId]),
        'friendRequests': FieldValue.arrayRemove([friendId])
      });
      transaction.update(friendRef, {
        'friends': FieldValue.arrayUnion([userId])
      });
    });

    print("Friend request accepted!");
  }

  Future<void> rejectFriendRequest(String friendId) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    final userRef = FirebaseFirestore.instance.collection('users').doc(userId);
    await userRef.update({
      'friendRequests': FieldValue.arrayRemove([friendId])
    });

    print("Friend request rejected!");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Friend Requests'),
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
  stream: getFriendRequests(),
  builder: (context, snapshot) {
    if (!snapshot.hasData || snapshot.data!.isEmpty) {
      return Text("No friend requests");
    }

    return ListView.builder(
      itemCount: snapshot.data!.length,
      itemBuilder: (context, index) {
        var friend = snapshot.data![index];
        return ListTile(
          leading: friend['profilePic'].isNotEmpty 
              ? CircleAvatar(backgroundImage: NetworkImage(friend['profilePic']))
              : CircleAvatar(child: Icon(Icons.person)),
          title: Text(friend['name']),
        );
      },
    );
  },
)

    );
  }
}

/*
StreamBuilder<List<String>>(
        stream: getFriendRequests(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No friend requests"));
          }
          
          final friendRequests = snapshot.data!;
          return ListView.builder(
            itemCount: friendRequests.length,
            itemBuilder: (context, index) {
              final friendId = friendRequests[index];
              return ListTile(
                title: Text(friendId), // Ideally, fetch the username using the ID
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.check, color: Colors.green),
                      onPressed: () => acceptFriendRequest(friendId),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.red),
                      onPressed: () => rejectFriendRequest(friendId),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),

*/
*/