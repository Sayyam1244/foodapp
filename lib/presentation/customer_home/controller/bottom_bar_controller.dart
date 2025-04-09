import 'package:flutter/material.dart';
import 'package:helloworld/model/custom_bottom_bar_model.dart';
import 'package:helloworld/presentation/business_home/components/account/account.dart';
import 'package:helloworld/presentation/customer_home/components/home/home_screen.dart';
import 'package:helloworld/presentation/customer_home/components/orders/orders_screen.dart';

// Controller for managing the custom bottom navigation bar
class CustomBottomBarController {
  // Index of the currently selected bottom bar item
  static int selectedIndex = 0;

  // List of pages and their corresponding icons and titles
  static List<BottomBarModel> pages = [
    BottomBarModel(
      title: "Home", // Title for the Home tab
      icon: const Icon(Icons.home_filled), // Icon for the Home tab
      page: const HomeScreen(), // Screen for the Home tab
    ),
    BottomBarModel(
      title: "Orders", // Title for the Orders tab
      icon: const Icon(Icons.shopping_bag_outlined), // Icon for the Orders tab
      page: const OrdersScreen(), // Screen for the Orders tab
    ),
    BottomBarModel(
      title: "My Account", // Title for the Account tab
      icon: const Icon(Icons.person), // Icon for the Account tab
      page: const MyAcccount(), // Screen for the Account tab
    ),
  ];
}
