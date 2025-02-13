import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:helloworld/model/user_model.dart';
import 'package:helloworld/presentation/menu/menu_screen.dart';
import 'package:helloworld/services/cart_service.dart';
import 'package:helloworld/services/firestore_service.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final pointController = TextEditingController();
  bool isLoading = false;
  double calculateDiscount(int points) {
    int enteredPoints = int.tryParse(pointController.text) ?? 0;
    int maxPoints = points;
    double pointsToDollars = enteredPoints / 1000;

    return pointsToDollars > CartService.instance.totalPrice()
        ? CartService.instance.totalPrice()
        : pointsToDollars > (maxPoints / 1000)
            ? maxPoints / 1000
            : pointsToDollars;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF517F03),
      appBar: AppBar(
        title: const Text(
          "Checkout",
          style: TextStyle(color: Color(0xFFFFF4E2)),
        ),
        backgroundColor: const Color(0xFF517F03),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(FirestoreService.instance.currentUser?.uid)
                  .snapshots(),
              builder: (ctx, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
                final user = UserModel.fromMap(snapshot.data!.data()!);
                final pointsConvertedToDollars = user.points! / 1000;
                final discount = pointsConvertedToDollars >=
                        CartService.instance.totalPrice()
                    ? CartService.instance.totalPrice()
                    : pointsConvertedToDollars;

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16),
                      Text(
                        'Redeem your points',
                        style:
                            Theme.of(context).textTheme.titleMedium!.copyWith(
                                  color: Colors.white,
                                ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Available Points to redeem: ${user.points ?? 0}',
                        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                              color: Colors.white,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: pointController,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              decoration: InputDecoration(
                                filled: true,
                                fillColor:
                                    const Color(0xFFFFF4E2), // Beige background
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(
                                      8.0), // Rounded corners
                                  borderSide: BorderSide.none, // No border line
                                ),
                                suffixIconConstraints:
                                    const BoxConstraints(maxWidth: 60),
                                suffixIcon: Padding(
                                  padding: const EdgeInsets.only(right: 8),
                                  child: SmallIconButton(
                                    icon: Icons.check,
                                    onPressed: () {
                                      if (int.tryParse(pointController.text) ==
                                          null) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                                'Please enter a valid number'),
                                          ),
                                        );
                                        return;
                                      }
                                      if (int.tryParse(pointController.text)! >
                                          user.points!) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                                'You do not have enough points'),
                                          ),
                                        );
                                        return;
                                      }
                                      if (int.tryParse(pointController.text)! <
                                          1000) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                                'Minimum points to redeem is 1000'),
                                          ),
                                        );
                                        return;
                                      }
                                      setState(() {});
                                    },
                                  ),
                                ),
                                hintText: "Enter points to redeem",
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Divider(),
                      const SizedBox(height: 16),
                      Text(
                        'Order Summary',
                        style:
                            Theme.of(context).textTheme.titleMedium!.copyWith(
                                  color: Colors.white,
                                ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.white24,
                          ),
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    'Order Amount:',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium!
                                        .copyWith(
                                          color: Colors.white,
                                        ),
                                  ),
                                ),
                                Text(
                                  '\$${CartService.instance.totalPrice()}',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium!
                                      .copyWith(
                                        color: Colors.white,
                                      ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            const Divider(
                              color: Colors.white24,
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    'Redeemed Points:',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium!
                                        .copyWith(
                                          color: Colors.white,
                                        ),
                                  ),
                                ),
                                Text(
                                  '\$${calculateDiscount(user.points!)}',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium!
                                      .copyWith(
                                        color: Colors.white,
                                      ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            const Divider(),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    'Total Amount:',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium!
                                        .copyWith(
                                          color: Colors.white,
                                        ),
                                  ),
                                ),
                                Text(
                                  '\$${CartService.instance.totalPrice() - calculateDiscount(user.points!)}',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium!
                                      .copyWith(
                                        color: Colors.white,
                                      ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      Container(
                        // height: 40,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: const Color(0xFFAECE77),
                        ),
                        child: InkWell(
                            onTap: () async {
                              setState(() {
                                isLoading = true;
                              });
                              //adjust points

                              await FirestoreService.instance
                                  .placeOrder(
                                CartService.instance.cartModel,
                                int.parse(pointController.text.isEmpty
                                    ? '0'
                                    : pointController.text),
                                user.points ?? 0,
                              )
                                  .then((value) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(value == true
                                        ? 'Order Placed Successfully'
                                        : value),
                                  ),
                                );
                                CartService.instance.clearCart();
                                pointController.clear();
                                setState(() {
                                  isLoading = false;
                                });
                              });
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              child: Center(
                                child: Text(
                                  'Place Order',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleSmall!
                                      .copyWith(
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black87,
                                      ),
                                ),
                              ),
                            )),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                );
              }),
    );
  }
}
