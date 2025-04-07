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
  File? image;
  final productNameController = TextEditingController();
  final productDescriptionController = TextEditingController();
  final priceBeforeDiscountController = TextEditingController();
  final priceAfterDiscountController = TextEditingController();
  final weightController = TextEditingController();
  final stockController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _loadProductData();
  }

  void _loadProductData() {
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
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                        backgroundImage: image != null
                            ? FileImage(image!)
                            : (widget.product.imageUrl != null
                                ? NetworkImage(widget.product.imageUrl!)
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
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
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
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  ),
                  const SizedBox(height: 20),
                  CustomTextField(
                    labelText: 'Weight (g):',
                    controller: weightController,
                    hintText: 'Enter weight in grams',
                    validator: AppValidator.numberCheck,
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 20),
                  CustomTextField(
                    labelText: 'Stock:',
                    controller: stockController,
                    hintText: 'Enter stock quantity',
                    validator: AppValidator.numberCheck,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  ),
                  const SizedBox(height: 30),
                  Center(
                    child: PrimaryButton(
                      buttonText: 'Save Changes',
                      onTap: () async {
                        if (!formKey.currentState!.validate()) {
                          return;
                        }
                        final val = await FirestoreService.instance.updateProduct(
                          id: widget.product.id,
                          productName: productNameController.text,
                          productDescription: productDescriptionController.text,
                          priceBeforeDiscount: double.parse(priceBeforeDiscountController.text),
                          priceAfterDiscount: double.parse(priceAfterDiscountController.text),
                          weight: double.parse(weightController.text),
                          stock: int.parse(stockController.text),
                          image: image,
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(val),
                            backgroundColor: Colors.black,
                          ),
                        );
                        Navigator.pop(context);
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
