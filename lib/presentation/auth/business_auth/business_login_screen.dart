import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart'; // Import for TapGestureRecognizer
import 'package:helloworld/presentation/business_home/business_home.dart';
import 'package:helloworld/presentation/reset_password_screen.dart';
import 'package:helloworld/services/auth_service.dart';
import 'package:helloworld/utils/app_validator.dart';
import 'business_register_screen.dart'; // Import for the sign-up screen

class BusinessLoginScreen extends StatefulWidget {
  const BusinessLoginScreen({Key? key}) : super(key: key);

  @override
  State<BusinessLoginScreen> createState() => _BusinessLoginScreenState();
}

class _BusinessLoginScreenState extends State<BusinessLoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF517F03), // Green background
      appBar: AppBar(
        title: const Text(
          "Business Login",
          style: TextStyle(color: Color(0xFFFFF4E2)), // Beige color for text
        ),
        backgroundColor: const Color(0xFF517F03), // Match the background color
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // Navigate back
          },
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Enter Email:",
                  style: TextStyle(
                    fontSize: 18,
                    color: Color(0xFFFFF4E2), // Beige color for text
                  ),
                ),
                const SizedBox(height: 10),

                TextFormField(
                  validator: AppValidator.emailCheck,
                  controller: emailController,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor:
                        const Color(0xFFFFF4E2), // Set to beige background
                    border: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(30.0), // Rounded corners
                      borderSide: BorderSide.none, // No border line
                    ),
                    hintText: "example@example.com",
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  "Enter Password:",
                  style: TextStyle(
                    fontSize: 18,
                    color: Color(0xFFFFF4E2), // Beige color for text
                  ),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: passwordController,
                  obscureText: true,
                  validator: AppValidator.passwordCheck,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor:
                        const Color(0xFFFFF4E2), // Set to beige background
                    border: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(30.0), // Rounded corners
                      borderSide: BorderSide.none, // No border line
                    ),
                    hintText: "********",
                  ),
                ),
                const SizedBox(height: 30),
                Center(
                  child: Column(
                    children: [
                      RichText(
                        text: TextSpan(
                          children: [
                            const TextSpan(
                              text: "Forgot password? ",
                              style: TextStyle(
                                color:
                                    Color(0xFFFFF4E2), // Beige color for text
                              ),
                            ),
                            TextSpan(
                              text: "Reset Password",
                              style: const TextStyle(
                                color: Color(
                                    0xFFAECE77), // Shade for the reset password text
                                decoration:
                                    TextDecoration.underline, // Underline
                              ),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const ResetPasswordScreen(),
                                    ),
                                  ); // Navigate to Reset Password screen
                                },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10), // Spacer
                      RichText(
                        text: TextSpan(
                          children: [
                            const TextSpan(
                              text: "Don't have an account? ",
                              style: TextStyle(
                                color:
                                    Color(0xFFFFF4E2), // Beige color for text
                              ),
                            ),
                            TextSpan(
                              text: "Sign up",
                              style: const TextStyle(
                                color: Color(
                                    0xFFAECE77), // Shade for the sign-up text
                                decoration:
                                    TextDecoration.underline, // Underline
                              ),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const BusinessRegisterScreen(), // Navigate to the sign-up screen
                                    ),
                                  );
                                },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                Center(
                  child: ElevatedButton(
                    onPressed: () async {
                      if (!formKey.currentState!.validate()) {
                        log("Didn't Passed the validations");

                        return;
                      }
                      final val = await AuthService.loginWithEmailPassword(
                        emailController.text,
                        passwordController.text,
                        'business',
                      );

                      log('passed the validations');
                      if (val is User) {
                        Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    const BusinessHomeScreen()),
                            (route) => false);
                      } else {
                        showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: const Text("Failed to log in"),
                              content: Text(val),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: const Text("OK"),
                                ),
                              ],
                            );
                          },
                        );
                      }
                      // Action for signing in, such as validating user credentials
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(
                          0xFFAECE77), // Darker Green login button color
                      foregroundColor: Colors.white, // Text color
                      padding: const EdgeInsets.symmetric(
                          horizontal: 50, vertical: 15),
                    ),
                    child: const Text(
                      "Login",
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                ),
                const SizedBox(height: 20), // Space below the button
              ],
            ),
          ),
        ),
      ),
    );
  }
}
