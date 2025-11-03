import 'package:flutter/material.dart';

final ThemeData appThemeData = ThemeData(
  primaryColor: Colors.black,
  brightness: Brightness.light,
  hintColor: Colors.cyan[600],
  appBarTheme: const AppBarTheme(
    color: Colors.black,
    titleTextStyle: TextStyle(color: Colors.white, fontSize: 20),
  ),
);
//Possivel mudança de temas
/*
final ThemeData appThemeDataDark = ThemeData(
  primaryColor: Colors.black,
  brightness: Brightness.light,
  hintColor: Colors.cyan[600],
  appBarTheme: const AppBarTheme(
    color: Colors.black,
    titleTextStyle: TextStyle(color: Colors.white, fontSize: 20),
  ),
);*/