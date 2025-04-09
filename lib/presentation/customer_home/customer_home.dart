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
    // Initialize topic subscription and fetch user data
    initTopic();
    FirestoreService.instance.getUser(FirebaseAuth.instance.currentUser!.uid).then((value) {
      setState(() {
        isLoading = false; // Stop loading once data is fetched
      });
    });
    super.initState();
  }

  // Subscribe to a topic for notifications
  initTopic() async {
    await FirebaseMessaging.instance.subscribeToTopic('all');
  }

  bool isLoading = true; // Tracks loading state

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(), // Show loader while loading
            )
          : CustomBottomBarController
              .pages[CustomBottomBarController.selectedIndex].page, // Show selected page
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: primaryColor, // Background color for bottom navigation bar
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20.0),
            topRight: Radius.circular(20.0),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1), // Shadow effect
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
                        // Update selected index on tap
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
                                  ? Colors.black54 // Highlight selected icon
                                  : whiteColor,
                              size: 28,
                            ),
                            Text(
                              element.title,
                              style: TextStyle(
                                color: CustomBottomBarController.selectedIndex == index
                                    ? Colors.black54 // Highlight selected text
                                    : whiteColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ))
                .toList()), // Generate navigation items dynamically
      ),
    );
  }
}
