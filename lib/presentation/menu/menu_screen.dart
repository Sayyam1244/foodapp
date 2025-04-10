import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:helloworld/model/product_model.dart';
import 'package:helloworld/model/user_model.dart';
import 'package:helloworld/presentation/cart/cart_screen.dart';
import 'package:helloworld/services/cart_service.dart';
import 'package:helloworld/services/firestore_service.dart';
import 'package:helloworld/utils/colors.dart';
import 'package:helloworld/utils/textstyles.dart';

// Screen to display the business menu
class BusinessMenuScreen extends StatefulWidget {
  const BusinessMenuScreen({super.key, required this.userModel});
  final UserModel userModel;

  @override
  State<BusinessMenuScreen> createState() => _BusinessMenuScreenState();
}

class _BusinessMenuScreenState extends State<BusinessMenuScreen> {
  List<ProductModel> products = []; // List of products
  bool isLoading = true; // Loading state
  final searchController = TextEditingController(); // Search input controller

  @override
  void initState() {
    super.initState();
    _fetchProducts(); // Fetch products on initialization
  }

  // Fetch products from Firestore
  Future<void> _fetchProducts() async {
    final val = await FirestoreService.instance.getProducts(widget.userModel.uid);
    if (val is String) {
      // Show error message if fetching fails
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(val),
        ),
      );
      setState(() {
        isLoading = false;
      });
    } else {
      products = val; // Assign fetched products
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final ratings = widget.userModel.ratings ?? []; // User ratings
    final totalRatings = ratings.fold(0, (previousValue, element) => previousValue.toInt() + element.toInt());
    final averageRating = totalRatings / ratings.length; // Calculate average rating

    return Scaffold(
      appBar: AppBar(backgroundColor: whiteColor), // App bar with white background
      backgroundColor: whiteColor, // Screen background color
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Colors.white, // Show loading spinner
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // User profile and ratings
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // User profile image
                      Container(
                        width: 80,
                        height: 80,
                        clipBehavior: Clip.hardEdge,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4), color: Colors.grey.shade200),
                        child: widget.userModel.image != null
                            ? Image.network(
                                widget.userModel.image!,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) => const Icon(Icons.business),
                              )
                            : const Icon(Icons.business),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // User name
                            Text(
                              widget.userModel.name,
                              style: titleTextStyle,
                            ),
                            if (ratings.isNotEmpty)
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  // Display average rating
                                  RatingBar.builder(
                                    initialRating: averageRating,
                                    direction: Axis.horizontal,
                                    allowHalfRating: true,
                                    ignoreGestures: true,
                                    itemSize: 16,
                                    itemPadding: const EdgeInsets.symmetric(horizontal: 1.0),
                                    itemBuilder: (context, _) => const Icon(
                                      Icons.star,
                                      color: Colors.amber,
                                      size: 12,
                                    ),
                                    onRatingUpdate: (rating) {},
                                  ),
                                  const SizedBox(width: 5),
                                  Text("${averageRating.toStringAsFixed(1)} (${ratings.length})",
                                      style: bodySmallTextStyle.copyWith(fontWeight: FontWeight.bold)),
                                ],
                              ),
                          ],
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(), // Divider line
                  const SizedBox(height: 16),
                  // List of products
                  Expanded(
                    child: ListView.separated(
                      itemCount: products.length,
                      itemBuilder: (context, index) {
                        final product = products[index];
                        bool ifProductAlreadyInCart = CartService.instance.cartModel.items
                            .any((element) => element.product!.id == product.id);

                        // Skip products with no stock
                        if (product.stock == 0) {
                          return const SizedBox.shrink();
                        }

                        return InkWell(
                          onTap: ifProductAlreadyInCart
                              ? null
                              : () {
                                  // Add product to cart
                                  final val = CartService.instance.addItemInCart(
                                      productModel: product, price: product.priceAfterDiscount);
                                  setState(() {});
                                },
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              color: Colors.grey.shade200,
                            ),
                            padding: const EdgeInsets.all(10),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Product image
                                Container(
                                  height: 80,
                                  width: 80,
                                  clipBehavior: Clip.hardEdge,
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade200,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: product.imageUrl != null
                                      ? Image.network(
                                          product.imageUrl!,
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) =>
                                              const Icon(Icons.error),
                                        )
                                      : const Icon(Icons.fastfood),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // Product name and description
                                      Text(product.productName,
                                          style: bodyLargeTextStyle.copyWith(
                                            fontWeight: FontWeight.bold,
                                          )),
                                      Text(product.productDescription, style: bodySmallTextStyle),
                                      const SizedBox(height: 6),
                                      // Product price
                                      Row(
                                        children: [
                                          Text("${product.priceAfterDiscount}",
                                              style: bodyMediumTextStyle.copyWith(
                                                fontWeight: FontWeight.bold,
                                              )),
                                          const SizedBox(width: 4),
                                          Text(
                                            "${product.priceBeforeDiscount}",
                                            style: bodySmallTextStyle.copyWith(
                                              fontWeight: FontWeight.bold,
                                              decoration: TextDecoration.lineThrough,
                                              decorationColor: Colors.red,
                                              decorationThickness: 2,
                                            ),
                                          ),
                                        ],
                                      ),
                                      // Cart actions
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          const SizedBox(),
                                          if (ifProductAlreadyInCart)
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.end,
                                              children: [
                                                // Decrement or remove item from cart
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
                                                // Display item quantity
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
                                                // Increment item in cart
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
                                            const SizedBox()
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
                  // Open cart button
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6),
                      color: cardColor,
                    ),
                    child: InkWell(
                        onTap: () async {
                          // Navigate to cart screen
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
                                  style: titleTextStyle.copyWith(
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              // Display total price
                              Text(
                                '\$${CartService.instance.totalPrice()}',
                                style: bodyMediumTextStyle.copyWith(
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 10),
                              const Icon(
                                color: Colors.white,
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

// Small button widget with an icon
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
          color: cardColor,
        ),
        child: Icon(
          icon,
          color: Colors.white,
        ),
      ),
    );
  }
}
