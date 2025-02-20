import 'package:appointement/config/routes/routes.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class OTPVerificationPage extends StatefulWidget {
  const OTPVerificationPage({super.key});

  @override
  _OTPVerificationPageState createState() => _OTPVerificationPageState();
}

class _OTPVerificationPageState extends State<OTPVerificationPage> {
  String otp = ''; // Initialize to an empty string to avoid null issues
  late String verificationId;
  String? errorMessage;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    try {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is String && args.isNotEmpty) {
        verificationId = args;
      } else {
        throw Exception('Verification ID is missing or invalid');
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Failed to retrieve verification ID: ${e.toString()}';
      });
    }
  }

  void _verifyOTP() async {
    if (otp.isEmpty) {
      setState(() {
        errorMessage = 'OTP is required';
      });
      return;
    }

    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: otp,
      );

      await FirebaseAuth.instance.signInWithCredential(credential);
      Navigator.of(context).pushNamed(AppRoutes.homePageRoute);
    } catch (e) {
      setState(() {
        errorMessage = 'Invalid OTP. Please try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Enter OTP',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 20),
              TextField(
                onChanged: (value) {
                  setState(() {
                    otp = value.trim(); // Trim whitespace
                    errorMessage = null; // Clear error message on input
                  });
                },
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'OTP',
                  border: const OutlineInputBorder(),
                  errorText: errorMessage,
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _verifyOTP,
                  child: const Text('Verify OTP'),
                ),
              ),
              if (errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    errorMessage!,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
