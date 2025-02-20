import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SearchForContact {
    Future<QueryDocumentSnapshot?> searchUserByPhoneNumber(BuildContext context, String phoneNumber) async {
    if (phoneNumber.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please enter a phone number")),
      );
      return null;
    }

    final userRef = FirebaseFirestore.instance.collection('users');
    final querySnapshot = await userRef.where('phoneNumber', isEqualTo: phoneNumber).get();

    // Debug: Print the query results
    print("Query Results: ${querySnapshot.docs}");

    if (querySnapshot.docs.isNotEmpty) {
      return querySnapshot.docs.first;
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("User not found")),
      );
      return null;
    }
  }

  Future<void> addContact_(BuildContext context, receiverId) async {
    final senderId = FirebaseAuth.instance.currentUser?.uid;

    if (senderId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("You must be logged in to send a friend request")),
      );
      return;
    }

    final senderRef = FirebaseFirestore.instance.collection('users').doc(senderId);
    final receiverRef = FirebaseFirestore.instance.collection('users').doc(receiverId);

    await FirebaseFirestore.instance.runTransaction((transaction) async {
      transaction.update(senderRef, {
        'friends': FieldValue.arrayUnion([receiverId])
      });
      transaction.update(receiverRef, {
        'friends': FieldValue.arrayUnion([senderId])
      });
    });

    await FirebaseFirestore.instance.collection('notifications').add({
      'receiverId': receiverId,
      'senderId': senderId,
      'type': 'friend_request_accepted',
      'message': 'You are now friends!',
      'timestamp': FieldValue.serverTimestamp(),
      'isRead': false,
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Friend request sent and accepted automatically!")),
    );
  }

}