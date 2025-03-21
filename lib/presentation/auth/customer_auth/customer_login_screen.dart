import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart'; // Import for TapGestureRecognizer
import 'package:firebase_auth/firebase_auth.dart';
import 'package:helloworld/presentation/common/custom_textfield.dart';
import 'package:helloworld/presentation/common/primary_button.dart';
import 'package:helloworld/presentation/customer_home/customer_home.dart';
import 'package:helloworld/presentation/reset_password_screen.dart';
import 'package:helloworld/services/auth_service.dart';
import 'package:helloworld/utils/app_validator.dart';
import 'package:helloworld/utils/colors.dart';
import 'package:helloworld/utils/textstyles.dart';
import 'customer_register_screen.dart'; // Import for the sign-up screen

class CustomerLoginScreen extends StatefulWidget {
  const CustomerLoginScreen({Key? key}) : super(key: key);
  @override
  State<CustomerLoginScreen> createState() => _CustomerLoginScreenState();
}

class _CustomerLoginScreenState extends State<CustomerLoginScreen> {
  final emailController = TextEditingController(text: 'customer@gmail.com');
  final passwordController = TextEditingController(text: '12345678A');
  final formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: formKey,
            child: Column(
              // mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Text(
                    'Customer Login',
                    style: headlineTextStyle.copyWith(
                      color: primaryColor,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                CustomTextField(
                  labelText: 'Enter Email:',
                  controller: emailController,
                  hintText: 'Email',
                  validator: AppValidator.emailCheck,
                ),
                const SizedBox(height: 20),
                CustomTextField(
                  labelText: 'Enter Password:',
                  controller: passwordController,
                  hintText: '********',
                  validator: AppValidator.passwordCheck,
                  obscureText: true,
                ),
                const SizedBox(height: 30),
                Center(
                  child: Column(
                    children: [
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
                          style: bodyLargeTextStyle.copyWith(
                            decoration: TextDecoration.underline,
                            color: primaryColor,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      PrimaryButton(
                          buttonText: 'Login',
                          onTap: () async {
                            if (!formKey.currentState!.validate()) {
                              return;
                            }
                            final val = await AuthService.loginWithEmailPassword(
                              emailController.text,
                              passwordController.text,
                              'customer',
                            );

                            if (val is User) {
                              Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const CustomerHomeScreen(),
                                ),
                                (route) => false,
                              );
                            } else {
                              showDialog(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    title: const Text("Failed to log in"),
                                    content: Text(val.toString()), // Error message
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
                          }),
                      const SizedBox(height: 10),
                      RichText(
                        text: TextSpan(
                          children: [
                            const TextSpan(text: "Don't have an account? ", style: bodyLargeTextStyle),
                            TextSpan(
                              text: "Sign up",
                              style: bodyLargeTextStyle.copyWith(
                                color: primaryColor,
                                decoration: TextDecoration.underline,
                              ),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const CustomerRegisterScreen(), // Navigate to the sign-up screen
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
