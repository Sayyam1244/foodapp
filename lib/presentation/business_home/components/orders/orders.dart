import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:helloworld/model/cart_model.dart';
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
  // Order types for filtering
  List<String> orderType = ["Incoming orders", "Incoming Completed"];

  // Selected order type
  String selectedType = 'Incoming orders';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteColor,
      body: StreamBuilder(
          // Stream to fetch user orders for the business
          stream: FirestoreService.instance.streamUserOrdersForBusiness(),
          builder: (context, snapshot) {
            if (snapshot.hasData == false) {
              // Show loading indicator if data is not available
              return const Center(
                child: CircularProgressIndicator(
                  color: Colors.white,
                ),
              );
            }

            // Separate orders into pending and completed
            final orders = snapshot.data as List<CartModel>;
            List<CartModel> pendingOrders = [];
            List<CartModel> completedOrders = [];

            for (final order in orders) {
              if (order.status == 'picked_up') {
                completedOrders.add(order);
              } else {
                pendingOrders.add(order);
              }
            }

            return Column(
              children: [
                // Add padding for the top of the screen
                SizedBox(height: (MediaQuery.of(context).padding.top + 20)),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        // Render order type filters
                        ...orderType
                            .map(
                              (e) => InkWell(
                                onTap: () {
                                  // Update selected order type
                                  setState(() {
                                    selectedType = e;
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
                                      e,
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
                // Display the list of orders
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    itemBuilder: ((context, index) {
                      // Determine which list to display based on selected type
                      final item =
                          selectedType == orderType[0] ? pendingOrders[index] : completedOrders[index];
                      return InkWell(
                        onTap: () {
                          // Navigate to order detail screen
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => OrderDetailScreen(order: item, isBusinessSide: true),
                            ),
                          );
                        },
                        child: Container(
                          height: item.rating != null ? 120 : 100,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12), color: Colors.grey.shade200),
                          padding: const EdgeInsets.all(14),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Display order ID and total price
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text("Order ID: ${item.orderId ?? ''}", style: titleTextStyle),
                                        Text(
                                          "\$${item.total!}",
                                          style: titleTextStyle.copyWith(fontSize: 14),
                                        ),
                                      ],
                                    ),
                                    // Display order creation date
                                    Text(item.createdDate.formattedDate, style: bodyMediumTextStyle),
                                    const SizedBox(height: 4),
                                    // Display order status
                                    Text(
                                      item.status!.toUpperCase().replaceAll("_", ' '),
                                      style: bodySmallTextStyle.copyWith(
                                        color: Colors.black,
                                      ),
                                    ),
                                    const Spacer(),
                                    // Display rating if available
                                    if (item.rating != null)
                                      Row(
                                        children: [
                                          RatingBar.builder(
                                            initialRating: item.rating!.toDouble(),
                                            minRating: 1,
                                            direction: Axis.horizontal,
                                            allowHalfRating: true,
                                            itemCount: 5,
                                            itemSize: 14,
                                            ignoreGestures: true,
                                            itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
                                            itemBuilder: (context, _) => const Icon(
                                              Icons.star,
                                              color: Colors.amber,
                                            ),
                                            onRatingUpdate: (rating) {
                                              log(rating.toString());
                                            },
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            (item.rating ?? 0).toString(),
                                            style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black45,
                                            ),
                                          ),
                                        ],
                                      )
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                    // Add spacing between list items
                    separatorBuilder: (BuildContext context, int index) {
                      return const SizedBox(height: 10);
                    },
                    // Determine the number of items to display
                    itemCount: (selectedType == orderType[0] ? pendingOrders : completedOrders).length,
                  ),
                )
              ],
            );
          }),
    );
  }
}
