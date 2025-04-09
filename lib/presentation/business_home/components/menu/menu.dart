import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:helloworld/model/product_model.dart';
import 'package:helloworld/presentation/business_home/components/menu/add_item.dart';
import 'package:helloworld/presentation/business_home/components/menu/edit_item.dart';
import 'package:helloworld/presentation/checkout/checkout_screen.dart';
import 'package:helloworld/presentation/common/primary_button.dart';
import 'package:helloworld/services/firestore_service.dart';
import 'package:helloworld/utils/colors.dart';
import 'package:helloworld/utils/textstyles.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteColor,
      body: Center(
        child: Column(
          children: [
            const SizedBox(height: 50), // Spacer at the top
            StreamBuilder(
              // Stream to fetch products from Firestore
              stream: FirebaseFirestore.instance
                  .collection('products')
                  .where('isDeleted', isNotEqualTo: true)
                  .where(
                    'businessId',
                    isEqualTo: FirebaseAuth.instance.currentUser!.uid,
                  )
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  // Show loading indicator while fetching data
                  return const CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  // Show error message if there's an error
                  return Text('Error: ${snapshot.error}');
                } else if (!snapshot.hasData || (snapshot.data?.docs.isEmpty ?? true)) {
                  // Show message if no products are available
                  return const Expanded(
                    child: Column(
                      children: [
                        SizedBox(height: 50),
                        Text(
                          'No products available',
                          style: TextStyle(
                            color: Color(
                              0xFFFFF4E2,
                            ),
                            fontSize: 20,
                          ),
                        ),
                      ],
                    ),
                  );
                } else {
                  // Map Firestore data to product models
                  final products = snapshot.data!.docs.map((e) => ProductModel.fromMap(e.data())).toList();

                  return Expanded(
                    // Display products in a list
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      itemCount: products.length,
                      itemBuilder: (context, index) {
                        var product = products[index];
                        return Container(
                          // Product card
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: Colors.grey.shade200,
                          ),
                          padding: const EdgeInsets.all(10),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Product image
                              Container(
                                height: 80,
                                width: 80,
                                clipBehavior: Clip.hardEdge,
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade200,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: product.imageUrl != null
                                    ? Image.network(
                                        product.imageUrl!,
                                        fit: BoxFit.cover,
                                      )
                                    : const Icon(Icons.fastfood),
                              ),
                              const SizedBox(width: 10), // Spacer between image and details
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Product name
                                    Text(product.productName,
                                        style: bodyLargeTextStyle.copyWith(
                                          fontWeight: FontWeight.bold,
                                        )),
                                    // Product description
                                    Text(product.productDescription, style: bodySmallTextStyle),
                                    Row(
                                      children: [
                                        // Discounted price
                                        Text("${product.priceAfterDiscount}",
                                            style: bodyMediumTextStyle.copyWith(
                                              fontWeight: FontWeight.bold,
                                            )),
                                        const SizedBox(width: 4),
                                        // Original price (strikethrough)
                                        Text(
                                          "${product.priceBeforeDiscount}",
                                          style: bodySmallTextStyle.copyWith(
                                            fontWeight: FontWeight.bold,
                                            decoration: TextDecoration.lineThrough,
                                            decorationColor: Colors.red,
                                            decorationThickness: 2,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        // Stock information
                                        Text("Stock: ${product.stock}",
                                            style: bodyMediumTextStyle.copyWith(
                                              fontWeight: FontWeight.bold,
                                            )),
                                      ],
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        // Edit button
                                        SmallIconButton(
                                            icon: Icons.edit,
                                            onPressed: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) => EditItem(
                                                    product: product,
                                                  ),
                                                ),
                                              );
                                            }),
                                        const SizedBox(width: 10), // Spacer between buttons
                                        // Delete button
                                        SmallIconButton(
                                            onPressed: () {
                                              showDialog(
                                                  context: context,
                                                  builder: (context) => AlertDialog(
                                                        title: const Text('Delete Product'),
                                                        content: const Text(
                                                            'Are you sure you want to delete this product?'),
                                                        actions: [
                                                          // Cancel button
                                                          TextButton(
                                                              onPressed: () {
                                                                Navigator.pop(context);
                                                              },
                                                              child: const Text('Cancel')),
                                                          // Confirm delete button
                                                          TextButton(
                                                              onPressed: () async {
                                                                await FirestoreService.instance
                                                                    .deleteProduct(product.id);
                                                                Navigator.pop(context);
                                                              },
                                                              child: const Text('Delete')),
                                                        ],
                                                      ));
                                            },
                                            icon: Icons.delete),
                                      ],
                                    )
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                      separatorBuilder: (BuildContext context, int index) {
                        return const SizedBox(height: 20); // Spacer between product cards
                      },
                    ),
                  );
                }
              },
            ),
            const SizedBox(height: 30), // Spacer before Add Product button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: PrimaryButton(
                // Navigate to AddItem screen
                onTap: () async {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const AddItem()));
                },
                buttonText: 'Add Product',
              ),
            ),
            const SizedBox(height: 100), // Spacer at the bottom
          ],
        ),
      ),
    );
  }
}
