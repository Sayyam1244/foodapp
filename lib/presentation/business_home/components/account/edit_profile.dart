import 'dart:io';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:helloworld/presentation/common/custom_textfield.dart';
import 'package:helloworld/presentation/common/primary_button.dart';
import 'package:helloworld/services/firestore_service.dart';
import 'package:helloworld/services/file_picker_service.dart';
import 'package:helloworld/utils/app_validator.dart';
import 'package:helloworld/utils/colors.dart';
import 'package:helloworld/utils/textstyles.dart';
import 'package:place_picker_google/place_picker_google.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({Key? key}) : super(key: key);

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  File? image; // Holds the selected profile image
  final businessNameController = TextEditingController(); // Controller for name input
  String? categoryValue; // Selected category value
  // final locationController = TextEditingController(); // Controller for location input
  final emailController = TextEditingController(); // Controller for email input
  final phoneNumberController = TextEditingController(); // Controller for phone number input
  final formKey = GlobalKey<FormState>(); // Key for form validation
  double? selectedLatitude;
  double? selectedLongitude;
  String? selectedAddress;
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
      // locationController.text = user.location ?? '';
      emailController.text = user.email;
      phoneNumberController.text = user.phoneNumber ?? '';
      selectedLatitude = user.latitude;
      selectedLongitude = user.longitude;
      selectedAddress = user.location;
      setState(() {}); // Update UI
    }
  }

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
      backgroundColor: whiteColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(
          "Edit Profile",
          style: titleTextStyle.copyWith(color: primaryColor),
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
                  if (FirestoreService.instance.currentUser?.role == 'business')
                    Center(
                      child: InkWell(
                        onTap: () async {
                          final pickedImage = await FilePickerService.pickFile();
                          setState(() {
                            image = pickedImage; // Update selected image
                          });
                        },
                        child: CircleAvatar(
                          radius: 50,
                          backgroundColor: Colors.grey.shade200,
                          backgroundImage: image != null
                              ? FileImage(image!)
                              : FirestoreService.instance.currentUser?.image != null
                                  ? NetworkImage(FirestoreService.instance.currentUser!.image!)
                                      as ImageProvider<Object>?
                                  : null,
                          child: image == null && FirestoreService.instance.currentUser?.image == null
                              ? const Icon(Icons.camera_alt, size: 40, color: greyColor)
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
                    hintText: "",
                    validator: AppValidator.emptyCheck,
                  ),
                  const SizedBox(height: 20),
                  // Business-specific fields
                  if (FirestoreService.instance.currentUser?.role == 'business') ...[
                    Text("Select Category:",
                        style: bodyLargeTextStyle.copyWith(
                          color: greyColor, // Label text color
                        )),
                    const SizedBox(height: 10),
                    DropdownButtonFormField2<String>(
                      dropdownStyleData: DropdownStyleData(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4.0), // Rounded corners
                          color: Colors.white, // Background color
                        ),
                      ),
                      value: categoryValue,
                      validator: AppValidator.emptyCheck,
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.only(right: 10, top: 18, bottom: 18),
                        filled: true,
                        fillColor: Colors.grey.shade100, // Background color
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(4.0), // Rounded corners
                          borderSide: BorderSide.none, // No border
                        ),
                      ),
                      items: ['Restaurants', 'Cafes', 'Groceries', 'Bakeries']
                          .map((value) => DropdownMenuItem(
                                value: value,
                                child: Text(value),
                              ))
                          .toList(),
                      onChanged: (newValue) {
                        setState(() {
                          categoryValue = newValue; // Update selected category
                        });
                      },
                    ),
                    const SizedBox(height: 20),
                    // CustomTextField(
                    //   labelText: "Location (Neighborhood, Street):",
                    //   controller: locationController,
                    //   hintText: "",
                    //   validator: AppValidator.emptyCheck,
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
                  ],
                  // Customer-specific fields
                  if (FirestoreService.instance.currentUser?.role == 'customer') ...[
                    CustomTextField(
                      labelText: "Phone Number:",
                      controller: phoneNumberController,
                      hintText: "",
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
                          location: selectedAddress,
                          latitude: selectedLatitude,
                          longitude: selectedLongitude,
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
                            const SnackBar(
                                behavior: SnackBarBehavior.floating,
                                margin: EdgeInsets.only(bottom: 10, left: 10, right: 10),
                                content: Text("Profile updated successfully")),
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
