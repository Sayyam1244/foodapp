import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:helloworld/presentation/checkout/checkout_screen.dart';
import 'package:helloworld/presentation/menu/menu_screen.dart';
import 'package:helloworld/services/cart_service.dart';
import 'package:helloworld/services/firestore_service.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  bool isLoading = false;
  @override
  Widget build(BuildContext context) {
    double total = 0;
    for (var item in CartService.instance.cartModel.items) {
      total += (item.price * item.quantity);
    }
    return Scaffold(
      backgroundColor: const Color(0xFF517F03),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        backgroundColor: const Color(0xFF517F03),
        title: const Text(
          'Cart',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: CartService.instance.cartModel.items.length,
                    itemBuilder: (context, index) {
                      final cartItem =
                          CartService.instance.cartModel.items[index];
                      return Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: const Color(0xFFFFF4E2),
                        ),
                        padding: const EdgeInsets.all(10),
                        margin: const EdgeInsets.all(10),
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
                              child: cartItem.product?.imageUrl != null
                                  ? Image.network(
                                      cartItem.product!.imageUrl!,
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
                                    cartItem.product?.productName ?? '',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xff2D531A),
                                    ),
                                  ),
                                  Text(
                                    "Description: ${cartItem.product?.productDescription}",
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Row(
                                    children: [
                                      const Text(
                                        "Price: ",
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        "${cartItem.price}",
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      SmallIconButton(
                                        onPressed: () async {
                                          CartService.instance
                                              .decrementItemInCart(
                                            productId: cartItem.productId,
                                          );
                                          setState(() {});
                                        },
                                        icon: cartItem.quantity == 1
                                            ? Icons.delete
                                            : Icons.remove,
                                      ),
                                      const SizedBox(width: 10),
                                      Text(
                                        cartItem.quantity.toString(),
                                        style: const TextStyle(
                                          fontSize: 20,
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      SmallIconButton(
                                        onPressed: () async {
                                          final val = CartService.instance
                                              .incrementItemInCart(
                                            productId: cartItem.productId,
                                          );
                                          if (val != null) {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                content: Text(val),
                                              ),
                                            );
                                          }
                                          setState(() {});
                                        },
                                        icon: Icons.add,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 10),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  // height: 40,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: const Color(0xFFAECE77),
                  ),
                  child: InkWell(
                      onTap: () async {
                        // setState(() {
                        //   isLoading = true;
                        // });
                        // final val = await FirestoreService.instance.placeOrder(
                        //   CartService.instance.cartModel,
                        // );
                        // ScaffoldMessenger.of(context).showSnackBar(
                        //   SnackBar(
                        //     content: Text(val == true
                        //         ? 'Order Placed Successfully'
                        //         : val),
                        //   ),
                        // );
                        // setState(() {
                        //   isLoading = false;
                        // });
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const CheckoutScreen()));
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 14),
                        child: Row(
                          children: [
                            Expanded(
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
                            Text(
                              '\$${CartService.instance.totalPrice()}',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium!
                                  .copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                  ),
                            ),
                          ],
                        ),
                      )),
                ),
                const SizedBox(height: 24),
              ],
            ),
    );
  }
}
