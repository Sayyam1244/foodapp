import 'package:helloworld/model/product_model.dart';
import 'package:helloworld/model/user_model.dart';

class CartModel {
  final String? orderId;
  UserModel? businessUser;
  UserModel? userModel;
  final String? id;
  final String? userId;
  final String? status;
  final String? total;
  final List<CartItemModel> items;
  final DateTime createdDate;
  final String? discount;

  CartModel({
    this.userModel,
    this.orderId,
    this.status,
    this.total,
    this.id,
    this.userId,
    this.businessUser,
    required this.items,
    required this.createdDate,
    this.discount,
  });
  CartModel copyWith({
    String? id,
    String? userId,
    List<CartItemModel>? items,
    DateTime? createdDate,
  }) {
    return CartModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      items: items ?? this.items,
      createdDate: createdDate ?? this.createdDate,
    );
  }

  factory CartModel.fromJson(Map<String, dynamic> json) {
    return CartModel(
      orderId: json['order_id'].toString(),
      status: json['status'],
      total: json['totalPrice'].toString(),
      id: json['docId'],
      userId: json['userId'],
      items: (json['products'] as List)
          .map((item) => CartItemModel.fromJson(item))
          .toList(),
      createdDate: json['createdDate'] != null
          ? DateTime.parse(json['createdDate'])
          : DateTime.now(),
      discount: json['discount'].toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'items': items.map((item) => item.toJson()).toList(),
      'createdDate': DateTime.now().toIso8601String(),
    };
  }
}

class CartItemModel {
  final String productId;
  final String businessId;
  int quantity;
  final double price;
  final DateTime createdDate;
  ProductModel? product;

  CartItemModel(
      {required this.productId,
      required this.businessId,
      required this.quantity,
      required this.price,
      required this.createdDate,
      this.product});
  CartItemModel copyWith({
    String? productId,
    String? businessId,
    int? quantity,
    double? price,
    DateTime? createdDate,
    ProductModel? product,
  }) {
    return CartItemModel(
      productId: productId ?? this.productId,
      businessId: businessId ?? this.businessId,
      quantity: quantity ?? this.quantity,
      price: price ?? this.price,
      createdDate: createdDate ?? this.createdDate,
      product: product ?? this.product,
    );
  }

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    return CartItemModel(
      productId: json['productId'],
      businessId: json['businessId'],
      quantity: json['quantity'],
      price: json['price'],
      createdDate: DateTime.parse(json['createdDate']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'businessId': businessId,
      'quantity': quantity,
      'price': price,
      'createdDate': createdDate.toIso8601String(),
    };
  }
}
