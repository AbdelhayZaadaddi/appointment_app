import 'package:appointement/features/landingPage/landing_page.dart';
import 'package:appointement/index.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';


class AuthWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.active) {

          final User? user = snapshot.data;
          if (user != null) {

            return const HomePage();
          } else {

            return const LandingPage();
          }
        }

        return const CupertinoPageScaffold(
          child: Center(child: CupertinoActivityIndicator()),
        );
      },
    );
  }
}