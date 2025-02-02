import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:helloworld/model/product_model.dart';
import 'package:helloworld/model/user_model.dart';
import 'package:helloworld/presentation/menu/menu_screen.dart';
import 'package:helloworld/services/firestore_service.dart';

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
  final searchController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF517F03),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: (MediaQuery.of(context).padding.top + 20)),
            Image.asset(
              'assets/logo.png',
              fit: BoxFit.contain,
              height: 50,
            ),
            const SizedBox(height: 12),
            Text(
              'Hello, ${FirestoreService.instance.currentUser?.name ?? ''}',
              style: const TextStyle(
                color: Color(0xFFFFF4E2),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: searchController,
              onChanged: (value) {
                toSearch = value;
                setState(() {});
              },
              decoration: const InputDecoration(
                hintText: 'Search for businesses',
                filled: true,
                fillColor: Color(0xFFFFF4E2),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                  borderSide: BorderSide.none,
                ),
                prefixIcon: Icon(Icons.search),
              ),
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
                            margin: const EdgeInsets.only(right: 12),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 12),
                            decoration: BoxDecoration(
                              color: selectedCat == e
                                  ? const Color(0xFFAECE77)
                                  : const Color(0xFFFFF4E2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(e),
                          ),
                        ))
                    .toList(),
              ),
            ),
            //one time request get request
            //stream
            StreamBuilder<List<UserModel>>(
              stream: FirestoreService.instance.getUsersStream('business'),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else if (!snapshot.hasData ||
                    (snapshot.data?.isEmpty ?? true)) {
                  return const Text('No products available');
                } else {
                  final unFilteredBusiness = snapshot.data ?? [];
                  List<UserModel> business = [];
                  if (toSearch.isNotEmpty) {
                    business.addAll(unFilteredBusiness.where((element) =>
                        element.name
                            .toLowerCase()
                            .contains(toSearch.toLowerCase())));
                  } else {
                    business.addAll(unFilteredBusiness);
                  }
                  if (selectedCat.isNotEmpty) {
                    business = business
                        .where((element) => element.category == selectedCat)
                        .toList();
                  }

                  return Expanded(
                    child: ListView.separated(
                      itemCount: business.length,
                      itemBuilder: (context, index) {
                        final item = business[index];
                        return InkWell(
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) =>
                                    BusinessMenuScreen(userModel: item),
                              ),
                            );
                          },
                          child: Stack(
                            alignment: Alignment.centerLeft,
                            children: [
                              Container(
                                width: double.infinity,
                                margin: const EdgeInsets.only(left: 50),
                                padding:
                                    const EdgeInsets.only(top: 30, bottom: 30),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(42),
                                  color: const Color(0xFFFFF4E2),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      item.name,
                                      maxLines: 2,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF517F03),
                                      ),
                                    ),
                                    Text(
                                      "${item.location}",
                                      maxLines: 2,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF517F03),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                height: 95,
                                width: 95,
                                clipBehavior: Clip.hardEdge,
                                decoration: const BoxDecoration(
                                  color: Color(0xFFAECE77),
                                  shape: BoxShape.circle,
                                ),
                                child: item.image != null
                                    ? Image.network(
                                        item.image!,
                                        fit: BoxFit.cover,
                                      )
                                    : const Icon(Icons.fastfood),
                              ),
                            ],
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

