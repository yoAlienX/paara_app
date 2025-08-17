import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:paara_app_duk/screens/login.dart';
import 'package:paara_app_duk/screens/splashScreen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Paara App',
      home: ParaSplashScreen(),
    );
  }
}
