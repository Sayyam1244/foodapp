import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:helloworld/model/cart_model.dart';
import 'package:helloworld/model/product_model.dart';
import 'package:helloworld/presentation/common/custom_dialogue.dart'; // Import for CustomDialogue
import 'package:helloworld/services/auth_service.dart';
import 'package:helloworld/services/firestore_service.dart';
import 'package:helloworld/utils/colors.dart';
import 'package:helloworld/utils/textstyles.dart';
import 'package:url_launcher/url_launcher.dart';

// Screen to display order details
class OrderDetailScreen extends StatefulWidget {
  const OrderDetailScreen({super.key, required this.order, this.isBusinessSide = false});
  final CartModel order;
  final bool isBusinessSide;

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  // Function to change the order status with confirmation dialog
  changeStatus(String status) async {
    // Show confirmation dialog
    showDialog(
      context: context,
      builder: (context) {
        return CustomDialogue(
          title: "Update Order Status",
          content: "Are you sure you want to update this order status?",
          action: () {
            // Update order status in Firestore
            FirebaseFirestore.instance.collection('orders').doc(widget.order.id).update({"status": status});
            Navigator.pop(context); // Close the dialog
          },
        );
      },
    );
  }

  final List<ProductModel> products = [];
  bool isLoading = true;

  // Fetch products in the order
  getProducts() async {
    for (final item in widget.order.items) {
      final product = await FirestoreService.instance.getSingleProduct(item.productId);
      products.add(product);
    }
    setState(() {
      isLoading = false;
    });
  }

  @override
  void initState() {
    getProducts(); // Load products when the screen initializes
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final userInOrder = widget.order.userModel ?? widget.order.businessUser;

    return Scaffold(
      backgroundColor: whiteColor,
      appBar: AppBar(backgroundColor: whiteColor),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            // User information section
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // User profile image
                Container(
                  height: 50,
                  width: 50,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: userInOrder?.image != null
                      ? Image.network(
                          userInOrder?.image ?? '',
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(
                              Icons.store_mall_directory_outlined,
                              size: 16,
                            );
                          },
                        )
                      : Icon(userInOrder?.role == 'business'
                          ? Icons.store_mall_directory_outlined
                          : Icons.person),
                ),
                const SizedBox(width: 10),
                // User name and phone number
                Column(
                  children: [
                    Text(
                      (userInOrder?.name ?? '').toUpperCase(),
                      style: bodyLargeTextStyle,
                    ),
                    if (userInOrder?.phoneNumber != null || (userInOrder?.phoneNumber?.isNotEmpty ?? false))
                      Text(
                        userInOrder!.phoneNumber!.toUpperCase(),
                        style: bodySmallTextStyle,
                      ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),

            Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.all(10),
              child: InkWell(
                onTap: () {
                  final googleMapUrl =
                      'https://www.google.com/maps/search/?api=1&query=${userInOrder?.latitude},${userInOrder?.longitude}';

                  log(googleMapUrl);
                  launchUrl(Uri.parse(googleMapUrl));
                },
                child: Row(
                  children: [
                    const Icon(Icons.map_outlined),
                    const SizedBox(width: 10),
                    Expanded(child: Text(userInOrder?.location ?? '')),
                    const Icon(Icons.arrow_right),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Column(
              children: [
                const Text(
                  "Order ID",
                  style: titleTextStyle,
                ),
                const SizedBox(height: 5),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: primaryColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child:
                      Text(widget.order.orderId ?? '', style: bodyLargeTextStyle.copyWith(color: whiteColor)),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Order status section for business users
            if (FirestoreService.instance.currentUser?.role == 'business') ...[
              const Center(
                child: Text(('Order Status'), style: titleTextStyle),
              ),
            ],

            if (FirestoreService.instance.currentUser?.role == 'business')
              StreamBuilder(
                  stream: FirebaseFirestore.instance.collection('orders').doc(widget.order.id).snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData == false) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: primaryColor,
                        ),
                      );
                    }
                    final orderStreamdata = CartModel.fromJson(snapshot.data!.data()!);

                    // Status checkboxes
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Checkbox(
                              value: orderStreamdata.status == 'active',
                              onChanged: (v) {
                                changeStatus('active');
                              },
                            ),
                            const Text('Active'),
                          ],
                        ),
                        Row(
                          children: [
                            Checkbox(
                              value: orderStreamdata.status == 'ready',
                              onChanged: (v) {
                                changeStatus('ready');
                              },
                            ),
                            const Text('Ready'),
                          ],
                        ),
                        Row(
                          children: [
                            Checkbox(
                              value: orderStreamdata.status == 'picked_up',
                              onChanged: (v) {
                                changeStatus('picked_up');
                              },
                            ),
                            const Text('Picked Up'),
                          ],
                        ),
                      ],
                    );
                  }),

            Divider(color: Colors.grey.shade200, thickness: 1),

            // Loading indicator while fetching products
            if (isLoading) const Center(child: CircularProgressIndicator()),

            // List of products in the order
            if (!isLoading)
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  itemBuilder: (context, index) {
                    final item = products[index];
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Product quantity
                        Text(
                          "${widget.order.items[index].quantity}x",
                          style: const TextStyle(
                            fontSize: 16,
                            color: primaryColor,
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Product details
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.productName,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w500,
                                  color: primaryColor,
                                ),
                              ),
                              Text(
                                item.productDescription,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: primaryColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Product price
                        Text(
                          "SAR ${widget.order.items[index].price}",
                          style: const TextStyle(
                            fontSize: 18,
                            color: primaryColor,
                          ),
                        ),
                      ],
                    );
                  },
                  separatorBuilder: (context, index) => Divider(
                    height: 30,
                    thickness: 0.5,
                    color: Colors.grey.shade100,
                  ),
                  itemCount: products.length,
                ),
              ),

            // Order summary section
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 30),
                const Text(
                  "Order Summary",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Column(
                    children: [
                      // Order status
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Status",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: primaryColor,
                            ),
                          ),
                          Text(
                            "${widget.order.status?.toUpperCase()}",
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: primaryColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // Subtotal
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Sub Total",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: primaryColor,
                            ),
                          ),
                          Text(
                            "SAR ${double.parse(widget.order.total!) + double.parse(widget.order.discount ?? '0')}",
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: primaryColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // Discount
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Discount",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: primaryColor,
                            ),
                          ),
                          Text(
                            "SAR ${double.parse(widget.order.discount ?? '0')}",
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: primaryColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      // Total
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Total",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: primaryColor,
                            ),
                          ),
                          Text(
                            "SAR ${widget.order.total}",
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                              color: primaryColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
