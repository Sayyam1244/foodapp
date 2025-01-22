import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:helloworld/firebase_options.dart';
import 'presentation/welcome_screen.dart'; // Import the WelcomeScreen class

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'FoodSaver App',
      home: WelcomeScreen(),
    );
  }
}
