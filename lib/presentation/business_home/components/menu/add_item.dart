import 'dart:io';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:helloworld/presentation/common/custom_textfield.dart';
import 'package:helloworld/presentation/common/primary_button.dart';
import 'package:helloworld/services/file_picker_service.dart';
import 'package:helloworld/services/firestore_service.dart';
import 'package:helloworld/services/notifications_services.dart';
import 'package:helloworld/utils/app_validator.dart';
import 'package:helloworld/utils/colors.dart';
import 'package:helloworld/utils/textstyles.dart';

class AddItem extends StatefulWidget {
  const AddItem({super.key});

  @override
  State<AddItem> createState() => _AddItemState();
}

class _AddItemState extends State<AddItem> {
  File? image; // Holds the selected image file
  final productNameController = TextEditingController(); // Controller for product name
  final productDescriptionController = TextEditingController(); // Controller for product description
  final priceBeforeDiscountController = TextEditingController(); // Controller for price before discount
  final priceAfterDiscountController = TextEditingController(); // Controller for price after discount
  final weightController = TextEditingController(); // Controller for product weight
  final stockController = TextEditingController(); // Controller for stock quantity
  String? categoryValue; // Selected category value
  final formKey = GlobalKey<FormState>(); // Form key for validation

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
                      'Add Product',
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
                        backgroundColor: Colors.grey[200], // Placeholder background color
                        backgroundImage: image != null ? FileImage(image!) : null, // Display selected image
                        child: image == null
                            ? Icon(
                                Icons.camera_alt,
                                color: Colors.grey[600], // Placeholder icon
                              )
                            : null,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Product name input
                  CustomTextField(
                    labelText: 'Product Name:',
                    controller: productNameController,
                    hintText: 'Enter product name',
                    validator: AppValidator.emptyCheck, // Validate non-empty input
                  ),
                  const SizedBox(height: 20),
                  // Product description input
                  CustomTextField(
                    labelText: 'Product Description:',
                    controller: productDescriptionController,
                    hintText: 'Enter product description',
                    validator: AppValidator.emptyCheck, // Validate non-empty input
                  ),
                  const SizedBox(height: 20),
                  // Price before discount input
                  CustomTextField(
                    labelText: 'Price Before Discount:',
                    controller: priceBeforeDiscountController,
                    hintText: 'Enter price before discount',
                    validator: (value) {
                      if (AppValidator.numberCheck(value) != null) {
                        return AppValidator.numberCheck(value); // Validate numeric input
                      }
                      if (double.tryParse(value!)! <= 0) {
                        return "Price before discount must be greater than zero"; // Ensure positive value
                      }
                      return null;
                    },
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly], // Allow digits only
                    keyboardType: TextInputType.number, // Numeric keyboard
                  ),
                  const SizedBox(height: 20),
                  // Price after discount input
                  CustomTextField(
                    labelText: 'Price After Discount:',
                    controller: priceAfterDiscountController,
                    hintText: 'Enter price after discount',
                    validator: (value) {
                      if (AppValidator.numberCheck(value) != null) {
                        return AppValidator.numberCheck(value); // Validate numeric input
                      }
                      if (double.tryParse(value!)! <= 0) {
                        return "Price after discount must be greater than zero"; // Ensure positive value
                      }
                      if (double.tryParse(value)! >= double.tryParse(priceBeforeDiscountController.text)!) {
                        return "Price after discount must be less than price before discount"; // Ensure logical pricing
                      }
                      return null;
                    },
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly], // Allow digits only
                    keyboardType: TextInputType.number, // Numeric keyboard
                  ),
                  const SizedBox(height: 20),
                  // Weight input
                  CustomTextField(
                    labelText: 'Weight (g):',
                    controller: weightController,
                    hintText: 'Enter weight in grams',
                    validator: AppValidator.numberCheck, // Validate numeric input
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly], // Allow digits only
                    keyboardType: TextInputType.number, // Numeric keyboard
                  ),
                  const SizedBox(height: 20),
                  // Stock input
                  CustomTextField(
                    labelText: 'Stock:',
                    controller: stockController,
                    hintText: 'Enter stock quantity',
                    validator: AppValidator.numberCheck, // Validate numeric input
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly], // Allow digits only
                    keyboardType: TextInputType.number, // Numeric keyboard
                  ),
                  const SizedBox(height: 30),
                  // Add product button
                  Center(
                    child: PrimaryButton(
                      buttonText: 'Add Product',
                      onTap: () async {
                        if (!formKey.currentState!.validate()) {
                          return; // Stop if form is invalid
                        }
                        final val = await FirestoreService.instance.addProduct(
                          productName: productNameController.text,
                          productDescription: productDescriptionController.text,
                          priceBeforeDiscount: double.parse(priceBeforeDiscountController.text),
                          priceAfterDiscount: double.parse(priceAfterDiscountController.text),
                          weight: double.parse(weightController.text),
                          stock: int.parse(stockController.text),
                          image: image,
                        );
                        if (!val.contains('error')) {
                          // Send notifications on success
                          await sendBulkNotifications(
                            title: 'FoodSaver',
                            subtitle:
                                '${FirestoreService.instance.currentUser?.name} has added a new deal, Check it out!',
                            type: 'NEW_PRODUCT',
                            dynamicId: FirebaseAuth.instance.currentUser!.uid,
                          );
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Product Added Successfully"),
                              backgroundColor: Colors.black,
                            ),
                          );
                          clearFieldsAndImage(); // Clear form fields and image
                        } else {
                          // Show error message
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Failed to add product"),
                              backgroundColor: Colors.red,
                            ),
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

  // Clear all input fields and reset image
  void clearFieldsAndImage() {
    productNameController.clear();
    productDescriptionController.clear();
    priceBeforeDiscountController.clear();
    priceAfterDiscountController.clear();
    weightController.clear();
    stockController.clear();
    setState(() {
      image = null;
    });
  }
}
