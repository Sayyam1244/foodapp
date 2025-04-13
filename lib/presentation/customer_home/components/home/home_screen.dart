import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:helloworld/model/product_model.dart';
import 'package:helloworld/model/user_model.dart';
import 'package:helloworld/presentation/common/custom_textfield.dart';
import 'package:helloworld/presentation/menu/menu_screen.dart';
import 'package:helloworld/services/firestore_service.dart';
import 'package:helloworld/utils/colors.dart';
import 'package:helloworld/utils/textstyles.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String toSearch = ''; // Search query
  String selectedCat = ''; // Selected category
  final categories = [
    'Restaurants',
    'Cafes',
    'Groceries',
    'Bakeries',
  ]; // List of categories

  // Get icon path based on category
  String getCategoryIcon(String category) {
    switch (category) {
      case 'Restaurants':
        return 'assets/store.png';
      case 'Cafes':
        return 'assets/tea.png';
      case 'Groceries':
        return 'assets/bag.png';
      case 'Bakeries':
        return 'assets/bread.png';
      default:
        return '';
    }
  }

  final searchController = TextEditingController(); // Controller for search input

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteColor,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Add padding for top of the screen
            SizedBox(height: (MediaQuery.of(context).padding.top + 20)),

            const SizedBox(height: 12),
            // Display greeting with user's name
            Text(
              'Hello, ${FirestoreService.instance.currentUser?.name ?? ''}',
              style: bodyMediumTextStyle.copyWith(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),

            // Display heading
            Text('Where do you want to eat?', style: headlineTextStyle.copyWith(color: primaryColor)),
            const SizedBox(height: 12),

            // Search bar
            CustomTextField(
              prefixIcon: const Icon(Icons.search),
              controller: searchController,
              onChanged: (value) {
                toSearch = value;
                setState(() {});
              },
              hintText: 'Search for a businesses',
            ),
            const SizedBox(height: 12),

            // Horizontal scrollable list of categories
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: categories
                    .map((e) => InkWell(
                          onTap: () {
                            // Toggle category selection
                            if (selectedCat == e) {
                              selectedCat = '';
                            } else {
                              selectedCat = e;
                            }
                            setState(() {});
                          },
                          child: Container(
                            height: 80,
                            width: 80,
                            margin: const EdgeInsets.only(right: 12),
                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                            decoration: BoxDecoration(
                              color: selectedCat == e ? primaryColor : Colors.grey[200],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // Display category icon
                                Image.asset(
                                  getCategoryIcon(e),
                                  height: 40,
                                  width: 40,
                                  color: selectedCat == e ? whiteColor : Colors.black,
                                ),
                                // Display category name
                                Text(e,
                                    style: bodySmallTextStyle.copyWith(
                                        fontSize: 10, color: selectedCat == e ? whiteColor : Colors.black)),
                              ],
                            ),
                          ),
                        ))
                    .toList(),
              ),
            ),
            const SizedBox(height: 12),

            // StreamBuilder to fetch and display businesses
            StreamBuilder<List<UserModel>>(
              stream: FirestoreService.instance.getUsersStream('business'),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  // Show loading indicator
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  // Show error message
                  // return Text('Error: ${snapshot.error}');
                  return Center(
                      child: Padding(
                    padding: const EdgeInsets.only(top: 50),
                    child: Column(
                      children: [
                        const Icon(Icons.error, size: 50, color: greyColor),
                        const SizedBox(height: 12),
                        Text('Error: ${snapshot.error}',
                            style:
                                bodyMediumTextStyle.copyWith(fontWeight: FontWeight.w500, color: greyColor)),
                      ],
                    ),
                  ));
                } else if (!snapshot.hasData || (snapshot.data?.isEmpty ?? true)) {
                  // Show message if no data is available
                  return Center(
                      child: Padding(
                    padding: const EdgeInsets.only(top: 50),
                    child: Column(
                      children: [
                        const Icon(Icons.error, size: 50, color: greyColor),
                        const SizedBox(height: 12),
                        Text('No products available',
                            style:
                                bodyMediumTextStyle.copyWith(fontWeight: FontWeight.w500, color: greyColor)),
                      ],
                    ),
                  ));
                } else {
                  final unFilteredBusiness = snapshot.data ?? [];
                  List<UserModel> business = [];

                  // Filter businesses based on search query
                  if (toSearch.isNotEmpty) {
                    business.addAll(unFilteredBusiness
                        .where((element) => element.name.toLowerCase().contains(toSearch.toLowerCase())));
                  } else {
                    business.addAll(unFilteredBusiness);
                  }

                  // Filter businesses based on selected category
                  if (selectedCat.isNotEmpty) {
                    business = business.where((element) => element.category == selectedCat).toList();
                  }

                  // Display filtered businesses in a list
                  return Expanded(
                    child: ListView.separated(
                      itemCount: business.length,
                      itemBuilder: (context, index) {
                        final item = business[index];
                        final ratings = item.ratings ?? [];
                        final totalRatings = ratings.fold(
                            0, (previousValue, element) => previousValue.toInt() + element.toInt());
                        final averageRating = totalRatings / ratings.length;

                        return InkWell(
                          onTap: () {
                            // Navigate to business menu screen
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => BusinessMenuScreen(userModel: item),
                              ),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(4),
                              color: Colors.grey[200],
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                // Display business image
                                Container(
                                  height: 95,
                                  width: 95,
                                  clipBehavior: Clip.hardEdge,
                                  decoration: BoxDecoration(
                                      color: Colors.grey.shade400, borderRadius: BorderRadius.circular(4)),
                                  child: item.image != null
                                      ? Image.network(
                                          item.image!,
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) =>
                                              const Icon(Icons.business),
                                        )
                                      : const Icon(Icons.fastfood),
                                ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      // Display business name
                                      Text(
                                        item.name,
                                        maxLines: 2,
                                        textAlign: TextAlign.center,
                                        style: bodyLargeTextStyle.copyWith(fontWeight: FontWeight.bold),
                                      ),
                                      // Display business location
                                      Text(
                                        "${item.location}",
                                        maxLines: 2,
                                        textAlign: TextAlign.center,
                                        style: bodyMediumTextStyle,
                                      ),
                                    ],
                                  ),
                                ),
                                if (ratings.isNotEmpty)
                                  SizedBox(
                                    height: 90,
                                    width: 60,
                                    child: Column(
                                      mainAxisSize: MainAxisSize.max,
                                      children: [
                                        Row(
                                          children: [
                                            // Display average rating
                                            Icon(Icons.star_rounded, color: Colors.yellow.shade700, size: 16),
                                            const SizedBox(width: 5),
                                            Text(
                                              "${averageRating.toStringAsFixed(1)} (${ratings.length})",
                                              style: bodySmallTextStyle.copyWith(fontWeight: FontWeight.bold),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  )
                                else
                                  const SizedBox(width: 60)
                              ],
                            ),
                          ),
                        );
                      },
                      separatorBuilder: (BuildContext context, int index) {
                        return const SizedBox(height: 20);
                      },
                    ),
                  );
                }
              },
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
