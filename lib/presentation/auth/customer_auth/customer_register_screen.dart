import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:helloworld/presentation/common/custom_dialogue.dart';
import 'package:helloworld/presentation/common/custom_textfield.dart';
import 'package:helloworld/presentation/common/primary_button.dart';
import 'package:helloworld/presentation/customer_home/customer_home.dart';
import 'package:helloworld/services/auth_service.dart';
import 'package:helloworld/utils/app_validator.dart';
import 'package:helloworld/utils/colors.dart';
import 'package:helloworld/utils/textstyles.dart';

class CustomerRegisterScreen extends StatefulWidget {
  const CustomerRegisterScreen({Key? key}) : super(key: key);

  @override
  State<CustomerRegisterScreen> createState() => _CustomerRegisterScreenState();
}

class _CustomerRegisterScreenState extends State<CustomerRegisterScreen> {
  // Controllers for form fields
  final customerNameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final phoneNumberController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  // Password rules to display
  final passRulesList = [
    "• Password must contain at least one letter",
    "• Password must contain at least one number",
    "• Password must be longer than 8 characters",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent, // Transparent app bar
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0), // Padding around the form
          child: Form(
            key: formKey, // Form key for validation
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Center(
                    child: Text(
                      'Customer Sign up',
                      style: headlineTextStyle.copyWith(
                        color: primaryColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Name input field
                  CustomTextField(
                    labelText: 'Enter Name:',
                    controller: customerNameController,
                    hintText: '',
                    validator: AppValidator.emptyCheck,
                  ),
                  const SizedBox(height: 20),
                  // Email input field
                  CustomTextField(
                    labelText: 'Enter Email:',
                    controller: emailController,
                    hintText: '',
                    validator: AppValidator.emailCheck,
                  ),
                  const SizedBox(height: 20),
                  // Phone number input field
                  CustomTextField(
                    labelText: 'Enter Phone Number:',
                    controller: phoneNumberController,
                    hintText: '',
                    validator: AppValidator.phoneCheck,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly, // Allow digits only
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Password input field
                  CustomTextField(
                    labelText: 'Enter Password:',
                    controller: passwordController,
                    hintText: '',
                    validator: AppValidator.passwordCheck,
                    obscureText: true, // Hide password input
                  ),
                  const SizedBox(height: 10),
                  // Display password rules
                  ...passRulesList.map(
                    (rule) => Text(
                      rule,
                      style: bodySmallTextStyle.copyWith(color: Colors.grey),
                    ),
                  ),
                  const SizedBox(height: 30),
                  // Register button
                  Center(
                    child: PrimaryButton(
                      buttonText: 'Sign up',
                      onTap: () async {
                        // Validate form
                        if (!formKey.currentState!.validate()) {
                          return;
                        }
                        // Attempt registration
                        final val = await AuthService.signUpWithEmailPassword(
                          phoneNumber: phoneNumberController.text,
                          email: emailController.text,
                          password: passwordController.text,
                          name: customerNameController.text,
                          role: "customer",
                        );
                        // Navigate to home screen if successful
                        if (val is User) {
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const CustomerHomeScreen(),
                            ),
                            (route) => false,
                          );
                        } else {
                          // Show error dialog if registration fails
                          showDialog(
                            context: context,
                            builder: (context) {
                              return CustomDialogue(
                                title: ("Failed to register"),
                                content: (val.toString()),
                                action: () {
                                  Navigator.pop(context);
                                },
                              );
                            },
                          );
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
