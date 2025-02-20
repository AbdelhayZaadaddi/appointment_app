import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const CustomButton({
    Key? key,
    required this.label,
    required this.onPressed,
    }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue, // Blue background
          foregroundColor: Colors.white, // White text color
          padding: const EdgeInsets.symmetric(vertical: 16), // Add some padding
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20), // Square corners (optional)
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(fontSize: 16),
        ));
  }
}
