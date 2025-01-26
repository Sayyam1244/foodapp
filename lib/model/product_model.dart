import 'package:cloud_firestore/cloud_firestore.dart';

class ProductModel {
  final String id;
  final String productName;
  final String productDescription;
  final double priceBeforeDiscount;
  final double priceAfterDiscount;
  final double weight;
  final int stock;
  final String? imageUrl;
  final String businessId;
  final DateTime? createdAt;
  final bool isDeleted;

  ProductModel({
    required this.id,
    required this.productName,
    required this.productDescription,
    required this.priceBeforeDiscount,
    required this.priceAfterDiscount,
    required this.weight,
    required this.stock,
    this.imageUrl,
    required this.businessId,
    required this.createdAt,
    required this.isDeleted,
  });

  factory ProductModel.fromMap(Map<String, dynamic> data) {
    return ProductModel(
      id: data['docId'],
      productName: data['productName'],
      productDescription: data['productDescription'],
      priceBeforeDiscount: data['priceBeforeDiscount'],
      priceAfterDiscount: data['priceAfterDiscount'],
      weight: data['weight'],
      stock: data['stock'],
      imageUrl: data['imageUrl'],
      businessId: data['businessId'],
      createdAt: data['createdAt'] == null
          ? null
          : (data['createdAt'] as Timestamp).toDate(),
      isDeleted: data['isDeleted'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'productName': productName,
      'productDescription': productDescription,
      'priceBeforeDiscount': priceBeforeDiscount,
      'priceAfterDiscount': priceAfterDiscount,
      'weight': weight,
      'stock': stock,
      'imageUrl': imageUrl,
      'businessId': businessId,
      'createdAt': createdAt,
      'isDeleted': isDeleted,
    };
  }
}
