import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:helloworld/presentation/customer_home/controller/bottom_bar_controller.dart';
import 'package:helloworld/services/firestore_service.dart';
import 'package:helloworld/services/notifications_services.dart';

class CustomerHomeScreen extends StatefulWidget {
  const CustomerHomeScreen({super.key});

  @override
  State<CustomerHomeScreen> createState() => _CustomerHomeScreenState();
}

class _CustomerHomeScreenState extends State<CustomerHomeScreen> {
  @override
  void initState() {
    initTopic();
    FirestoreService.instance
        .getUser(FirebaseAuth.instance.currentUser!.uid)
        .then((value) {
      setState(() {
        isLoading = false;
      });
    });
    super.initState();
  }

  initTopic() async {
    await FirebaseMessaging.instance.subscribeToTopic('all');
  }

  bool isLoading = true;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: isLoading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : CustomBottomBarController
                .pages[CustomBottomBarController.selectedIndex].page,
        bottomNavigationBar: BottomNavigationBar(
          items: CustomBottomBarController.pages
              .map(
                (page) => BottomNavigationBarItem(
                  icon: page.icon,
                  label: page.title,
                ),
              )
              .toList(),
          currentIndex: CustomBottomBarController.selectedIndex,
          onTap: (index) {
            setState(() {
              CustomBottomBarController.selectedIndex = index;
            });
          },
        ));
  }
}
