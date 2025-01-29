import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:helloworld/model/product_model.dart';
import 'package:helloworld/presentation/business_home/components/menu/add_item.dart';
import 'package:helloworld/presentation/business_home/components/menu/edit_item.dart';
import 'package:helloworld/services/firestore_service.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF517F03),
      body: Center(
        child: Column(
          children: [
            const SizedBox(height: 50),
            StreamBuilder(
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
                  return const CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else if (!snapshot.hasData ||
                    (snapshot.data?.docs.isEmpty ?? true)) {
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
                  final products = snapshot.data!.docs
                      .map((e) => ProductModel.fromMap(e.data()))
                      .toList();

                  return Expanded(
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      itemCount: products.length,
                      itemBuilder: (context, index) {
                        var product = products[index];
                        return Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: const Color(0xFFFFF4E2),
                          ),
                          padding: const EdgeInsets.all(10),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                height: 105,
                                width: 105,
                                clipBehavior: Clip.hardEdge,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFAECE77),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: product.imageUrl != null
                                    ? Image.network(
                                        product.imageUrl!,
                                        fit: BoxFit.cover,
                                      )
                                    : const Icon(Icons.fastfood),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      product.productName,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xff2D531A),
                                      ),
                                    ),
                                    Text(
                                      "Description: ${product.productDescription}",
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Row(
                                      children: [
                                        const Text(
                                          "Price Before discount: ",
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          "${product.priceBeforeDiscount}",
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                            decoration:
                                                TextDecoration.lineThrough,
                                            decorationColor: Colors.red,
                                            decorationThickness: 2,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Text(
                                      "Price after discount: ${product.priceAfterDiscount}",
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          "Stock: ${product.stock}",
                                          style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        InkWell(
                                            onTap: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      EditItem(
                                                    product: product,
                                                  ),
                                                ),
                                              );
                                            },
                                            child: const Icon(Icons.edit)),
                                        const SizedBox(width: 10),
                                        InkWell(
                                            onTap: () {
                                              showDialog(
                                                  context: context,
                                                  builder:
                                                      (context) => AlertDialog(
                                                            title: const Text(
                                                                'Delete Product'),
                                                            content: const Text(
                                                                'Are you sure you want to delete this product?'),
                                                            actions: [
                                                              TextButton(
                                                                  onPressed:
                                                                      () {
                                                                    Navigator.pop(
                                                                        context);
                                                                  },
                                                                  child: const Text(
                                                                      'Cancel')),
                                                              TextButton(
                                                                  onPressed:
                                                                      () async {
                                                                    await FirestoreService
                                                                        .instance
                                                                        .deleteProduct(
                                                                            product.id);
                                                                    Navigator.pop(
                                                                        context);
                                                                  },
                                                                  child: const Text(
                                                                      'Delete')),
                                                            ],
                                                          ));
                                            },
                                            child: const Icon(Icons.delete)),
                                      ],
                                    )
                                  ],
                                ),
                              ),
                              const SizedBox(width: 10),
                            ],
                          ),
                        );
                      },
                      separatorBuilder: (BuildContext context, int index) {
                        return const SizedBox(height: 20);
                      },
                    ),
                  );
                }
              },
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () async {
                // navigate to AddItem
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => const AddItem()));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    const Color(0xFFAECE77), // Darker Green login button color
                foregroundColor: Colors.white, // Text color
                padding:
                    const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
              ),
              child: const Text(
                "Add Product",
                style: TextStyle(fontSize: 18),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
