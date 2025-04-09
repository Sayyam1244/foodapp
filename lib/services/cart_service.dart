import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:helloworld/model/cart_model.dart';
import 'package:helloworld/model/product_model.dart';

class CartService {
  CartService._();
  static CartService cartService = CartService._();
  static CartService get instance => cartService;

  // Cart model to hold cart data
  CartModel cartModel = CartModel(
    items: [],
    createdDate: DateTime.now(),
  );

  // Calculate total price of items in the cart
  double totalPrice() {
    double total = 0;
    for (var item in cartModel.items) {
      total += (item.price * item.quantity);
    }
    return total;
  }

  // Add an item to the cart
  addItemInCart({
    required ProductModel productModel,
    required double price,
  }) {
    if (productModel.stock < 1) {
      return 'Not enough stock available for this product';
    }
    // Clear cart if adding items from a different business
    if (cartModel.items.isNotEmpty) {
      if (productModel.businessId != cartModel.items.first.businessId) {
        clearCart();
      }
    }

    // Check if item already exists in the cart
    var existingItem = cartModel.items.firstWhere(
      (item) => item.productId == productModel.id,
      orElse: () => CartItemModel(
        productId: productModel.id,
        businessId: productModel.businessId,
        product: productModel,
        quantity: 0,
        price: price,
        createdDate: DateTime.now(),
      ),
    );

    // Update quantity if item exists, otherwise add new item
    if (existingItem.quantity > 0) {
      if (existingItem.quantity < productModel.stock) {
        existingItem.quantity += 1;
        return 'Added to cart';
      } else {
        return 'Cannot add more. Reached maximum stock.';
      }
    } else {
      cartModel.items.add(CartItemModel(
        product: productModel,
        productId: productModel.id,
        businessId: productModel.businessId,
        quantity: 1,
        price: price,
        createdDate: DateTime.now(),
      ));
      return 'Added to cart';
    }
  }

  // Remove an item from the cart
  removeItemFromCart({required String productId}) {
    cartModel.items.removeWhere((element) => element.productId == productId);
  }

  // Increment the quantity of an item in the cart
  incrementItemInCart({required String productId}) {
    final index = cartModel.items.indexWhere((element) => element.productId == productId);
    final product = cartModel.items[index].product;
    if (cartModel.items[index].quantity < (product?.stock ?? 0)) {
      cartModel.items[index] = cartModel.items[index].copyWith(quantity: cartModel.items[index].quantity + 1);
    } else {
      return 'Cannot add more. Reached maximum stock.';
    }
  }

  // Decrement the quantity of an item in the cart
  decrementItemInCart({required String productId}) {
    final index = cartModel.items.indexWhere((element) => element.productId == productId);
    if (cartModel.items[index].quantity > 1) {
      cartModel.items[index] = cartModel.items[index].copyWith(quantity: cartModel.items[index].quantity - 1);
    } else {
      cartModel.items.removeAt(index);
    }
  }

  // Place an order and update stock in Firestore
  placeOrder() async {
    try {
      final FirebaseFirestore firestore = FirebaseFirestore.instance;

      // Adjust stock for each product
      for (var item in cartModel.items) {
        final productRef = firestore.collection('products').doc(item.productId);
        await firestore.runTransaction((transaction) async {
          final snapshot = await transaction.get(productRef);
          if (!snapshot.exists) {
            return "Product does not exist";
          }

          final newStock = snapshot.data()!['stock'] - item.quantity;
          if (newStock < 0) {
            return "Not enough stock for product ${item.productId}";
          }

          transaction.update(productRef, {'stock': newStock});
        });
      }

      // Calculate total price and save order to Firestore
      double total = 0;
      for (var item in cartModel.items) {
        total += item.price * item.quantity;
      }
      await firestore.collection('orders').add({
        'items': cartModel.items.map((item) => item.toJson()).toList(),
        'createdDate': cartModel.createdDate,
        'totalPrice': total,
      });

      // Clear the cart after placing the order
      cartModel.items.clear();
      return true;
    } catch (e) {
      return "Failed to place order";
    }
  }

  // Clear all items from the cart
  void clearCart() {
    cartModel.items.clear();
  }
}
