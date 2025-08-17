import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:paara_app_duk/screens/login.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Paara App',
      home: PaaraLoginPage(),
    );
  }
}