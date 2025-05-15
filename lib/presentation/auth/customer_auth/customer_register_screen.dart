import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:helloworld/presentation/common/custom_dialogue.dart';
import 'package:helloworld/presentation/common/custom_textfield.dart';
import 'package:helloworld/presentation/common/primary_button.dart';
import 'package:helloworld/presentation/customer_home/customer_home.dart';
import 'package:helloworld/services/auth_service.dart';
import 'package:helloworld/utils/app_validator.dart';
import 'package:helloworld/utils/colors.dart';
import 'package:helloworld/utils/textstyles.dart';
import 'package:place_picker_google/place_picker_google.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
          apiKey: "AIzaSyCNOwAsoA8vCB-bzW_0Sk_sIay_a8NBeIo",
          enableNearbyPlaces: false,
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
                  const SizedBox(height: 20),
                  // Location selection button
                  // ElevatedButton(
                  //   onPressed: _openPlacePicker,
                  //   child: Text(selectedAddress ?? 'Select Location'),
                  // ),
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
                          // Save additional location data to Firestore
                          await FirebaseFirestore.instance.collection('users').doc(val.uid).set({
                            'name': customerNameController.text,
                            'email': emailController.text,
                            'phoneNumber': phoneNumberController.text,
                            'role': 'customer',
                            'latitude': selectedLatitude,
                            'longitude': selectedLongitude,
                            'location': selectedAddress,
                          });
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
