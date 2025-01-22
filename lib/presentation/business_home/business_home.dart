import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:helloworld/presentation/business_home/controller/bottom_bar_controller.dart';
import 'package:helloworld/services/firestore_service.dart';

class BusinessHomeScreen extends StatefulWidget {
  const BusinessHomeScreen({super.key});

  @override
  State<BusinessHomeScreen> createState() => _BusinessHomeScreenState();
}

class _BusinessHomeScreenState extends State<BusinessHomeScreen> {
  @override
  void initState() {
    FirestoreService.instance
        .getUser(FirebaseAuth.instance.currentUser!.uid)
        .then((value) {
      setState(() {
        isLoading = false;
      });
    });
    super.initState();
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
