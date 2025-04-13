import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:helloworld/presentation/business_home/controller/bottom_bar_controller.dart';
import 'package:helloworld/services/firestore_service.dart';
import 'package:helloworld/utils/colors.dart';
import 'package:collection/collection.dart';

// Main screen for the business home
class BusinessHomeScreen extends StatefulWidget {
  const BusinessHomeScreen({super.key});

  @override
  State<BusinessHomeScreen> createState() => _BusinessHomeScreenState();
}

class _BusinessHomeScreenState extends State<BusinessHomeScreen> {
  bool isLoading = true; // Tracks loading state

  @override
  void initState() {
    // Fetch user data and update loading state
    FirestoreService.instance.getUser(FirebaseAuth.instance.currentUser!.uid).then((value) {
      setState(() {
        isLoading = false;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        extendBody: true,
        // Show loading indicator or selected page
        body: isLoading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : CustomBottomBarController.pages[CustomBottomBarController.selectedIndex].page,
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: cardColor, // Background color for bottom navigation
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
            // mainAxisAlignment: MainAxisAlignment.spaceAround,
            // Generate navigation items dynamically
            children: CustomBottomBarController.pages
                .mapIndexed((index, element) => Expanded(
                      child: InkWell(
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
                              // Display icon
                              Icon(
                                element.icon.icon,
                                color: CustomBottomBarController.selectedIndex == index
                                    ? Colors.black54
                                    : whiteColor,
                                size: 28,
                              ),
                              // Display title
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
                      ),
                    ))
                .toList(),
          ),
        ));
  }
}
