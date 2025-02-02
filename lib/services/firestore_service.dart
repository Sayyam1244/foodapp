import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:helloworld/main.dart';
import 'package:helloworld/model/product_model.dart';
import 'package:helloworld/model/user_model.dart';
import 'package:helloworld/presentation/welcome_screen.dart';

class FirestoreService {
  FirestoreService._privateConstructor();
  static final FirestoreService _instance =
      FirestoreService._privateConstructor();
  static FirestoreService get instance => _instance;

  UserModel? currentUser;

  Future setUser(UserModel user, {File? image}) async {
    try {
      //TODO: Enable firebase storage
      String? imageUrl = user.image;
      if (image != null) {
        final fileName = DateTime.now().millisecondsSinceEpoch.toString();
        final storageRef = FirebaseStorage.instance.ref('users/$fileName.png');
        await storageRef.putFile(image);
        imageUrl = await storageRef.getDownloadURL();
      }
      final usr = user.copyWith(image: imageUrl);
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .set(usr.toMap());
      return await getUser(user.uid);
    } catch (e) {
      return 'Error happened, Please try again later.';
    }
  }

  Future<UserModel?> getUser(String uid) async {
    try {
      DocumentSnapshot doc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (doc.exists) {
        currentUser = UserModel.fromMap(doc.data() as Map<String, dynamic>);
        if (currentUser?.isDeleted == true) {
          Navigator.pushAndRemoveUntil(
              navigatorKey.currentContext!,
              MaterialPageRoute(builder: (context) => const WelcomeScreen()),
              (route) => false);
        }
        return currentUser;
      } else {
        return null;
      }
    } catch (e) {
      throw Exception('Error getting user: $e');
    }
  }

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

  Future<String> addProduct(
      {required String productName,
      required String productDescription,
      required double priceBeforeDiscount,
      required double priceAfterDiscount,
      required double weight,
      required int stock,
      File? image}) async {
    try {
      final fileName = DateTime.now().millisecondsSinceEpoch.toString();
      final storageRef = FirebaseStorage.instance.ref('products/$fileName.png');
      await storageRef.putFile(image!);
      final imageUrl = await storageRef.getDownloadURL();
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
      return 'Product added successfully';
    } catch (e) {
      return e.toString();
    }
  }

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
      // final fileName = DateTime.now().millisecondsSinceEpoch.toString();
      // final storageRef = FirebaseStorage.instance.ref('products/$fileName.png');
      // await storageRef.putFile(image!);
      // final imageUrl = storageRef.getDownloadURL();
      final docRef = FirebaseFirestore.instance.collection('products').doc(id);

      docRef.update({
        if (productName != null) 'productName': productName,
        if (productDescription != null)
          'productDescription': productDescription,
        if (priceBeforeDiscount != null)
          'priceBeforeDiscount': priceBeforeDiscount,
        if (priceAfterDiscount != null)
          'priceAfterDiscount': priceAfterDiscount,
        if (weight != null) 'weight': weight,
        if (stock != null) 'stock': stock,
        // if (imageUrl != null) 'image': imageUrl,
      });
      return 'Product updated successfully';
    } catch (e) {
      return e.toString();
    }
  }

  Future deleteProduct(docId) async {
    try {
      await FirebaseFirestore.instance
          .collection('products')
          .doc(docId)
          .update({
        'isDeleted': true,
      });
      return true;
    } catch (e) {
      return 'Error deleting product';
    }
  }

  // Stream<List<ProductModel>> getProductsStream() async* {
  //   Stream<List<UserModel>> usersStream = getUsersStream();

  //   await for (var snapshot in FirebaseFirestore.instance
  //       .collection('products')
  //       .where('isDeleted', isEqualTo: false)
  //       .snapshots()) {
  //     List<UserModel> users = await usersStream.first;

  //     List<ProductModel> products = snapshot.docs.map((doc) {
  //       ProductModel productModel = ProductModel.fromMap(doc.data());

  //       productModel.user = users
  //           .where((user) => user.uid == productModel.businessId)
  //           .firstOrNull;

  //       return productModel;
  //     }).toList();

  //     yield products;
  //   }
  // }

  Stream<List<UserModel>> getUsersStream(String type) async* {
    await for (var snapshot in FirebaseFirestore.instance
        .collection('users')
        .where('isDeleted', isEqualTo: false)
        .where('role', isEqualTo: type)
        .snapshots()) {
      List<UserModel> users = snapshot.docs.map((doc) {
        return UserModel.fromMap(doc.data());
      }).toList();
      yield users;
    }
  }

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
}
