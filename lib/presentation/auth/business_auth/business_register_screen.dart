import 'dart:developer';
import 'dart:io';

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:helloworld/presentation/common/custom_dialogue.dart';
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
  File? image; // Holds the selected image file
  final businessNameController = TextEditingController(); // Controller for business name input
  final locationController = TextEditingController(); // Controller for location input
  final emailController = TextEditingController(); // Controller for email input
  final passwordController = TextEditingController(); // Controller for password input
  String? categoryValue; // Selected category value
  final formKey = GlobalKey<FormState>(); // Form key for validation

  // Password rules to display
  final passRulesList = [
    "• Password must contain at least one letter",
    "• Password must contain at least one number",
    "• Password must be longer than 8 characters",
  ];

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
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Center(
                    child: Text(
                      'Business Register',
                      style: headlineTextStyle.copyWith(
                        color: primaryColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Image picker
                  Center(
                    child: InkWell(
                      onTap: () async {
                        final pickedFile = await FilePickerService.pickFile(); // Pick an image file
                        setState(() {
                          image = pickedFile; // Update the selected image
                        });
                      },
                      child: CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.grey[200],
                        backgroundImage: image != null ? FileImage(image!) : null, // Display selected image
                        child: image == null
                            ? Icon(
                                Icons.camera_alt,
                                color: Colors.grey[600],
                              )
                            : null, // Show camera icon if no image is selected
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Business name input
                  CustomTextField(
                    labelText: 'Enter Business Name:',
                    controller: businessNameController,
                    hintText: '',
                    validator: AppValidator.emptyCheck, // Validate non-empty input
                  ),
                  const SizedBox(height: 20),
                  Text('Select Category:',
                      style: bodyLargeTextStyle.copyWith(
                        color: greyColor, // Label text color
                      )),
                  const SizedBox(height: 10),
                  // Category dropdown
                  DropdownButtonFormField2<String>(
                    dropdownStyleData: DropdownStyleData(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4.0), // Rounded corners
                        color: Colors.white, // Background color
                      ),
                    ),

                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.only(right: 10, top: 18, bottom: 18),
                      filled: true,
                      fillColor: Colors.grey.shade100, // Background color
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(4.0), // Rounded corners
                        borderSide: BorderSide.none, // No border
                      ),
                    ),

                    hint: const Text('Select'),
                    value: categoryValue, // Selected category
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
                        categoryValue = newValue; // Update selected category
                      });
                    },
                    validator: (value) =>
                        value == null ? 'Please select a category' : null, // Validate selection
                  ),
                  const SizedBox(height: 20),
                  // Location input
                  CustomTextField(
                    labelText: 'Enter Location:',
                    controller: locationController,
                    hintText: '',
                    validator: AppValidator.emptyCheck, // Validate non-empty input
                  ),
                  const SizedBox(height: 20),
                  // Email input
                  CustomTextField(
                    labelText: 'Enter Email:',
                    controller: emailController,
                    hintText: '',
                    validator: AppValidator.emailCheck, // Validate email format
                  ),
                  const SizedBox(height: 20),
                  // Password input
                  CustomTextField(
                    labelText: 'Enter Password:',
                    controller: passwordController,
                    hintText: '',
                    validator: AppValidator.passwordCheck, // Validate password rules
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
                      buttonText: 'Register',
                      onTap: () async {
                        if (!formKey.currentState!.validate()) {
                          return; // Stop if form is invalid
                        }
                        // if (image == null) {
                        //   // Show error if no image is selected
                        //   showDialog(
                        //     context: context,
                        //     builder: (context) {
                        //       return CustomDialogue(
                        //           title: ("Error"),
                        //           content: ("Please select an image"),
                        //           action: () {
                        //             Navigator.pop(context);
                        //           });
                        //     },
                        //   );
                        //   return;
                        // }
                        // Attempt to register the user
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
                                title: ("Error"),
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
