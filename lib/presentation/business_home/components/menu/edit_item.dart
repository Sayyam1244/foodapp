import 'dart:developer';
import 'dart:io';

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:helloworld/model/product_model.dart';
import 'package:helloworld/presentation/common/custom_textfield.dart';
import 'package:helloworld/presentation/common/primary_button.dart';
import 'package:helloworld/services/file_picker_service.dart';
import 'package:helloworld/services/firestore_service.dart';
import 'package:helloworld/utils/app_validator.dart';
import 'package:helloworld/utils/colors.dart';
import 'package:helloworld/utils/textstyles.dart';

class EditItem extends StatefulWidget {
  final ProductModel product;

  const EditItem({super.key, required this.product});

  @override
  State<EditItem> createState() => _EditItemState();
}

class _EditItemState extends State<EditItem> {
  File? image; // Holds the selected image file
  final productNameController = TextEditingController(); // Controller for product name
  final productDescriptionController = TextEditingController(); // Controller for product description
  final priceBeforeDiscountController = TextEditingController(); // Controller for price before discount
  final priceAfterDiscountController = TextEditingController(); // Controller for price after discount
  final weightController = TextEditingController(); // Controller for product weight
  final stockController = TextEditingController(); // Controller for stock quantity
  final formKey = GlobalKey<FormState>(); // Key for form validation

  @override
  void initState() {
    super.initState();
    _loadProductData(); // Load product data into controllers
  }

  void _loadProductData() {
    // Initialize controllers with product data
    productNameController.text = widget.product.productName;
    productDescriptionController.text = widget.product.productDescription;
    priceBeforeDiscountController.text = widget.product.priceBeforeDiscount.toString();
    priceAfterDiscountController.text = widget.product.priceAfterDiscount.toString();
    weightController.text = widget.product.weight.toString();
    stockController.text = widget.product.stock.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(
          'Edit Product',
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
                  // Image picker section
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
                        backgroundImage: image != null
                            ? FileImage(image!) // Display selected image
                            : (widget.product.imageUrl != null
                                ? NetworkImage(widget.product.imageUrl!) // Display existing image
                                : null) as ImageProvider?,
                        child: image == null && widget.product.imageUrl == null
                            ? Icon(
                                Icons.camera_alt,
                                color: Colors.grey[600],
                              )
                            : null,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Product name input field
                  CustomTextField(
                    labelText: 'Product Name:',
                    controller: productNameController,
                    hintText: 'Enter product name',
                    validator: AppValidator.emptyCheck, // Validate non-empty input
                  ),
                  const SizedBox(height: 20),
                  // Product description input field
                  CustomTextField(
                    labelText: 'Product Description:',
                    controller: productDescriptionController,
                    hintText: 'Enter product description',
                    validator: AppValidator.emptyCheck, // Validate non-empty input
                  ),
                  const SizedBox(height: 20),
                  // Price before discount input field
                  CustomTextField(
                    labelText: 'Price Before Discount:',
                    controller: priceBeforeDiscountController,
                    hintText: 'Enter price before discount',
                    validator: (value) {
                      if (AppValidator.numberCheck(value) != null) {
                        return AppValidator.numberCheck(value); // Validate numeric input
                      }
                      if (double.tryParse(value!)! <= 0) {
                        return "Price before discount must be greater than zero";
                      }
                      return null;
                    },
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly], // Allow only digits
                  ),
                  const SizedBox(height: 20),
                  // Price after discount input field
                  CustomTextField(
                    labelText: 'Price After Discount:',
                    controller: priceAfterDiscountController,
                    hintText: 'Enter price after discount',
                    validator: (value) {
                      if (AppValidator.numberCheck(value) != null) {
                        return AppValidator.numberCheck(value); // Validate numeric input
                      }
                      if (double.tryParse(value!)! <= 0) {
                        return "Price after discount must be greater than zero";
                      }
                      if (double.tryParse(value)! >= double.tryParse(priceBeforeDiscountController.text)!) {
                        return "Price after discount must be less than price before discount";
                      }
                      return null;
                    },
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly], // Allow only digits
                  ),
                  const SizedBox(height: 20),
                  // Weight input field
                  CustomTextField(
                    labelText: 'Weight (g):',
                    controller: weightController,
                    hintText: 'Enter weight in grams',
                    validator: AppValidator.numberCheck, // Validate numeric input
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 20),
                  // Stock input field
                  CustomTextField(
                    labelText: 'Stock:',
                    controller: stockController,
                    hintText: 'Enter stock quantity',
                    validator: AppValidator.numberCheck, // Validate numeric input
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly], // Allow only digits
                  ),
                  const SizedBox(height: 30),
                  // Save changes button
                  Center(
                    child: PrimaryButton(
                      buttonText: 'Save Changes',
                      onTap: () async {
                        if (!formKey.currentState!.validate()) {
                          return; // Stop if form is invalid
                        }
                        final val = await FirestoreService.instance.updateProduct(
                          id: widget.product.id,
                          productName: productNameController.text,
                          productDescription: productDescriptionController.text,
                          priceBeforeDiscount: double.parse(priceBeforeDiscountController.text),
                          priceAfterDiscount: double.parse(priceAfterDiscountController.text),
                          weight: double.parse(weightController.text),
                          stock: int.parse(stockController.text),
                          image: image, // Pass the selected image
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            behavior: SnackBarBehavior.floating,
                            margin: const EdgeInsets.only(bottom: 10, left: 10, right: 10),
                            content: Text(val), // Show success or error message
                            // backgroundColor: Colors.black,
                          ),
                        );
                        Navigator.pop(context); // Navigate back after saving
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
