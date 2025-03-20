import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:helloworld/model/product_model.dart';
import 'package:helloworld/model/user_model.dart';
import 'package:helloworld/presentation/cart/cart_screen.dart';
import 'package:helloworld/services/cart_service.dart';
import 'package:helloworld/services/firestore_service.dart';

class BusinessMenuScreen extends StatefulWidget {
  const BusinessMenuScreen({super.key, required this.userModel});
  final UserModel userModel;

  @override
  State<BusinessMenuScreen> createState() => _BusinessMenuScreenState();
}

class _BusinessMenuScreenState extends State<BusinessMenuScreen> {
  List<ProductModel> products = [];
  bool isLoading = true;
  final searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }

  Future<void> _fetchProducts() async {
    final val = await FirestoreService.instance.getProducts(widget.userModel.uid);
    if (val is String) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(val),
        ),
      );
      setState(() {
        isLoading = false;
      });
    } else {
      products = val;
      setState(() {
        isLoading = false;
      });
    }

    // setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final ratings = widget.userModel.ratings ?? [];
    final totalRatings = ratings.fold(0, (previousValue, element) => previousValue.toInt() + element.toInt());
    final averageRating = totalRatings / ratings.length;
    return Scaffold(
      backgroundColor: const Color(0xFF517F03),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Colors.white,
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  const SizedBox(height: 24),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const BackButton(
                        color: Colors.white,
                      ),
                      Container(
                        width: 80,
                        height: 80,
                        clipBehavior: Clip.hardEdge,
                        decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.white),
                        child: widget.userModel.image != null
                            ? Image.network(
                                widget.userModel.image!,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) => const Icon(Icons.business),
                              )
                            : const Icon(Icons.business),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.userModel.name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                              ),
                            ),
                            if (ratings.isNotEmpty)
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.star, color: Colors.yellow),
                                  const SizedBox(width: 5),
                                  Text(
                                    "${averageRating.toStringAsFixed(1)} (${ratings.length})",
                                    style: const TextStyle(
                                      color: Colors.green,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListView.separated(
                      itemCount: products.length,
                      itemBuilder: (context, index) {
                        final product = products[index];
                        bool ifProductAlreadyInCart = CartService.instance.cartModel.items
                            .any((element) => element.product!.id == product.id);
                        if (product.stock == 0) {
                          return const SizedBox.shrink();
                        }
                        return Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: const Color(0xFFFFF4E2),
                          ),
                          padding: const EdgeInsets.all(10),
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
                                child: product.imageUrl != null
                                    ? Image.network(
                                        product.imageUrl!,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) => const Icon(Icons.error),
                                      )
                                    : const Icon(Icons.fastfood),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      product.productName,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xff2D531A),
                                      ),
                                    ),
                                    Text(
                                      "Description: ${product.productDescription}",
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Row(
                                      children: [
                                        const Text(
                                          "Price Before discount: ",
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          "${product.priceBeforeDiscount}",
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                            decoration: TextDecoration.lineThrough,
                                            decorationColor: Colors.red,
                                            decorationThickness: 2,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Text(
                                      "Price after discount: ${product.priceAfterDiscount}",
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          "Stock: ${product.stock}",
                                          style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        if (ifProductAlreadyInCart)
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.end,
                                            children: [
                                              SmallIconButton(
                                                onPressed: () async {
                                                  CartService.instance.decrementItemInCart(
                                                    productId: product.id,
                                                  );
                                                  setState(() {});
                                                },
                                                icon: CartService.instance.cartModel.items
                                                            .firstWhere((element) =>
                                                                element.product!.id == product.id)
                                                            .quantity ==
                                                        1
                                                    ? Icons.delete
                                                    : Icons.remove,
                                              ),
                                              const SizedBox(width: 10),
                                              Text(
                                                CartService.instance.cartModel.items
                                                    .firstWhere(
                                                        (element) => element.product!.id == product.id)
                                                    .quantity
                                                    .toString(),
                                                style: const TextStyle(
                                                  fontSize: 20,
                                                ),
                                              ),
                                              const SizedBox(width: 10),
                                              SmallIconButton(
                                                onPressed: () async {
                                                  final val = CartService.instance.incrementItemInCart(
                                                    productId: product.id,
                                                  );
                                                  setState(() {});
                                                },
                                                icon: Icons.add,
                                              ),
                                            ],
                                          )
                                        else
                                          SmallIconButton(
                                            onPressed: () async {
                                              final val = CartService.instance.addItemInCart(
                                                  productModel: product, price: product.priceAfterDiscount);
                                              setState(() {});
                                            },
                                            icon: Icons.add,
                                          ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                      separatorBuilder: (BuildContext context, int index) {
                        final product = products[index];
                        if (product.stock == 0) {
                          return const SizedBox.shrink();
                        }
                        return const SizedBox(
                          height: 12,
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    // height: 40,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: const Color(0xFFAECE77),
                    ),
                    child: InkWell(
                        onTap: () async {
                          await Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const CartScreen(),
                            ),
                          );
                          setState(() {});
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  'Open cart (${CartService.instance.cartModel.items.length})',
                                  style: Theme.of(context).textTheme.titleSmall!.copyWith(
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black87,
                                      ),
                                ),
                              ),
                              Text(
                                '\$${CartService.instance.totalPrice()}',
                                style: Theme.of(context).textTheme.titleMedium!.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black87,
                                    ),
                              ),
                              const SizedBox(width: 10),
                              const Icon(
                                Icons.arrow_forward_ios_rounded,
                                size: 20,
                              )
                            ],
                          ),
                        )),
                  ),
                ],
              ),
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
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 1,
              blurRadius: 10,
              offset: const Offset(0, 1),
            ),
          ],
          borderRadius: BorderRadius.circular(12),
          color: const Color(0xFFAECE77),
        ),
        child: Icon(
          icon,
          color: Colors.white,
        ),
      ),
    );
  }
}
