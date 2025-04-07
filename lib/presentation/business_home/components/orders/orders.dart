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
  List<String> orderType = ["Incoming orders", "Incoming Completed"];

  String selectedType = 'Incoming orders';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteColor,
      body: StreamBuilder(
          stream: FirestoreService.instance.streamUserOrdersForBusiness(),
          builder: (context, snapshot) {
            if (snapshot.hasData == false) {
              return const Center(
                child: CircularProgressIndicator(
                  color: Colors.white,
                ),
              );
            }
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
                SizedBox(height: (MediaQuery.of(context).padding.top + 20)),
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
                                    selectedType = e;
                                  });
                                },
                                child: Container(
                                  margin: const EdgeInsets.only(right: 10),
                                  height: 40,
                                  padding: const EdgeInsets.symmetric(horizontal: 24),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(4),
                                    color: primaryColor,
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
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    itemBuilder: ((context, index) {
                      final item =
                          selectedType == orderType[0] ? pendingOrders[index] : completedOrders[index];
                      return InkWell(
                        onTap: () {
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
                                    Text(item.createdDate.formattedDate, style: bodyMediumTextStyle),
                                    const SizedBox(height: 4),
                                    Text(
                                      item.status!.toUpperCase().replaceAll("_", ' '),
                                      style: bodyMediumTextStyle.copyWith(
                                        color: Colors.black,
                                      ),
                                    ),
                                    const Spacer(),
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
                    separatorBuilder: (BuildContext context, int index) {
                      return const SizedBox(height: 10);
                    },
                    itemCount: (selectedType == orderType[0] ? pendingOrders : completedOrders).length,
                  ),
                )
              ],
            );
          }),
    );
  }
}
