import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:helloworld/main.dart';
import 'package:helloworld/model/user_model.dart';
import 'package:helloworld/presentation/menu/menu_screen.dart';
import 'package:helloworld/services/cart_service.dart';
import 'package:helloworld/services/firestore_service.dart';
import 'package:helloworld/services/stripe_service.dart';
import 'package:helloworld/utils/colors.dart';

// Checkout screen widget
class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final pointController = TextEditingController(); // Controller for points input
  bool isLoading = false; // Loading state

  // Calculate discount based on points
  double calculateDiscount(num points) {
    int enteredPoints = int.tryParse(pointController.text) ?? 0;
    num maxPoints = points;
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('Checkout', style: TextStyle(color: Colors.black)),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator()) // Show loader if loading
          : StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(FirestoreService.instance.currentUser?.uid)
                  .snapshots(),
              builder: (ctx, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator()); // Show loader if no data
                }
                final user = UserModel.fromMap({
                  ...snapshot.data!.data()!,
                  "uid": FirestoreService.instance.currentUser?.uid
                }); // Parse user data

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16),
                      const Text(
                        'Redeem your points',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Display available points
                      Text(
                        'Available Points to redeem: ${user.points ?? 0}',
                        style: const TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: pointController, // Input for redeeming points
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.grey.shade200,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                  borderSide: BorderSide.none,
                                ),
                                suffixIcon: Padding(
                                  padding: const EdgeInsets.only(right: 8, top: 4, bottom: 4),
                                  child: SmallIconButton(
                                    icon: Icons.check,
                                    onPressed: () {
                                      // Validate points input
                                      if (int.tryParse(pointController.text) == null) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(
                                            behavior: SnackBarBehavior.floating,
                                            margin: EdgeInsets.only(bottom: 10, left: 10, right: 10),
                                            content: Text('Please enter a valid number'),
                                          ),
                                        );
                                        return;
                                      }
                                      if (int.tryParse(pointController.text)! > user.points!) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(
                                            behavior: SnackBarBehavior.floating,
                                            margin: EdgeInsets.only(bottom: 10, left: 10, right: 10),
                                            content: Text('You do not have enough points'),
                                          ),
                                        );
                                        return;
                                      }
                                      if (int.tryParse(pointController.text)! < 1000) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(
                                            behavior: SnackBarBehavior.floating,
                                            margin: EdgeInsets.only(bottom: 10, left: 10, right: 10),
                                            content: Text('Minimum points to redeem is 1000'),
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
                      const Text(
                        'Order Summary',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Order summary section
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.grey.shade200,
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                const Expanded(
                                  child: Text(
                                    'Order Amount:',
                                    style: TextStyle(fontSize: 14),
                                  ),
                                ),
                                Text(
                                  'SAR ${CartService.instance.totalPrice()}',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            const Divider(),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                const Expanded(
                                  child: Text(
                                    'Redeemed Points:',
                                    style: TextStyle(fontSize: 14),
                                  ),
                                ),
                                Text(
                                  'SAR ${calculateDiscount(user.points ?? 0)}',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            const Divider(),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                const Expanded(
                                  child: Text(
                                    'Total Amount:',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Text(
                                  'SAR ${(CartService.instance.totalPrice() - calculateDiscount(user.points ?? 0)).toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      // Place order button
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: cardColor,
                        ),
                        child: InkWell(
                          onTap: () async {
                            // Validate cart and place order
                            if (CartService.instance.cartModel.items.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Cart is empty'),
                                ),
                              );
                              return;
                            }
                            setState(() {
                              isLoading = true;
                            });
                            double totalPrice = 0;
                            for (var element in CartService.instance.cartModel.items) {
                              totalPrice += element.price * element.quantity;
                            }
                            await StripeService.instance.payment(totalPrice.toString(), onSuccess: (v) async {
                              await FirestoreService.instance
                                  .placeOrder(
                                CartService.instance.cartModel,
                                int.parse(pointController.text.isEmpty ? '0' : pointController.text),
                                user.points ?? 0,
                                user.gmSaved ?? 0,
                              )
                                  .then((value) async {
                                Navigator.pop(context);
                                Navigator.pop(context);
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    behavior: SnackBarBehavior.floating,
                                    margin: const EdgeInsets.only(bottom: 10, left: 10, right: 10),
                                    content: Text(value == true ? 'Order Placed Successfully' : value),
                                  ),
                                );
                                CartService.instance.clearCart();
                                pointController.clear();
                              });
                            }, onCancelled: () {});
                            setState(() {
                              isLoading = false;
                            });
                          },
                          child: const Padding(
                            padding: EdgeInsets.symmetric(vertical: 14),
                            child: Center(
                              child: Text(
                                'Confirm',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                );
              }),
    );
  }
}

// // Small button with an icon
// class SmallIconButton extends StatelessWidget {
//   const SmallIconButton({super.key, required this.icon, required this.onPressed});
//   final IconData icon;
//   final Function() onPressed;

//   @override
//   Widget build(BuildContext context) {
//     return InkWell(
//       onTap: onPressed,
//       child: Container(
//         padding: const EdgeInsets.all(6),
//         decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(8),
//           color: Colors.grey.shade300,
//         ),
//         child: Icon(
//           icon,
//           color: Colors.black87,
//           size: 18,
//         ),
//       ),
//     );
//   }
// }
