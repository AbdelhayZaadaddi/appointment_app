import 'package:flutter/material.dart';

class TSearchTheme {
  TSearchTheme._();

  static InputDecorationTheme lightTheme = InputDecorationTheme(
    filled: true,
    fillColor: Colors.white,
    contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(30), // Adjusted to match your example
      borderSide: BorderSide.none,
    ),
    prefixIconColor: Colors.grey, // Color for the prefix icon
    hintStyle: TextStyle(color: Colors.grey), // Hint text style
  );

  static InputDecorationTheme darkTheme = InputDecorationTheme(
    filled: true,
    fillColor: Colors.black26,
    contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(30),
      borderSide: BorderSide.none,
    ),
    prefixIconColor: Colors.white,
    hintStyle: TextStyle(color: Colors.white),
  );
}
