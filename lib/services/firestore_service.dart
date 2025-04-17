import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:helloworld/main.dart';
import 'package:helloworld/model/cart_model.dart';
import 'package:helloworld/model/product_model.dart';
import 'package:helloworld/model/user_model.dart';
import 'package:helloworld/presentation/welcome_screen.dart';

class FirestoreService {
  FirestoreService._privateConstructor();
  static final FirestoreService _instance = FirestoreService._privateConstructor();
  static FirestoreService get instance => _instance;

  UserModel? currentUser;

  // Set user data in Firestore, upload image if provided
  Future setUser(UserModel user, {File? image}) async {
    try {
      String? imageUrl = user.image;
      if (image != null) {
        final fileName = DateTime.now().millisecondsSinceEpoch.toString();
        final storageRef = FirebaseStorage.instance.ref('users/$fileName.png');
        await storageRef.putFile(image);
        imageUrl = await storageRef.getDownloadURL();
      }
      final usr = user.copyWith(image: imageUrl);
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set(usr.toMap());
      return await getUser(user.uid);
    } catch (e) {
      return 'Error happened, Please try again later.';
    }
  }

  // Get user data from Firestore
  Future<UserModel?> getUser(String uid) async {
    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (doc.exists) {
        currentUser = UserModel.fromMap(doc.data() as Map<String, dynamic>);
        if (currentUser?.isDeleted == true) {
          Navigator.pushAndRemoveUntil(navigatorKey.currentContext!,
              MaterialPageRoute(builder: (context) => const WelcomeScreen()), (route) => false);
          ScaffoldMessenger.of(navigatorKey.currentContext!).showSnackBar(
            const SnackBar(
              behavior: SnackBarBehavior.floating,
              margin: EdgeInsets.only(bottom: 10, left: 10, right: 10),
              content: Text('Your account has been deleted.'),
            ),
          );
        }
        return currentUser;
      } else {
        return null;
      }
    } catch (e) {
      throw Exception('Error getting user: $e');
    }
  }

  // Mark user account as deleted
  Future<bool> deleteAccount(String uid) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'isDeleted': true,
      });
      return true;
    } catch (e) {
      throw Exception('Error deleting user: $e');
    }
  }

  // Add a new product to Firestore
  Future<String> addProduct(
      {required String productName,
      required String productDescription,
      required double priceBeforeDiscount,
      required double priceAfterDiscount,
      required double weight,
      required int stock,
      File? image}) async {
    try {
      String? imageUrl;
      if (image != null) {
        final fileName = DateTime.now().millisecondsSinceEpoch.toString();
        final storageRef = FirebaseStorage.instance.ref('products/$fileName.png');
        await storageRef.putFile(image);
        imageUrl = await storageRef.getDownloadURL();
      }

      final docRef = FirebaseFirestore.instance.collection('products').doc();
      docRef.set({
        'docId': docRef.id,
        'productName': productName,
        'productDescription': productDescription,
        'priceBeforeDiscount': priceBeforeDiscount,
        'priceAfterDiscount': priceAfterDiscount,
        'weight': weight,
        'stock': stock,
        'image': imageUrl,
        'businessId': currentUser!.uid,
        'createdAt': FieldValue.serverTimestamp(),
        "isDeleted": false,
      });
      return docRef.id;
    } catch (e) {
      return "error: ${e.toString()}";
    }
  }

  // Update product details in Firestore
  Future<String> updateProduct(
      {String? id,
      String? productName,
      String? productDescription,
      double? priceBeforeDiscount,
      double? priceAfterDiscount,
      double? weight,
      int? stock,
      File? image}) async {
    try {
      final docRef = FirebaseFirestore.instance.collection('products').doc(id);

      docRef.update({
        if (productName != null) 'productName': productName,
        if (productDescription != null) 'productDescription': productDescription,
        if (priceBeforeDiscount != null) 'priceBeforeDiscount': priceBeforeDiscount,
        if (priceAfterDiscount != null) 'priceAfterDiscount': priceAfterDiscount,
        if (weight != null) 'weight': weight,
        if (stock != null) 'stock': stock,
      });
      return 'Product updated successfully';
    } catch (e) {
      return e.toString();
    }
  }

  // Mark product as deleted in Firestore
  Future deleteProduct(docId) async {
    try {
      await FirebaseFirestore.instance.collection('products').doc(docId).update({
        'isDeleted': true,
      });
      return true;
    } catch (e) {
      return 'Error deleting product';
    }
  }

  // Stream list of users based on role
  Stream<List<UserModel>> getUsersStream(String type) async* {
    await for (var snapshot in FirebaseFirestore.instance
        .collection('users')
        .where('isDeleted', isEqualTo: false)
        .where('role', isEqualTo: type)
        .orderBy('name', descending: false)
        .snapshots()) {
      List<UserModel> users = snapshot.docs.map((doc) {
        return UserModel.fromMap(doc.data());
      }).toList();
      yield users;
    }
  }

  // Get list of users based on role
  Future<List<UserModel>> getUsersList(String type) async {
    final data = await FirebaseFirestore.instance
        .collection('users')
        .where('isDeleted', isEqualTo: false)
        .where('role', isEqualTo: type)
        .get();
    List<UserModel> users = data.docs.map((doc) {
      return UserModel.fromMap(doc.data());
    }).toList();
    return users;
  }

  // Get list of products for a specific business
  Future getProducts(String businessId) async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('products')
          .where('isDeleted', isEqualTo: false)
          .where('businessId', isEqualTo: businessId)
          .get();
      return snapshot.docs.map((doc) {
        return ProductModel.fromMap(doc.data());
      }).toList();
    } catch (e) {
      return e.toString();
    }
  }

  // Get a single product by ID
  Future getSingleProduct(String id) async {
    try {
      final snapshot = await FirebaseFirestore.instance.collection('products').doc(id).get();
      return ProductModel.fromMap(snapshot.data()!);
    } catch (e) {
      return e.toString();
    }
  }

  // Stream list of products for a specific business
  Stream<List<ProductModel>> getProductsStream(String businessId) async* {
    await for (var snapshot in FirebaseFirestore.instance
        .collection('products')
        .where('isDeleted', isEqualTo: false)
        .where('businessId', isEqualTo: businessId)
        .snapshots()) {
      List<ProductModel> products = snapshot.docs.map((doc) {
        return ProductModel.fromMap(doc.data());
      }).toList();
      yield products;
    }
  }

  // Place an order and update stock and user points
  Future placeOrder(
    CartModel cartModel,
    int pointsUsed,
    previousPoints,
    num gmSaved,
  ) async {
    double totalPrice = 0;
    for (var element in cartModel.items) {
      totalPrice += element.price * element.quantity;
    }
    try {
      num orderTotalGms = 0;
      for (final item in cartModel.items) {
        orderTotalGms = orderTotalGms + (item.product?.weight ?? 0);
      }
      final docRef = FirebaseFirestore.instance.collection('orders').doc();
      docRef.set({
        'docId': docRef.id,
        'userId': currentUser!.uid,
        'products': cartModel.items.map((e) => e.toJson()).toList(),
        'totalPrice': totalPrice,
        'createdAt': FieldValue.serverTimestamp(),
        'status': 'active',
        'discount': pointsUsed > 0 ? pointsUsed / 1000 : 0,
        'order_id': _generateUnique8NumbersString(),
      });
      // Adjust stock
      WriteBatch batch = FirebaseFirestore.instance.batch();
      for (var element in cartModel.items) {
        final productRef = FirebaseFirestore.instance.collection('products').doc(element.productId);
        final product = await productRef.get();
        final stock = product.data()!['stock'];
        batch.update(productRef, {'stock': stock - element.quantity});
      }
      await batch.commit();
      // Adjust points
      final userRef = FirebaseFirestore.instance.collection('users').doc(currentUser!.uid);

      await userRef.update({
        'points': previousPoints - pointsUsed + (totalPrice * 100),
        'gmSaved': gmSaved + orderTotalGms,
      });
      return true;
    } catch (e) {
      return e.toString();
    }
  }

  // Stream orders for the current user
  Stream<List<CartModel>> streamUserOrders() async* {
    final userList = await getUsersList('business');

    await for (var snapshot in FirebaseFirestore.instance
        .collection('orders')
        .where('userId', isEqualTo: currentUser!.uid)
        .snapshots()) {
      List<CartModel> orders = [];

      for (var doc in snapshot.docs) {
        final data = CartModel.fromJson(doc.data());

        final user = userList
            .where(
              (user) => user.uid == data.items.first.businessId,
            )
            .firstOrNull;

        data.businessUser = user;
        orders.add(data);
      }

      yield orders;
    }
  }

  // Stream orders for businesses
  Stream<List<CartModel>> streamUserOrdersForBusiness() async* {
    final userList = await getUsersList('customer');

    await for (var snapshot in FirebaseFirestore.instance.collection('orders').snapshots()) {
      List<CartModel> orders = [];

      for (var doc in snapshot.docs) {
        final data = CartModel.fromJson(doc.data());

        if (data.items.first.businessId == FirebaseAuth.instance.currentUser!.uid) {
          final user = userList.where((user) => user.uid == data.userId).firstOrNull;

          data.userModel = user;
          orders.add(data);
        }
      }

      yield orders;
    }
  }

  // Generate a unique 8-digit string
  _generateUnique8NumbersString() {
    return DateTime.now().millisecondsSinceEpoch.toString().substring(1, 8);
  }
}
