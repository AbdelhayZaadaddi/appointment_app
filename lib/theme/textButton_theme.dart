import 'package:flutter/material.dart';

class TTextButtonTheme {
  TTextButtonTheme._();

  static ButtonStyle lightTheme = TextButton.styleFrom(
    backgroundColor: Colors.blue,
    foregroundColor: Colors.white,
    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
    ),
  );
}