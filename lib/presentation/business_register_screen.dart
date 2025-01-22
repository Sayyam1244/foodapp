import 'dart:developer';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:helloworld/presentation/home_screen.dart';
import 'package:helloworld/services/auth_service.dart';
import 'package:helloworld/services/file_picker_service.dart';
import 'package:helloworld/utils/app_validator.dart';

class BusinessRegisterScreen extends StatefulWidget {
  const BusinessRegisterScreen({Key? key}) : super(key: key);

  @override
  State<BusinessRegisterScreen> createState() => _BusinessRegisterScreenState();
}

class _BusinessRegisterScreenState extends State<BusinessRegisterScreen> {
  File? image;
  final businessNameController = TextEditingController();
  String? categoryValue;
  final locationController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF517F03), // Green background
      appBar: AppBar(
        title: const Text(
          "Business Sign Up",
          style: TextStyle(color: Color(0xFFFFF4E2)), // Beige color for text
        ),
        backgroundColor: const Color(0xFF517F03), // Match background color
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
          child: SingleChildScrollView(
            // Allows scrolling for small screens
            child: Form(
              key: formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: InkWell(
                      onTap: () {
                        FilePickerService.pickFile().then((value) {
                          setState(() {
                            image = value;
                          });
                        });
                      },
                      child: Container(
                        height: 150,
                        width: 150,
                        clipBehavior: Clip.hardEdge,
                        decoration: const BoxDecoration(
                          color: Color(0xFFFFF4E2), // Beige background
                          shape: BoxShape.circle,
                        ),
                        child: image == null
                            ? const Icon(
                                Icons.camera_alt,
                                size: 50,
                                color:
                                    Color(0xFF517F03), // Green color for icon
                              )
                            : Image.file(
                                image!,
                                fit: BoxFit.cover,
                              ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "Business Name:",
                    style: TextStyle(
                      fontSize: 18,
                      color: Color(0xFFFFF4E2), // Beige color for text
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: businessNameController,
                    validator: AppValidator.emptyCheck,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: const Color(0xFFFFF4E2), // Beige background
                      border: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(30.0), // Rounded corners
                        borderSide: BorderSide.none, // No border line
                      ),
                      hintText: "Enter business name",
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "Category:",
                    style: TextStyle(
                      fontSize: 18,
                      color: Color(0xFFFFF4E2), // Beige color for text
                    ),
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    validator: AppValidator.emptyCheck,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: const Color(0xFFFFF4E2), // Beige background
                      border: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(30.0), // Rounded corners
                        borderSide: BorderSide.none,
                      ),
                    ),
                    hint: const Text("Select category"),
                    items: <String>[
                      'Restaurants',
                      'Cafes',
                      'Groceries',
                      'Bakeries',
                    ].map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(
                          value,
                          style: const TextStyle(
                            color: Color(
                                0xFF517F03), // Text color for dropdown items
                            fontSize: 16,
                          ),
                        ),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      categoryValue = newValue;
                    },
                    // Keep the dropdown from filling the entire screen
                    isExpanded: false,
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "Location (Neighborhood, Street):",
                    style: TextStyle(
                      fontSize: 18,
                      color: Color(0xFFFFF4E2), // Beige color for text
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: locationController,
                    validator: AppValidator.emptyCheck,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: const Color(0xFFFFF4E2), // Beige background
                      border: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(30.0), // Rounded corners
                        borderSide: BorderSide.none, // No border line
                      ),
                      hintText: "Enter location",
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "Email:",
                    style: TextStyle(
                      fontSize: 18,
                      color: Color(0xFFFFF4E2), // Beige color for text
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: emailController,
                    validator: AppValidator.emptyCheck,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: const Color(0xFFFFF4E2),
                      // Beige background
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
                    "Password:",
                    style: TextStyle(
                      fontSize: 18,
                      color: Color(0xFFFFF4E2), // Beige color for text
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: passwordController,
                    validator: AppValidator.emptyCheck,
                    obscureText: true,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: const Color(0xFFFFF4E2), // Beige background
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
                    child: ElevatedButton(
                      onPressed: () async {
                        // if (image == null) {
                        //   showDialog(
                        //       context: context,
                        //       builder: (context) {
                        //         return AlertDialog(
                        //           title: const Text("Error"),
                        //           content: const Text("Please select an image"),
                        //           actions: [
                        //             TextButton(
                        //               onPressed: () {
                        //                 Navigator.pop(context);
                        //               },
                        //               child: const Text("OK"),
                        //             ),
                        //           ],
                        //         );
                        //       });
                        //   return;
                        // }
                        if (!formKey.currentState!.validate()) {
                          return;
                        }
                        log('Signing up');
                        // Save the data
                        final val = await AuthService.signUpWithEmailPassword(
                          email: emailController.text,
                          password: passwordController.text,
                          name: businessNameController.text,
                          category: categoryValue,
                          location: locationController.text,
                          image: image,
                          role: 'business',
                        );

                        if (val.runtimeType == User) {
                          Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const HomeScreen()),
                              (route) => false);
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
                              });
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(
                            0xFFAECE77), // Darker Green save button color
                        foregroundColor: Colors.white, // Text color
                        padding: const EdgeInsets.symmetric(
                            horizontal: 50, vertical: 15),
                      ),
                      child: const Text(
                        "Sign Up",
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
      ),
    );
  }
}
