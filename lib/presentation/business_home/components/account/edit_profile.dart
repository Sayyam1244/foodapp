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
  File? image;
  final businessNameController = TextEditingController();
  String? categoryValue;
  final locationController = TextEditingController();
  final emailController = TextEditingController();
  final phoneNumberController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = FirestoreService.instance.currentUser;
    if (user != null) {
      businessNameController.text = user.name;
      categoryValue = user.category;
      locationController.text = user.location ?? '';
      emailController.text = user.email;
      phoneNumberController.text = user.phoneNumber ?? '';
      setState(() {});
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
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: InkWell(
                      onTap: () async {
                        final pickedImage = await FilePickerService.pickFile();
                        setState(() {
                          image = pickedImage;
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
                  CustomTextField(
                    labelText: FirestoreService.instance.currentUser?.role == 'business'
                        ? "Business Name:"
                        : "Name:",
                    controller: businessNameController,
                    hintText: "Enter your name",
                    validator: AppValidator.emptyCheck,
                  ),
                  const SizedBox(height: 20),
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
                          categoryValue = newValue;
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
                  if (FirestoreService.instance.currentUser?.role == 'customer') ...[
                    CustomTextField(
                      labelText: "Phone Number:",
                      controller: phoneNumberController,
                      hintText: "Enter your phone number",
                      validator: AppValidator.phoneCheck,
                    ),
                  ],
                  const SizedBox(height: 30),
                  Center(
                    child: PrimaryButton(
                      buttonText: "Save",
                      onTap: () async {
                        if (!formKey.currentState!.validate()) return;

                        final user = FirestoreService.instance.currentUser!.copyWith(
                          name: businessNameController.text,
                          category: categoryValue,
                          location: locationController.text,
                          phoneNumber: phoneNumberController.text,
                        );

                        final result = await FirestoreService.instance.setUser(user, image: image);

                        if (result is String) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result)));
                        } else {
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
