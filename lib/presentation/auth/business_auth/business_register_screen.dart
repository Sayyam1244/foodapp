import 'dart:developer';
import 'dart:io';

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:helloworld/presentation/common/custom_textfield.dart';
import 'package:helloworld/presentation/common/primary_button.dart';
import 'package:helloworld/presentation/business_home/business_home.dart';
import 'package:helloworld/services/auth_service.dart';
import 'package:helloworld/services/file_picker_service.dart';
import 'package:helloworld/utils/app_validator.dart';
import 'package:helloworld/utils/colors.dart';
import 'package:helloworld/utils/textstyles.dart';

class BusinessRegisterScreen extends StatefulWidget {
  const BusinessRegisterScreen({Key? key}) : super(key: key);

  @override
  State<BusinessRegisterScreen> createState() => _BusinessRegisterScreenState();
}

class _BusinessRegisterScreenState extends State<BusinessRegisterScreen> {
  File? image;
  final businessNameController = TextEditingController();
  final locationController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  String? categoryValue;
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
                      'Business Register',
                      style: headlineTextStyle.copyWith(
                        color: primaryColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: InkWell(
                      onTap: () async {
                        final pickedFile = await FilePickerService.pickFile();
                        setState(() {
                          image = pickedFile;
                        });
                      },
                      child: CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.grey[200],
                        backgroundImage: image != null ? FileImage(image!) : null,
                        child: image == null
                            ? Icon(
                                Icons.camera_alt,
                                color: Colors.grey[600],
                              )
                            : null,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  CustomTextField(
                    labelText: 'Enter Business Name:',
                    controller: businessNameController,
                    hintText: 'Business Name',
                    validator: AppValidator.emptyCheck,
                  ),
                  const SizedBox(height: 20),
                  DropdownButtonFormField2<String>(
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.grey[200],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    hint: const Text('Select Category'),
                    value: categoryValue,
                    items: <String>[
                      'Restaurants',
                      'Cafes',
                      'Groceries',
                      'Bakeries',
                    ].map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        categoryValue = newValue;
                      });
                    },
                    validator: (value) => value == null ? 'Please select a category' : null,
                  ),
                  const SizedBox(height: 20),
                  CustomTextField(
                    labelText: 'Enter Location:',
                    controller: locationController,
                    hintText: 'Neighborhood, Street',
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
                        if (image == null) {
                          showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: const Text("Error"),
                                content: const Text("Please select an image"),
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
                          return;
                        }
                        final val = await AuthService.signUpWithEmailPassword(
                          email: emailController.text,
                          password: passwordController.text,
                          name: businessNameController.text,
                          category: categoryValue,
                          location: locationController.text,
                          image: image,
                          role: 'business',
                        );
                        log(val.toString());
                        if (val is User) {
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const BusinessHomeScreen(),
                            ),
                            (route) => false,
                          );
                        } else {
                          showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: const Text("Error"),
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
