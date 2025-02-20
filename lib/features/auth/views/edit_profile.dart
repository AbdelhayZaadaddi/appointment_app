import 'dart:io';
import 'package:appointement/config/routes/routes.dart';
import 'package:appointement/features/auth/views/ensureUserExists.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class EditProfile extends StatefulWidget {
  const EditProfile({super.key});

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  FirebaseAuth _auth = FirebaseAuth.instance;
  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  FirebaseStorage _storage = FirebaseStorage.instance;

  String username = '';
  String phone_number = '';
  String? imageUrl;
  File? _image;

  Future<void> saveUserData(String name, String? imageUrl) async {
    User? user = _auth.currentUser;
    if (user != null) {
      await _firestore.collection('users').doc(user.uid).set({
        'name': name,
        'email': user.email,
        'imageUrl': imageUrl,
        'phoneNumber': user.phoneNumber,
        'createdAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }
  }


  Future<Map<String, dynamic>?> getUserData() async {
    User? user = _auth.currentUser;
    if (user != null) {
      DocumentSnapshot doc = await _firestore.collection('users').doc(user.uid).get();
      if (doc.exists) {
        return doc.data() as Map<String, dynamic>;
      }
    }
    return null;
  }


  void loadUserData() async {
    Map<String, dynamic>? userData = await getUserData();
    User? user = _auth.currentUser;
    if (user != null) {
      setState(() {
        username = userData?['name'] ?? '';
        imageUrl = userData?['imageUrl'];
        phone_number = user.phoneNumber ?? '';
      });
    }
  }



  Future<void> pickImage() async {
     
      final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          _image = File(pickedFile.path);
        });
        await uploadImage();
      }
  }

  Future<void> uploadImage() async {
    if (_image == null) return;
    User? user = _auth.currentUser;
    if (user != null) {
      String filePath = 'profile_images/${user.uid}.jpg';
      UploadTask uploadTask = _storage.ref(filePath).putFile(_image!);
      TaskSnapshot snapshot = await uploadTask;
      String downloadUrl = await snapshot.ref.getDownloadURL();
      setState(() {
        imageUrl = downloadUrl;
      });
      await saveUserData(username, imageUrl);
    }
  }

  void _checkedUser() async {
    CheckedUser checkedUser = CheckedUser();
    await checkedUser.ensureUserExists();
  }

  @override
  void initState() {
    super.initState();
    _checkedUser();
    loadUserData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).primaryColor.withOpacity(0.8),
              Theme.of(context).primaryColor.withOpacity(0.6),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Custom AppBar
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Text(
                      "Edit Profile",
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                      children: [
                        const SizedBox(height: 20),
                        // Profile Image Section
                        GestureDetector(
                          onTap: pickImage,
                          child: Stack(
                            children: [
                              CircleAvatar(
                                radius: 60,
                                backgroundColor: Colors.white.withOpacity(0.9),
                                backgroundImage: imageUrl != null ? NetworkImage(imageUrl!) : null,
                                child: imageUrl == null
                                    ? const Icon(Icons.person, size: 60, color: Colors.blue)
                                    : null,
                              ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.blue, width: 2),
                                  ),
                                  child: const Icon(Icons.camera_alt, size: 20, color: Colors.blue),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 40),

                        // Username TextField
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: TextField(
                            decoration: InputDecoration(
                              labelText: username.isNotEmpty ? username : "Enter your name",
                              hintText:  "Update your user Name",
                              floatingLabelBehavior: FloatingLabelBehavior.never,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              filled: true,
                              fillColor: Colors.white,
                              prefixIcon: const Icon(Icons.person_outline),
                            ),
                            onChanged: (value) => setState(() => username = value),
                          ),
                        ),
                        const SizedBox(height: 20),

                        
                        const SizedBox(height: 40),

                        // Update Button
                        ElevatedButton(
                          onPressed: () async {
                            if (username.isNotEmpty) {
                              await saveUserData(username, imageUrl);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Profile Updated Successfully!')),
                              );
                              Navigator.of(context).pushNamedAndRemoveUntil(
                                AppRoutes.homePageRoute,
                                    (Route<dynamic> route) => false,
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Please fill in all fields')),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Theme.of(context).primaryColor,
                            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Update Profile',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
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
        ),
      ),
    );
  }
}