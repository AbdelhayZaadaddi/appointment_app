import 'package:appointement/config/routes/routes.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';


class Logout extends StatefulWidget {
  const Logout({super.key});

  @override
  State<Logout> createState() => _LogoutState();
}

class _LogoutState extends State<Logout> {

  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> _logout(BuildContext context) async {
    try {
      await _auth.signOut();

      Navigator.of(context).pushNamedAndRemoveUntil(
        AppRoutes.landingPageRoute,
        (Route<dynamic> route) => false,
      );
    } catch (e) {
      print('Error loggin out: $e');
    }
  }
  @override
  Widget build(BuildContext context) {
    return Container(
      child: IconButton(
        icon: Icon(Icons.logout),
        onPressed: () => _logout(context),
      ),
    );
  }
}
