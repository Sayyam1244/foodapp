import 'package:flutter/material.dart';
import 'package:helloworld/model/custom_bottom_bar_model.dart';
import 'package:helloworld/presentation/business_home/components/account/account.dart';
import 'package:helloworld/presentation/customer_home/components/home/home_screen.dart';

class CustomBottomBarController {
  static int selectedIndex = 0;
  static List<BottomBarModel> pages = [
    BottomBarModel(
      title: "Home",
      icon: const Icon(Icons.home),
      page: const HomeScreen(),
    ),
    BottomBarModel(
      title: "Orders",
      icon: const Icon(Icons.home),
      page: const SizedBox(),
    ),
    BottomBarModel(
      title: "My Account",
      icon: const Icon(Icons.person),
      page: const MyAcccount(),
    ),
  ];
}
