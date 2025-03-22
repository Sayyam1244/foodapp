import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
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
  final customerNameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final phoneNumberController = TextEditingController();
  final formKey = GlobalKey<FormState>();

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
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Text(
                      'Customer Register',
                      style: headlineTextStyle.copyWith(
                        color: primaryColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  CustomTextField(
                    labelText: 'Enter Name:',
                    controller: customerNameController,
                    hintText: 'Name',
                    validator: AppValidator.emptyCheck,
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
                    labelText: 'Enter Phone Number:',
                    controller: phoneNumberController,
                    hintText: 'Phone Number',
                    validator: AppValidator.phoneCheck,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                  ),
                  const SizedBox(height: 20),
                  CustomTextField(
                    labelText: 'Enter Password:',
                    controller: passwordController,
                    hintText: '********',
                    validator: AppValidator.passwordCheck,
                    obscureText: true,
                  ),
                  const SizedBox(height: 10),
                  ...passRulesList.map(
                    (rule) => Text(
                      rule,
                      style: bodySmallTextStyle.copyWith(color: Colors.grey),
                    ),
                  ),
                  const SizedBox(height: 30),
                  Center(
                    child: PrimaryButton(
                      buttonText: 'Register',
                      onTap: () async {
                        if (!formKey.currentState!.validate()) {
                          return;
                        }
                        final val = await AuthService.signUpWithEmailPassword(
                          phoneNumber: phoneNumberController.text,
                          email: emailController.text,
                          password: passwordController.text,
                          name: customerNameController.text,
                          role: "customer",
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
                                title: const Text("Failed to register"),
                                content: Text(val.toString()),
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
