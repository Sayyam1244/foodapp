import 'package:flutter/material.dart';
import 'package:helloworld/model/cart_model.dart';
import 'package:helloworld/presentation/order_detail/order_detail_screen.dart';
import 'package:helloworld/services/firestore_service.dart';
import 'package:helloworld/utils/date_formatter.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  List<String> orderType = ["active", "ready", "picked_up"];

  String selectedType = 'active';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF517F03),
      body: StreamBuilder(
          stream: FirestoreService.instance.streamUserOrders(),
          builder: (context, snapshot) {
            if (snapshot.hasData == false) {
              return const Center(
                child: CircularProgressIndicator(
                  color: Colors.white,
                ),
              );
            }
            final orders = snapshot.data as List<CartModel>;
            List<CartModel> activeOrders = [];
            List<CartModel> readyOrders = [];
            List<CartModel> pickedUpOrders = [];

            for (final order in orders) {
              if (order.status == orderType[0]) {
                activeOrders.add(order);
              } else if (order.status == orderType[1]) {
                readyOrders.add(order);
              } else if (order.status == orderType[2]) {
                pickedUpOrders.add(order);
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
                                  height: 50,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 24),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    color: const Color.fromARGB(
                                        255, 143, 168, 100),
                                    border: Border.all(
                                      color: selectedType == e
                                          ? Colors.black
                                          : Colors.transparent,
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(
                                      '$e ${(e == orderType[0] ? activeOrders.length : e == orderType[1] ? readyOrders.length : pickedUpOrders.length)}',
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
                      final item = selectedType == orderType[0]
                          ? activeOrders[index]
                          : selectedType == orderType[1]
                              ? readyOrders[index]
                              : pickedUpOrders[index];
                      return InkWell(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => OrderDetailScreen(
                                order: item,
                              ),
                            ),
                          );
                        },
                        child: Container(
                          height: 120,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: const Color(0xFFFFF4E2),
                          ),
                          padding: const EdgeInsets.all(10),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                height: 50,
                                width: 50,
                                clipBehavior: Clip.hardEdge,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFAECE77),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: item.businessUser?.image != null
                                    ? Image.network(
                                        item.businessUser?.image ?? '',
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                          return const Icon(Icons.fastfood);
                                        },
                                      )
                                    : const Icon(Icons.fastfood),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          item.businessUser?.name ?? "",
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xff2D531A),
                                          ),
                                        ),
                                        Text(
                                          "\$${item.total!}",
                                          style: const TextStyle(
                                            fontSize: 22,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Text(
                                      item.orderId!,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Color(0xff2D531A),
                                      ),
                                    ),
                                    Text(
                                      item.createdDate.formattedDate,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Color(0xff2D531A),
                                      ),
                                    ),
                                    Text(
                                      item.status!,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black45,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 10),
                              const Center(
                                child: Icon(
                                  Icons.arrow_forward_ios_rounded,
                                  color: Color(0xff2D531A),
                                  size: 16,
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
                    itemCount: (selectedType == orderType[0]
                            ? activeOrders
                            : selectedType == orderType[1]
                                ? readyOrders
                                : pickedUpOrders)
                        .length,
                  ),
                )
              ],
            );
          }),
    );
  }
}
