import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

class Statistics {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;

  String get userId{
    final user = auth.currentUser;
    if (user == null) throw Exception("User not logged in");
    return user.uid;
  }

  /*

  int GetNumberOfAppointmentOfWeek() async {
    await firestore.collection();
    return 1;
  }

  */
}

