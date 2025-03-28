import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:helloworld/services/file_picker_service.dart';
import 'package:helloworld/services/firestore_service.dart';
import 'package:helloworld/services/notifications_services.dart';
import 'package:helloworld/utils/app_validator.dart';

class AddItem extends StatefulWidget {
  const AddItem({super.key});

  @override
  State<AddItem> createState() => _AddItemState();
}

class _AddItemState extends State<AddItem> {
  File? image;
  final productNameController = TextEditingController();
  final productDescriptionController = TextEditingController();
  final priceBeforeDiscountController = TextEditingController();
  final priceAfterDiscountController = TextEditingController();
  final weightController = TextEditingController();
  final stockController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF517F03), // Green background
      appBar: AppBar(
        title: const Text(
          "Add Product",
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
                    "Product Name:",
                    style: TextStyle(
                      fontSize: 18,
                      color: Color(0xFFFFF4E2), // Beige color for text
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: productNameController,
                    validator: AppValidator.emptyCheck,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: const Color(0xFFFFF4E2), // Beige background
                      border: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(30.0), // Rounded corners
                        borderSide: BorderSide.none, // No border line
                      ),
                      hintText: "Enter product name",
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "Product Description:",
                    style: TextStyle(
                      fontSize: 18,
                      color: Color(0xFFFFF4E2), // Beige color for text
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: productDescriptionController,
                    validator: AppValidator.emptyCheck,
                    maxLines: 3,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: const Color(0xFFFFF4E2), // Beige background
                      border: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(30.0), // Rounded corners
                        borderSide: BorderSide.none, // No border line
                      ),
                      hintText: "Enter product description",
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "Price Before Discount:",
                    style: TextStyle(
                      fontSize: 18,
                      color: Color(0xFFFFF4E2), // Beige color for text
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    controller: priceBeforeDiscountController,
                    validator: (value) {
                      if (AppValidator.numberCheck(value) != null) {
                        return AppValidator.numberCheck(value);
                      }
                      if (double.tryParse(value!)! <= 0) {
                        return "Price before discount must be greater than zero";
                      }
                      return null;
                    },
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      errorMaxLines: 3,
                      filled: true,
                      fillColor: const Color(0xFFFFF4E2), // Beige background
                      border: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(30.0), // Rounded corners
                        borderSide: BorderSide.none, // No border line
                      ),
                      hintText: "Enter price before discount",
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "Price After Discount:",
                    style: TextStyle(
                      fontSize: 18,
                      color: Color(0xFFFFF4E2), // Beige color for text
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    controller: priceAfterDiscountController,
                    validator: (value) {
                      if (AppValidator.numberCheck(value) != null) {
                        return AppValidator.numberCheck(value);
                      }
                      if (double.tryParse(value!)! <= 0) {
                        return "Price after discount must be greater than zero";
                      }
                      if (double.tryParse(value)! >=
                          double.tryParse(
                              priceBeforeDiscountController.text)!) {
                        return "Price after discount must be less than price before discount";
                      }
                      return null;
                    },
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      errorMaxLines: 3,
                      filled: true,
                      fillColor: const Color(0xFFFFF4E2), // Beige background
                      border: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(30.0), // Rounded corners
                        borderSide: BorderSide.none, // No border line
                      ),
                      hintText: "Enter price after discount",
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "Weight: (g)",
                    style: TextStyle(
                      fontSize: 18,
                      color: Color(0xFFFFF4E2), // Beige color for text
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: weightController,
                    validator: AppValidator.numberCheck,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: const Color(0xFFFFF4E2), // Beige background
                      border: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(30.0), // Rounded corners
                        borderSide: BorderSide.none, // No border line
                      ),
                      hintText: "Enter weight in grams",
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "Stock:",
                    style: TextStyle(
                      fontSize: 18,
                      color: Color(0xFFFFF4E2), // Beige color for text
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    controller: stockController,
                    validator: AppValidator.numberCheck,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: const Color(0xFFFFF4E2), // Beige background
                      border: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(30.0), // Rounded corners
                        borderSide: BorderSide.none, // No border line
                      ),
                      hintText: "Enter stock quantity",
                    ),
                  ),
                  const SizedBox(height: 30),
                  Center(
                    child: ElevatedButton(
                      onPressed: () async {
                        if (!formKey.currentState!.validate()) {
                          return;
                        }
                        final val = await FirestoreService.instance.addProduct(
                          productName: productNameController.text,
                          productDescription: productDescriptionController.text,
                          priceBeforeDiscount:
                              double.parse(priceBeforeDiscountController.text),
                          priceAfterDiscount:
                              double.parse(priceAfterDiscountController.text),
                          weight: double.parse(weightController.text),
                          stock: int.parse(stockController.text),
                          image: image,
                        );
                        if (!val.contains('error')) {
                          await sendBulkNotifications(
                            title: 'FoodSaver',
                            subtitle:
                                '${FirestoreService.instance.currentUser?.name} has added a new deal, Check it out!',
                            type: 'NEW_PRODUCT',
                            dynamicId: FirebaseAuth.instance.currentUser!.uid,
                          );
                        }
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(val),
                            backgroundColor: Colors.black,
                          ),
                        );
                        clearFieldsAndImage();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(
                            0xFFAECE77), // Darker Green save button color
                        foregroundColor: Colors.white, // Text color
                        padding: const EdgeInsets.symmetric(
                            horizontal: 50, vertical: 15),
                      ),
                      child: const Text(
                        "Add Product",
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
