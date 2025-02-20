import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CategoryService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;


  String get _userId {
    final user = _auth.currentUser;
    if (user==null) throw Exception("User not logged in");
    return user.uid;
  }


  Future<void> createCategory(String name) async {
    await _firestore.collection('categories').doc(_userId).collection('userCategories').add({
      'name': name,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }


  Stream<QuerySnapshot> getCategories() {
    return _firestore.collection('categories').doc(_userId).collection('userCategories').snapshots();
  }


  Future<void> updateCategory(String categoryId, String newName) async {
    await _firestore
        .collection('categories')
        .doc(_userId)
        .collection('userCategories')
        .doc(categoryId)
        .update({'name': newName});
  }


  Future<void> deleteCategory(String categoryId) async {
    await _firestore
        .collection('categories')
        .doc(_userId)
        .collection('userCategories')
        .doc(categoryId)
        .delete();
  }

}