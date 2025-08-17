// Usage in your main app:
import 'package:flutter/material.dart';
import 'package:paara_app_duk/screens/Kform.dart';
import 'package:paara_app_duk/screens/homeScreen.dart';
import 'package:paara_app_duk/screens/splashScreen.dart';

void main() {
  runApp(MaterialApp(
    home: ParaHomeScreen(),
    debugShowCheckedModeBanner: false,
    theme: ThemeData.dark(),
  ));
}