import 'package:firebase_auth/firebase_auth.dart'; // Firebase Authentication
import 'package:firebase_core/firebase_core.dart'; // Firebase Core initialization
import 'package:flutter/material.dart'; // Flutter UI framework
import 'package:helloworld/firebase_options.dart'; // Firebase configuration options
import 'package:helloworld/presentation/business_home/business_home.dart'; // Business home screen
import 'package:helloworld/services/notifications_services.dart'; // Notification services
import 'presentation/welcome_screen.dart'; // Welcome screen

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Ensure Flutter is initialized

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform); // Initialize Firebase
  NotificationServies().setupFlutterNotifications(); // Setup notifications
  runApp(const MyApp()); // Run the app
}

final navigatorKey = GlobalKey<NavigatorState>(); // Global key for navigation

class MyApp extends StatelessWidget {
  const MyApp({super.key}); // Constructor

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey, // Set navigator key
      theme: ThemeData.from(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFAECE77), // Define theme color
        ),
      ),
      title: 'FoodSaver App', // App title
      home: const WelcomeScreen(), // Set initial screen
    );
  }
}
