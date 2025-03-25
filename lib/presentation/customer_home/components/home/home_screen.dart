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
  String toSearch = '';
  String selectedCat = '';
  final categories = [
    'Restaurants',
    'Cafes',
    'Groceries',
    'Bakeries',
  ];

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

  final searchController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteColor,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: (MediaQuery.of(context).padding.top + 20)),

            const SizedBox(height: 12),
            Text(
              'Hello, ${FirestoreService.instance.currentUser?.name ?? ''}',
              style: bodyMediumTextStyle.copyWith(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),

            Text('Where do you want to eat?', style: headlineTextStyle.copyWith(color: primaryColor)),
            const SizedBox(height: 12),
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
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: categories
                    .map((e) => InkWell(
                          onTap: () {
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
                                Image.asset(
                                  getCategoryIcon(e),
                                  height: 40,
                                  width: 40,
                                  color: selectedCat == e ? whiteColor : Colors.black,
                                ),
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

            //one time request get request
            //stream
            StreamBuilder<List<UserModel>>(
              stream: FirestoreService.instance.getUsersStream('business'),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else if (!snapshot.hasData || (snapshot.data?.isEmpty ?? true)) {
                  return const Text('No products available');
                } else {
                  final unFilteredBusiness = snapshot.data ?? [];
                  List<UserModel> business = [];
                  if (toSearch.isNotEmpty) {
                    business.addAll(unFilteredBusiness
                        .where((element) => element.name.toLowerCase().contains(toSearch.toLowerCase())));
                  } else {
                    business.addAll(unFilteredBusiness);
                  }
                  if (selectedCat.isNotEmpty) {
                    business = business.where((element) => element.category == selectedCat).toList();
                  }

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
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  height: 95,
                                  width: 95,
                                  clipBehavior: Clip.hardEdge,
                                  decoration: BoxDecoration(
                                      color: Colors.grey.shade400, borderRadius: BorderRadius.circular(4)
                                      // shape: BoxShape.circle,
                                      ),
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
                                    children: [
                                      const SizedBox(height: 22),
                                      Text(
                                        item.name,
                                        maxLines: 2,
                                        textAlign: TextAlign.center,
                                        style: bodyLargeTextStyle.copyWith(fontWeight: FontWeight.bold),
                                      ),
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
                                  Align(
                                    alignment: Alignment.topRight,
                                    child: Row(
                                      children: [
                                        const Icon(Icons.star_rounded, color: Colors.orange, size: 16),
                                        const SizedBox(width: 5),
                                        Text(
                                          "${averageRating.toStringAsFixed(1)} (${ratings.length})",
                                          style: bodySmallTextStyle.copyWith(fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                  ),
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


// payment -> business -> amount after processing, date, status, 
// list of business
// each business its pending balance which we collected on their behalf in our stripe account
// we will have a page, in that page user will be seeing its balance (pending balance)
// they will have a button to request payout
// they will add a request which will be displayed to the admin to processed.
// when they add a request. they will be attaching there bank details.
// admin acceptes the request. the amount is deducted from their app wallet. and you transfer the amount to the bank manually. 



//

