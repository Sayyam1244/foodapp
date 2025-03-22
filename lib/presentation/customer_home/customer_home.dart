import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:helloworld/presentation/customer_home/controller/bottom_bar_controller.dart';
import 'package:helloworld/services/firestore_service.dart';
import 'package:helloworld/services/notifications_services.dart';
import 'package:helloworld/utils/colors.dart';
import 'package:collection/collection.dart';

class CustomerHomeScreen extends StatefulWidget {
  const CustomerHomeScreen({super.key});

  @override
  State<CustomerHomeScreen> createState() => _CustomerHomeScreenState();
}

class _CustomerHomeScreenState extends State<CustomerHomeScreen> {
  @override
  void initState() {
    initTopic();
    FirestoreService.instance.getUser(FirebaseAuth.instance.currentUser!.uid).then((value) {
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
      extendBody: true,
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : CustomBottomBarController.pages[CustomBottomBarController.selectedIndex].page,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: primaryColor,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20.0),
            topRight: Radius.circular(20.0),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: CustomBottomBarController.pages
                .mapIndexed((index, element) => InkWell(
                      onTap: () {
                        setState(() {
                          CustomBottomBarController.selectedIndex = index;
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              element.icon.icon,
                              color: CustomBottomBarController.selectedIndex == index
                                  ? Colors.black54
                                  : whiteColor,
                              size: 28,
                            ),
                            Text(
                              element.title,
                              style: TextStyle(
                                color: CustomBottomBarController.selectedIndex == index
                                    ? Colors.black54
                                    : whiteColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ))
                .toList()),
      ),
    );
  }
}
