import 'dart:io';
import 'package:flutter/material.dart';
import 'package:helloworld/presentation/common/custom_textfield.dart';
import 'package:helloworld/presentation/common/primary_button.dart';
import 'package:helloworld/services/firestore_service.dart';
import 'package:helloworld/services/file_picker_service.dart';
import 'package:helloworld/utils/app_validator.dart';
import 'package:helloworld/utils/colors.dart';
import 'package:helloworld/utils/textstyles.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({Key? key}) : super(key: key);

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  File? image; // Holds the selected profile image
  final businessNameController = TextEditingController(); // Controller for name input
  String? categoryValue; // Selected category value
  final locationController = TextEditingController(); // Controller for location input
  final emailController = TextEditingController(); // Controller for email input
  final phoneNumberController = TextEditingController(); // Controller for phone number input
  final formKey = GlobalKey<FormState>(); // Key for form validation

  @override
  void initState() {
    super.initState();
    _loadUserData(); // Load user data on initialization
  }

  Future<void> _loadUserData() async {
    // Fetch current user data and populate fields
    final user = FirestoreService.instance.currentUser;
    if (user != null) {
      businessNameController.text = user.name;
      categoryValue = user.category;
      locationController.text = user.location ?? '';
      emailController.text = user.email;
      phoneNumberController.text = user.phoneNumber ?? '';
      setState(() {}); // Update UI
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(
          "Edit Profile",
          style: headlineTextStyle.copyWith(color: primaryColor),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: formKey, // Attach form key for validation
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Profile image picker
                  Center(
                    child: InkWell(
                      onTap: () async {
                        final pickedImage = await FilePickerService.pickFile();
                        setState(() {
                          image = pickedImage; // Update selected image
                        });
                      },
                      child: CircleAvatar(
                        radius: 75,
                        backgroundColor: Colors.grey.shade200,
                        backgroundImage: image != null
                            ? FileImage(image!)
                            : FirestoreService.instance.currentUser?.image != null
                                ? NetworkImage(FirestoreService.instance.currentUser!.image!)
                                    as ImageProvider<Object>?
                                : null,
                        child: image == null && FirestoreService.instance.currentUser?.image == null
                            ? const Icon(Icons.camera_alt, size: 50, color: primaryColor)
                            : null,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Name input field
                  CustomTextField(
                    labelText: FirestoreService.instance.currentUser?.role == 'business'
                        ? "Business Name:"
                        : "Name:",
                    controller: businessNameController,
                    hintText: "Enter your name",
                    validator: AppValidator.emptyCheck,
                  ),
                  const SizedBox(height: 20),
                  // Business-specific fields
                  if (FirestoreService.instance.currentUser?.role == 'business') ...[
                    DropdownButtonFormField<String>(
                      value: categoryValue,
                      validator: AppValidator.emptyCheck,
                      decoration: const InputDecoration(border: InputBorder.none),
                      items: ['Restaurants', 'Cafes', 'Groceries', 'Bakeries']
                          .map((value) => DropdownMenuItem(
                                value: value,
                                child: Text(value, style: bodyLargeTextStyle),
                              ))
                          .toList(),
                      onChanged: (newValue) {
                        setState(() {
                          categoryValue = newValue; // Update selected category
                        });
                      },
                    ),
                    const SizedBox(height: 20),
                    CustomTextField(
                      labelText: "Location (Neighborhood, Street):",
                      controller: locationController,
                      hintText: "Enter location",
                      validator: AppValidator.emptyCheck,
                    ),
                  ],
                  // Customer-specific fields
                  if (FirestoreService.instance.currentUser?.role == 'customer') ...[
                    CustomTextField(
                      labelText: "Phone Number:",
                      controller: phoneNumberController,
                      hintText: "Enter your phone number",
                      validator: AppValidator.phoneCheck,
                    ),
                  ],
                  const SizedBox(height: 30),
                  // Save button
                  Center(
                    child: PrimaryButton(
                      buttonText: "Save",
                      onTap: () async {
                        if (!formKey.currentState!.validate()) return; // Validate form

                        // Update user data
                        final user = FirestoreService.instance.currentUser!.copyWith(
                          name: businessNameController.text,
                          category: categoryValue,
                          location: locationController.text,
                          phoneNumber: phoneNumberController.text,
                        );

                        // Save updated user data
                        final result = await FirestoreService.instance.setUser(user, image: image);

                        if (result is String) {
                          // Show error message
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result)));
                        } else {
                          // Show success message and navigate back
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Profile updated successfully")),
                          );
                          Navigator.pop(context);
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
