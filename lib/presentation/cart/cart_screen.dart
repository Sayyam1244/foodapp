import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:helloworld/services/cart_service.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
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
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: CartService.instance.cartModel.items.length,
              itemBuilder: (context, index) {
                final cartItem = CartService.instance.cartModel.items[index];
                return InkWell(
                  onTap: () {
                    //
                  },
                  child: Container(
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
                                  ElevatedButton(
                                    onPressed: () {
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
                                    child: const Text(
                                      '+',
                                      style: TextStyle(fontSize: 20),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    cartItem.quantity.toString(),
                                    style: const TextStyle(
                                      fontSize: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  ElevatedButton(
                                    onPressed: () {
                                      CartService.instance.decrementItemInCart(
                                        productId: cartItem.productId,
                                      );
                                      setState(() {});
                                    },
                                    child: const Text(
                                      '-',
                                      style: TextStyle(fontSize: 20),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                  ),
                ),
                Text(
                  '\$${total.toStringAsFixed(2)}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {},
            child: const Text('Place Order'),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
