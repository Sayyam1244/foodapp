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
  File? image;
  final productNameController = TextEditingController();
  final productDescriptionController = TextEditingController();
  final priceBeforeDiscountController = TextEditingController();
  final priceAfterDiscountController = TextEditingController();
  final weightController = TextEditingController();
  final stockController = TextEditingController();
  String? categoryValue;
  final formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
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
                    child: Text(
                      'Add Product',
                      style: headlineTextStyle.copyWith(
                        color: primaryColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: InkWell(
                      onTap: () async {
                        final pickedFile = await FilePickerService.pickFile();
                        setState(() {
                          image = pickedFile;
                        });
                      },
                      child: CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.grey[200],
                        backgroundImage: image != null ? FileImage(image!) : null,
                        child: image == null
                            ? Icon(
                                Icons.camera_alt,
                                color: Colors.grey[600],
                              )
                            : null,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  CustomTextField(
                    labelText: 'Product Name:',
                    controller: productNameController,
                    hintText: 'Enter product name',
                    validator: AppValidator.emptyCheck,
                  ),
                  const SizedBox(height: 20),
                  CustomTextField(
                    labelText: 'Product Description:',
                    controller: productDescriptionController,
                    hintText: 'Enter product description',
                    validator: AppValidator.emptyCheck,
                    // maxLines: 3,
                  ),
                  const SizedBox(height: 20),
                  CustomTextField(
                    labelText: 'Price Before Discount:',
                    controller: priceBeforeDiscountController,
                    hintText: 'Enter price before discount',
                    validator: (value) {
                      if (AppValidator.numberCheck(value) != null) {
                        return AppValidator.numberCheck(value);
                      }
                      if (double.tryParse(value!)! <= 0) {
                        return "Price before discount must be greater than zero";
                      }
                      return null;
                    },
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 20),
                  CustomTextField(
                    labelText: 'Price After Discount:',
                    controller: priceAfterDiscountController,
                    hintText: 'Enter price after discount',
                    validator: (value) {
                      if (AppValidator.numberCheck(value) != null) {
                        return AppValidator.numberCheck(value);
                      }
                      if (double.tryParse(value!)! <= 0) {
                        return "Price after discount must be greater than zero";
                      }
                      if (double.tryParse(value)! >= double.tryParse(priceBeforeDiscountController.text)!) {
                        return "Price after discount must be less than price before discount";
                      }
                      return null;
                    },
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 20),
                  CustomTextField(
                    labelText: 'Weight (g):',
                    controller: weightController,
                    hintText: 'Enter weight in grams',
                    validator: AppValidator.numberCheck,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 20),
                  CustomTextField(
                    labelText: 'Stock:',
                    controller: stockController,
                    hintText: 'Enter stock quantity',
                    validator: AppValidator.numberCheck,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 30),
                  Center(
                    child: PrimaryButton(
                      buttonText: 'Add Product',
                      onTap: () async {
                        if (!formKey.currentState!.validate()) {
                          return;
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
                          clearFieldsAndImage();
                        } else {
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
