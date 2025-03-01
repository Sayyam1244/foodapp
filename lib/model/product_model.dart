import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:helloworld/model/user_model.dart';
import 'package:helloworld/services/firestore_service.dart';

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
  UserModel? user;

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
    this.user,
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
      imageUrl: data['image'],
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

  ProductModel copyWith({
    String? id,
    String? productName,
    String? productDescription,
    double? priceBeforeDiscount,
    double? priceAfterDiscount,
    double? weight,
    int? stock,
    String? imageUrl,
    String? businessId,
    DateTime? createdAt,
    bool? isDeleted,
    UserModel? user,
  }) {
    return ProductModel(
      id: id ?? this.id,
      productName: productName ?? this.productName,
      productDescription: productDescription ?? this.productDescription,
      priceBeforeDiscount: priceBeforeDiscount ?? this.priceBeforeDiscount,
      priceAfterDiscount: priceAfterDiscount ?? this.priceAfterDiscount,
      weight: weight ?? this.weight,
      stock: stock ?? this.stock,
      imageUrl: imageUrl ?? this.imageUrl,
      businessId: businessId ?? this.businessId,
      createdAt: createdAt ?? this.createdAt,
      isDeleted: isDeleted ?? this.isDeleted,
      user: user ?? this.user,
    );
  }
}
