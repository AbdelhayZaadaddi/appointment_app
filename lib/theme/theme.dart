import 'package:appointement/theme/box_shadow.dart';
import 'package:appointement/theme/search_theme.dart';
import 'package:appointement/theme/textButton_theme.dart';
import 'package:appointement/theme/text_theme.dart';
import 'package:flutter/material.dart';

class TAppTheme {
  TAppTheme._();

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    primaryColor: Colors.blue,
    scaffoldBackgroundColor: Colors.white,
    textTheme: TTextTheme.lightTheme,
    inputDecorationTheme: TSearchTheme.lightTheme,
    textButtonTheme: TextButtonThemeData(
      style: TTextButtonTheme.lightTheme,
    ),
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    primaryColor: Colors.blue,
    scaffoldBackgroundColor: Colors.black,
    textTheme: TTextTheme.darkTheme,
    inputDecorationTheme: TSearchTheme.darkTheme,
  );

  static BoxDecoration lightBoxShadow = TBoxShadow.lightTheme;
  static BoxDecoration darkBoxShadow = TBoxShadow.darkTheme;
}