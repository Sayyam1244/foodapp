import 'package:flutter/material.dart';
import 'package:helloworld/model/custom_bottom_bar_model.dart';
import 'package:helloworld/presentation/business_home/components/account.dart';

class CustomBottomBarController {
  static int selectedIndex = 2;
  static List<BottomBarModel> pages = [
    BottomBarModel(
      title: "Orders",
      icon: const Icon(Icons.fire_truck),
      page: const SizedBox(),
    ),
    BottomBarModel(
      title: "Menu",
      icon: const Icon(Icons.menu),
      page: const SizedBox(),
    ),
    BottomBarModel(
      title: "My Account",
      icon: const Icon(Icons.person),
      page: const MyAcccount(),
    ),
  ];
}
