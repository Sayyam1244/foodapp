import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:helloworld/model/cart_model.dart';
import 'package:helloworld/model/user_model.dart';
import 'package:helloworld/presentation/order_detail/order_detail_screen.dart';
import 'package:helloworld/services/firestore_service.dart';
import 'package:helloworld/utils/colors.dart';
import 'package:helloworld/utils/date_formatter.dart';
import 'package:helloworld/utils/textstyles.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  // Order types and their display names
  List<String> orderType = ["active", "picked_up"];
  Map nameMapped = {'active': "Incoming orders", 'picked_up': "Previous Orders"};
  String selectedType = 'active'; // Default selected order type

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteColor,
      body: StreamBuilder(
          // Stream to fetch user orders
          stream: FirestoreService.instance.streamUserOrders(),
          builder: (context, snapshot) {
            if (snapshot.hasData == false) {
              // Show loading indicator if data is not available
              return const Center(
                child: CircularProgressIndicator(
                  color: Colors.white,
                ),
              );
            }

            // Separate orders into active and picked-up categories
            final orders = snapshot.data as List<CartModel>;
            List<CartModel> activeOrders = [];
            List<CartModel> pickedUpOrders = [];
            for (final order in orders) {
              if (order.status != 'picked_up') {
                activeOrders.add(order);
              } else if (order.status == 'picked_up') {
                pickedUpOrders.add(order);
              }
            }
            log('active orders: ${activeOrders.length}');
            log('picked up orders: ${pickedUpOrders.length}');

            return Column(
              children: [
                SizedBox(height: (MediaQuery.of(context).padding.top + 20)),
                // Order type selection tabs
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        ...orderType
                            .map(
                              (e) => InkWell(
                                onTap: () {
                                  setState(() {
                                    selectedType = e; // Update selected type
                                  });
                                },
                                child: Container(
                                  margin: const EdgeInsets.only(right: 10),
                                  height: 40,
                                  padding: const EdgeInsets.symmetric(horizontal: 24),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(4),
                                    color: cardColor,
                                    border: Border.all(
                                      width: 2,
                                      color: selectedType == e ? Colors.black : Colors.transparent,
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(
                                      '${nameMapped[e]}', // Display name of the order type
                                      style: const TextStyle(
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            )
                            .toList()
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                // List of orders based on selected type
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.only(left: 24, right: 24, bottom: 100),
                    itemBuilder: ((context, index) {
                      final item = selectedType == orderType[0] ? activeOrders[index] : pickedUpOrders[index];
                      return InkWell(
                        onTap: () {
                          // Navigate to order detail screen
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => OrderDetailScreen(
                                order: item,
                              ),
                            ),
                          );
                        },
                        child: Container(
                          height: (item.status == orderType[1] && item.rating == null) ? 130 : 100,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: Colors.grey.shade200,
                          ),
                          padding: const EdgeInsets.all(10),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // Display business image or fallback icon
                              Container(
                                height: 60,
                                width: 60,
                                clipBehavior: Clip.hardEdge,
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade400,
                                  shape: BoxShape.circle,
                                ),
                                child: item.businessUser?.image != null
                                    ? Image.network(
                                        item.businessUser?.image ?? '',
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) {
                                          return const Icon(Icons.fastfood);
                                        },
                                      )
                                    : const Icon(Icons.store_outlined),
                              ),
                              const SizedBox(width: 10),
                              // Display order details
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          item.businessUser?.name ?? "", // Business name
                                          style: bodyLargeTextStyle.copyWith(fontWeight: FontWeight.bold),
                                        ),
                                        Text(
                                          "SAR ${item.total!}", // Order total
                                          style: bodySmallTextStyle.copyWith(fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                    Text(
                                      item.orderId!, // Order ID
                                      style: bodySmallTextStyle,
                                    ),
                                    Text(
                                      item.createdDate.formattedDate, // Order creation date
                                      style: bodySmallTextStyle,
                                    ),
                                    Text(
                                      item.status!.toUpperCase().replaceAll("_", ' '), // Order status
                                      style: bodySmallTextStyle.copyWith(
                                          fontWeight: FontWeight.bold, color: Colors.black),
                                    ),
                                    const Spacer(),
                                    // Show rating option if order is completed but not rated
                                    if (item.status == orderType[1] && item.rating == null)
                                      Align(
                                        alignment: Alignment.centerRight,
                                        child: InkWell(
                                          onTap: () {
                                            showRatingPopup(context, (v) {
                                              submitRating(v, item.id!, item.businessUser!.uid);
                                            });
                                          },
                                          child: Text('Rate your order',
                                              style: bodyMediumTextStyle.copyWith(
                                                fontWeight: FontWeight.bold,
                                                decoration: TextDecoration.underline,
                                                color: greyColor,
                                              )),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                    separatorBuilder: (BuildContext context, int index) {
                      return const SizedBox(height: 10);
                    },
                    itemCount: (selectedType == orderType[0] ? activeOrders : pickedUpOrders).length,
                  ),
                )
              ],
            );
          }),
    );
  }
}

// Submit rating for an order
submitRating(double rating, String orderId, businessId) async {
  // Update order with the new rating
  await FirebaseFirestore.instance.collection('orders').doc(orderId).update({
    'rating': rating,
  });

  // Fetch business user details
  final val = await FirebaseFirestore.instance.collection('users').doc(businessId).get();
  final user = UserModel.fromMap(val.data()!);

  // Update business user's ratings
  await FirebaseFirestore.instance.collection('users').doc(businessId).update({
    'ratings': [...(user.ratings ?? []), rating],
  });
}

// Show rating popup dialog
showRatingPopup(context, Function(double rating) callback) {
  double newRating = 3; // Default rating value
  return showDialog(
    context: context,
    builder: (context) => Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Close button
            Align(
              alignment: Alignment.topRight,
              child: IconButton(
                icon: const Icon(Icons.close),
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                },
              ),
            ),
            // Icon at the top
            CircleAvatar(
              radius: 40,
              backgroundColor: primaryColor.withOpacity(0.1),
              child: const Icon(
                Icons.star,
                color: primaryColor,
                size: 50,
              ),
            ),
            const SizedBox(height: 20),
            // Title
            const Text(
              'Rate your order',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: primaryColor,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            // Description
            const Text(
              'How was your experience?',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            // Rating bar for user input
            RatingBar.builder(
              initialRating: newRating,
              minRating: 1,
              direction: Axis.horizontal,
              allowHalfRating: false,
              itemCount: 5,
              itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
              itemBuilder: (context, _) => const Icon(
                Icons.star,
                color: Colors.amber,
              ),
              onRatingUpdate: (rating) {
                newRating = rating; // Update rating value
              },
            ),
            const SizedBox(height: 20),
            // Submit button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close dialog
                  callback(newRating); // Pass rating to callback
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
                child: const Text(
                  "Submit",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
