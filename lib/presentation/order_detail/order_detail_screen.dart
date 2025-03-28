import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:helloworld/model/cart_model.dart';
import 'package:helloworld/model/product_model.dart';
import 'package:helloworld/services/auth_service.dart';
import 'package:helloworld/services/firestore_service.dart';
import 'package:helloworld/utils/colors.dart';
import 'package:helloworld/utils/textstyles.dart';

class OrderDetailScreen extends StatefulWidget {
  const OrderDetailScreen({super.key, required this.order, this.isBusinessSide = false});
  final CartModel order;
  final bool isBusinessSide;

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  changeStatus(status) async {
    await FirebaseFirestore.instance.collection('orders').doc(widget.order.id).update({"status": status});
  }

  final List<ProductModel> products = [];
  bool isLoading = true;
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
    getProducts();
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
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 40,
                  width: 40,
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
                      : const Icon(Icons.store_mall_directory_outlined),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // const SizedBox(height: 8),
                      Text(
                        (userInOrder?.name ?? '').toUpperCase(),
                        style: bodyLargeTextStyle,
                      ),
                      Text(
                        ((userInOrder?.phoneNumber == null || (userInOrder?.phoneNumber?.isEmpty ?? true))
                                ? 'No phone number'
                                : userInOrder?.phoneNumber)!
                            .toUpperCase(),
                        style: bodySmallTextStyle,
                      ),
                      const SizedBox(height: 14),
                      Padding(
                        padding: const EdgeInsets.only(top: 14, right: 24),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
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
                                  child: Text(widget.order.orderId ?? '',
                                      style: bodyLargeTextStyle.copyWith(
                                        color: whiteColor,
                                      )),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),
            if (FirestoreService.instance.currentUser?.role == 'business')
              const Align(
                alignment: Alignment.topLeft,
                child: Text(
                  ('Order Status'),
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                  ),
                ),
              ),
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

                    return Row(
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
            //
            if (isLoading) const Center(child: CircularProgressIndicator()),
            if (!isLoading)
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  itemBuilder: (context, index) {
                    final item = products[index];
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "${widget.order.items[index].quantity}x",
                          style: const TextStyle(
                            fontSize: 16,
                            color: primaryColor,
                          ),
                        ),
                        const SizedBox(width: 12),
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
                        Text(
                          "\$${widget.order.items[index].price}",
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
                            "\$${double.parse(widget.order.total!) + double.parse(widget.order.discount ?? '0')}",
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: primaryColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
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
                            "\$${double.parse(widget.order.discount ?? '0')}",
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: primaryColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
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
                            "\$${widget.order.total}",
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
