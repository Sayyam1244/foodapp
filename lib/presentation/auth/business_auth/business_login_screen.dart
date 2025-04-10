import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart'; // Import for TapGestureRecognizer
import 'package:firebase_auth/firebase_auth.dart';
import 'package:helloworld/presentation/common/custom_dialogue.dart';
import 'package:helloworld/presentation/common/custom_textfield.dart';
import 'package:helloworld/presentation/common/primary_button.dart';
import 'package:helloworld/presentation/business_home/business_home.dart';
import 'package:helloworld/presentation/reset_password_screen.dart';
import 'package:helloworld/services/auth_service.dart';
import 'package:helloworld/utils/app_validator.dart';
import 'package:helloworld/utils/colors.dart';
import 'package:helloworld/utils/textstyles.dart';
import 'business_register_screen.dart'; // Import for the sign-up screen

class BusinessLoginScreen extends StatefulWidget {
  const BusinessLoginScreen({Key? key}) : super(key: key);

  @override
  State<BusinessLoginScreen> createState() => _BusinessLoginScreenState();
}

class _BusinessLoginScreenState extends State<BusinessLoginScreen> {
  // Controllers for email and password input fields
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final formKey = GlobalKey<FormState>(); // Form key for validation

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteColor, // Set background color
      appBar: AppBar(
        backgroundColor: Colors.transparent, // Transparent app bar
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0), // Add padding around the form
          child: Form(
            key: formKey, // Attach form key for validation
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Center(
                  child: Text(
                    'Business Login',
                    style: headlineTextStyle.copyWith(color: primaryColor),
                  ),
                ),
                const SizedBox(height: 20), // Spacing
                // Email input field
                CustomTextField(
                  prefixIcon: const Icon(Icons.email_outlined),
                  labelText: 'Enter Email:',
                  controller: emailController,
                  hintText: '',
                  validator: AppValidator.emailCheck, // Email validation
                ),
                const SizedBox(height: 20), // Spacing
                // Password input field
                CustomTextField(
                  prefixIcon: const Icon(Icons.lock_outline),
                  labelText: 'Enter Password:',
                  controller: passwordController,
                  hintText: '',
                  validator: AppValidator.passwordCheck, // Password validation
                  obscureText: true, // Hide password input
                ),
                const SizedBox(height: 30), // Spacing
                Center(
                  child: Column(
                    children: [
                      // Forgot password link
                      InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ResetPasswordScreen(),
                            ),
                          );
                        },
                        child: Text(
                          'Forgot Password?',
                          style: bodyMediumTextStyle.copyWith(
                            decoration: TextDecoration.underline,
                            color: primaryColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(height: 80), // Spacing
                      // Login button
                      PrimaryButton(
                        buttonText: 'Login',
                        onTap: () async {
                          if (!formKey.currentState!.validate()) {
                            log("Didn't pass the validations"); // Log validation failure
                            return;
                          }
                          // Attempt login
                          final val = await AuthService.loginWithEmailPassword(
                            emailController.text,
                            passwordController.text,
                            'business',
                          );

                          if (val is User) {
                            // Navigate to home screen on success
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const BusinessHomeScreen(),
                              ),
                              (route) => false,
                            );
                          } else {
                            // Show error dialog on failure
                            showDialog(
                              context: context,
                              builder: (context) {
                                return CustomDialogue(
                                  title: ("Failed to log in"),
                                  content: (val.toString()), // Error message
                                  action: () {
                                    Navigator.pop(context);
                                  },
                                );
                              },
                            );
                          }
                        },
                      ),
                      const SizedBox(height: 16), // Spacing
                      // Sign-up link
                      RichText(
                        text: TextSpan(
                          children: [
                            const TextSpan(text: "Don't have an account? ", style: bodyMediumTextStyle),
                            TextSpan(
                              text: "Sign up",
                              style: bodyMediumTextStyle.copyWith(
                                color: primaryColor,
                                decoration: TextDecoration.underline,
                                fontWeight: FontWeight.w500,
                              ),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const BusinessRegisterScreen(),
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
