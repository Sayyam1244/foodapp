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
import 'package:place_picker_google/place_picker_google.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BusinessRegisterScreen extends StatefulWidget {
  const BusinessRegisterScreen({Key? key}) : super(key: key);

  @override
  State<BusinessRegisterScreen> createState() => _BusinessRegisterScreenState();
}

class _BusinessRegisterScreenState extends State<BusinessRegisterScreen> {
  File? image; // Holds the selected image file
  final businessNameController = TextEditingController(); // Controller for business name input
  final emailController = TextEditingController(); // Controller for email input
  final passwordController = TextEditingController(); // Controller for password input
  String? categoryValue; // Selected category value
  final formKey = GlobalKey<FormState>(); // Form key for validation

  // State variables to store selected location
  double? selectedLatitude;
  double? selectedLongitude;
  String? selectedAddress;

  // Password rules to display
  final passRulesList = [
    "• Password must contain at least one letter",
    "• Password must contain at least one number",
    "• Password must be longer than 8 characters",
  ];

  // Function to open place picker
  Future<void> _openPlacePicker() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PlacePicker(
          enableNearbyPlaces: false,
          apiKey: "AIzaSyCNOwAsoA8vCB-bzW_0Sk_sIay_a8NBeIo",
          onPlacePicked: (result) {
            setState(() {
              selectedLatitude = result.latLng?.latitude;
              selectedLongitude = result.latLng?.longitude;
              selectedAddress = result.formattedAddress;
            });
            Navigator.of(context).pop();
          },
        ),
      ),
    );
  }

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
                  // Location selection button
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(10),
                      color: selectedAddress != null ? Colors.grey : Colors.white,
                    ),
                    child: InkWell(
                      onTap: _openPlacePicker,
                      child: Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            color: selectedAddress != null ? Colors.white : Colors.grey,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              selectedAddress ?? 'Select Location',
                              style: bodyMediumTextStyle.copyWith(
                                  color: selectedAddress != null ? Colors.white : Colors.grey),
                            ),
                          ),
                        ],
                      ),
                    ),
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
                        // Validate location selection
                        if (selectedLatitude == null || selectedLongitude == null) {
                          showDialog(
                            context: context,
                            builder: (context) {
                              return CustomDialogue(
                                title: "Location Required",
                                content: "Please select a location.",
                                action: () {
                                  Navigator.pop(context);
                                },
                              );
                            },
                          );
                          return;
                        }
                        // Attempt to register the user
                        final val = await AuthService.signUpWithEmailPassword(
                          email: emailController.text,
                          password: passwordController.text,
                          name: businessNameController.text,
                          category: categoryValue,
                          location: selectedAddress,
                          image: image,
                          role: 'business',
                        );
                        log(val.toString());
                        if (val is User) {
                          // Save additional location data to Firestore
                          await FirebaseFirestore.instance.collection('users').doc(val.uid).set({
                            'name': businessNameController.text,
                            'email': emailController.text,
                            'category': categoryValue,
                            'role': 'business',
                            'latitude': selectedLatitude,
                            'longitude': selectedLongitude,
                            'location': selectedAddress,
                          });
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
