import 'package:flutter/material.dart';
import 'package:helloworld/model/custom_bottom_bar_model.dart';
import 'package:helloworld/presentation/business_home/components/account/account.dart';
import 'package:helloworld/presentation/business_home/components/menu/menu.dart';
import 'package:helloworld/presentation/business_home/components/orders/orders.dart';

// Controller for managing the custom bottom navigation bar
class CustomBottomBarController {
  // Index of the currently selected tab
  static int selectedIndex = 2;

  // List of bottom bar items with their respective pages
  static List<BottomBarModel> pages = [
    BottomBarModel(
      title: "Orders", // Title for the Orders tab
      icon: const Icon(Icons.fire_truck), // Icon for the Orders tab
      page: const OrdersScreen(), // Associated page for the Orders tab
    ),
    BottomBarModel(
      title: "Menu", // Title for the Menu tab
      icon: const Icon(Icons.menu), // Icon for the Menu tab
      page: const MenuScreen(), // Associated page for the Menu tab
    ),
    BottomBarModel(
      title: "My Account", // Title for the Account tab
      icon: const Icon(Icons.person), // Icon for the Account tab
      page: const MyAcccount(), // Associated page for the Account tab
    ),
  ];
}
