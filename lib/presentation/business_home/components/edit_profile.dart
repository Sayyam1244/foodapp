import 'dart:io';
import 'package:flutter/material.dart';
import 'package:helloworld/model/user_model.dart';
import 'package:helloworld/services/auth_service.dart';
import 'package:helloworld/services/firestore_service.dart';
import 'package:helloworld/services/file_picker_service.dart';
import 'package:helloworld/utils/app_validator.dart';

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
    UserModel? user = FirestoreService.instance.currentUser;
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
      backgroundColor: const Color(0xFF517F03), // Green background
      appBar: AppBar(
        title: const Text(
          "Edit Profile",
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
                        child: FirestoreService.instance.currentUser?.image !=
                                null
                            ? Image.network(
                                FirestoreService.instance.currentUser!.image!)
                            : image == null
                                ? const Icon(
                                    Icons.camera_alt,
                                    size: 50,
                                    color: Color(
                                        0xFF517F03), // Green color for icon
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
                    value: categoryValue,
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

                  const SizedBox(height: 30),
                  Center(
                    child: ElevatedButton(
                      onPressed: () async {
                        if (!formKey.currentState!.validate()) {
                          return;
                        }
                        UserModel user = UserModel(
                          uid: FirestoreService.instance.currentUser!.uid,
                          name: businessNameController.text,
                          email: emailController.text,
                          phoneNumber: phoneNumberController.text,
                          category: categoryValue,
                          location: locationController.text,
                          role: FirestoreService.instance.currentUser!.role,
                          isDeleted: false,
                        );
                        await FirestoreService.instance.setUser(
                          user,
                          image: image,
                        );
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(
                            0xFFAECE77), // Darker Green save button color
                        foregroundColor: Colors.white, // Text color
                        padding: const EdgeInsets.symmetric(
                            horizontal: 50, vertical: 15),
                      ),
                      child: const Text(
                        "Save",
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
