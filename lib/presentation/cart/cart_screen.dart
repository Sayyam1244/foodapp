import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:helloworld/presentation/checkout/checkout_screen.dart';
import 'package:helloworld/services/cart_service.dart';
import 'package:helloworld/utils/textstyles.dart';

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
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('Cart', style: titleTextStyle),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: CartService.instance.cartModel.items.length,
                    itemBuilder: (context, index) {
                      final cartItem = CartService.instance.cartModel.items[index];
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.grey.shade200,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                height: 80,
                                width: 80,
                                clipBehavior: Clip.hardEdge,
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade300,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: cartItem.product?.imageUrl != null
                                    ? Image.network(
                                        cartItem.product!.imageUrl!,
                                        fit: BoxFit.cover,
                                      )
                                    : const Icon(Icons.fastfood),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(cartItem.product?.productName ?? '',
                                        style: bodyLargeTextStyle.copyWith(
                                          fontWeight: FontWeight.bold,
                                        )),
                                    Text(cartItem.product?.productDescription ?? '',
                                        style: bodySmallTextStyle),
                                    Text(
                                      "\$${cartItem.price.toStringAsFixed(2)}",
                                      style: bodyMediumTextStyle.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        const SizedBox(),
                                        Row(
                                          children: [
                                            SmallIconButton(
                                              onPressed: () async {
                                                CartService.instance.decrementItemInCart(
                                                  productId: cartItem.productId,
                                                );
                                                setState(() {});
                                              },
                                              icon: cartItem.quantity == 1 ? Icons.delete : Icons.remove,
                                            ),
                                            const SizedBox(width: 10),
                                            Text(
                                              cartItem.quantity.toString(),
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const SizedBox(width: 10),
                                            SmallIconButton(
                                              onPressed: () async {
                                                final val = CartService.instance.incrementItemInCart(
                                                  productId: cartItem.productId,
                                                );
                                                if (val != null) {
                                                  ScaffoldMessenger.of(context).showSnackBar(
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
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: const Color(0xFF517F03),
                  ),
                  child: InkWell(
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const CheckoutScreen(),
                        ),
                      );
                      setState(() {});
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Place Order',
                              style: Theme.of(context).textTheme.titleSmall!.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                            ),
                          ),
                          Text(
                            '\$${CartService.instance.totalPrice().toStringAsFixed(2)}',
                            style: Theme.of(context).textTheme.titleMedium!.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
    );
  }
}

class SmallIconButton extends StatelessWidget {
  const SmallIconButton({super.key, required this.icon, required this.onPressed});
  final IconData icon;
  final Function() onPressed;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: Colors.grey.shade300,
        ),
        child: Icon(
          icon,
          color: Colors.black87,
          size: 18,
        ),
      ),
    );
  }
}
