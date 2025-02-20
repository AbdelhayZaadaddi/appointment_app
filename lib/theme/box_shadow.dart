import 'package:flutter/material.dart';

class TBoxShadow {
  TBoxShadow._();

  static final BoxDecoration lightTheme = BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(10),
    boxShadow: [
      BoxShadow(
        color: Colors.grey.withOpacity(0.5),
        spreadRadius: 1,
        blurRadius: 2,
        offset: Offset(0, 3), // Shadow position
      ),
    ],
  );

  static final BoxDecoration darkTheme = BoxDecoration(
    color: Colors.black,
    borderRadius: BorderRadius.circular(10),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.7),
        spreadRadius: 5,
        blurRadius: 7,
        offset: Offset(0, 3), // Shadow position
      ),
    ],
  );
}
