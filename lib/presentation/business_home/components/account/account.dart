import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:helloworld/presentation/business_home/components/account/change_pass.dart';
import 'package:helloworld/presentation/business_home/components/account/edit_profile.dart';
import 'package:helloworld/presentation/common/custom_dialogue.dart';
import 'package:helloworld/presentation/welcome_screen.dart';
import 'package:helloworld/services/auth_service.dart';
import 'package:helloworld/services/firestore_service.dart';
import 'package:helloworld/utils/colors.dart';
import 'package:helloworld/utils/textstyles.dart';

class MyAcccount extends StatefulWidget {
  const MyAcccount({super.key});

  @override
  State<MyAcccount> createState() => _MyAcccountState();
}

class _MyAcccountState extends State<MyAcccount> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: whiteColor,
        body: SingleChildScrollView(
          child: Column(
            children: [
              // Add spacing for top padding
              SizedBox(height: MediaQuery.of(context).padding.top + 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const SizedBox(width: 24), // Display user profile image or default icon
                  Container(
                    height: 60,
                    width: 60,
                    clipBehavior: Clip.hardEdge,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      shape: BoxShape.circle,
                    ),
                    child: FirestoreService.instance.currentUser!.image != null
                        ? Image.network(
                            FirestoreService.instance.currentUser!.image!,
                            fit: BoxFit.cover,
                          )
                        : Icon(
                            (FirestoreService.instance.currentUser?.role == 'business')
                                ? Icons.storefront
                                : Icons.person,
                            color: greyColor,
                            size: 36),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Display welcome message with user name
                      Text("Welcome, ${FirestoreService.instance.currentUser!.name}", style: titleTextStyle),
                      // Show ratings if user is a business
                      if (FirestoreService.instance.currentUser?.role == 'business')
                        StreamBuilder(
                            stream: FirebaseFirestore.instance
                                .collection('users')
                                .doc(FirestoreService.instance.currentUser!.uid)
                                .snapshots(),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState == ConnectionState.waiting) {
                                return const SizedBox();
                              }
                              List ratings = (snapshot.data?.data() as Map).containsKey('ratings')
                                  ? (snapshot.data?['ratings'] ?? [])
                                  : [];
                              num totalRatings = ratings.isEmpty
                                  ? 0
                                  : ratings.fold(0, (previousValue, element) => previousValue + element);
                              final averageRating = ratings.isEmpty ? 0 : totalRatings / ratings.length;
                              return Row(
                                children: [
                                  Icon(Icons.star, color: Colors.yellow.shade700, size: 14),
                                  const SizedBox(width: 5),
                                  // Display average rating and count
                                  Text(
                                    "${averageRating.toStringAsFixed(1)} (${ratings.length})",
                                    style: TextStyle(
                                      color: Colors.yellow.shade700,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              );
                            }),
                    ],
                  ),
                ],
              ),
              const SizedBox(width: 10),
              // Show wallet and saved stats if user is a customer
              if (FirestoreService.instance.currentUser?.role == 'customer')
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Wallet section
                      Text("My Wallet", style: bodyLargeTextStyle.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 5),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          border: Border.all(color: Colors.black),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: StreamBuilder(
                          stream: FirebaseFirestore.instance
                              .collection('users')
                              .doc(FirestoreService.instance.currentUser!.uid)
                              .snapshots(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return const SizedBox();
                            }
                            final points = (snapshot.data?.data() as Map).containsKey('points')
                                ? (snapshot.data?['points'] ?? 0)
                                : 0;
                            // Display wallet points
                            return Row(
                              children: [
                                const Icon(
                                  Icons.account_balance_wallet_outlined,
                                  color: Colors.black,
                                  size: 34,
                                ),
                                const SizedBox(width: 10),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("$points", style: bodyLargeTextStyle),
                                    const Text("Points available", style: bodySmallTextStyle),
                                  ],
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Saved stats section
                      Text("You Helped Save!",
                          style: bodyLargeTextStyle.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 5),
                      StreamBuilder(
                          stream: FirebaseFirestore.instance
                              .collection('users')
                              .doc(FirestoreService.instance.currentUser!.uid)
                              .snapshots(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return const SizedBox();
                            }
                            num gmSaved = (snapshot.data?.data() as Map).containsKey('gmSaved')
                                ? (snapshot.data?['gmSaved'] ?? 0)
                                : 0;
                            num co2 = gmSaved > 0 ? gmSaved * 2 : 0;
                            // Display food rescued and CO2 saved
                            return Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    children: [
                                      Container(
                                          width: double.infinity,
                                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                          decoration: BoxDecoration(
                                            color: Colors.grey.shade200,
                                            border: Border.all(color: Colors.black),
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: Center(
                                            child: Text('${gmSaved.toInt()} g', style: bodySmallTextStyle),
                                          )),
                                      const SizedBox(height: 5),
                                      const Text("Food Rescued", style: bodySmallTextStyle),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    children: [
                                      Container(
                                          width: double.infinity,
                                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                          decoration: BoxDecoration(
                                            color: Colors.grey.shade200,
                                            border: Border.all(color: Colors.black),
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: Center(
                                            child: Text('${co2.toInt()} g', style: bodySmallTextStyle),
                                          )),
                                      const SizedBox(height: 5),
                                      const Text("CO2", style: bodySmallTextStyle),
                                    ],
                                  ),
                                ),
                              ],
                            );
                          }),
                      const SizedBox(height: 5),
                    ],
                  ),
                ),
              const SizedBox(height: 20),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 24),
                child: Divider(thickness: 1.8),
              ),
              const SizedBox(height: 50),
              // Edit profile option
              AcccountSettingTile(
                title: 'Edit Profile',
                icon: Icons.edit_note_rounded,
                onTap: () async {
                  await Navigator.push(
                      context, MaterialPageRoute(builder: (context) => const EditProfileScreen()));
                  setState(() {});
                },
              ),
              const SizedBox(height: 20),
              // Change password option
              AcccountSettingTile(
                title: 'Change Password',
                icon: Icons.password,
                onTap: () async {
                  await Navigator.push(
                      context, MaterialPageRoute(builder: (context) => const ChangePassScreen()));
                  setState(() {});
                },
              ),
              const SizedBox(height: 20),
              // Delete account option
              AcccountSettingTile(
                title: 'Delete Account',
                icon: Icons.close,
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) => CustomDialogue(
                      title: ("Delete Account"),
                      content: ("Are you sure you want to delete your account?"),
                      action: () async {
                        await FirestoreService.instance
                            .deleteAccount(FirestoreService.instance.currentUser!.uid);
                        await FirebaseAuth.instance.currentUser!.delete();
                        // await AuthService.signOut();
                        Navigator.pushAndRemoveUntil(context,
                            MaterialPageRoute(builder: (context) => const WelcomeScreen()), (route) => false);
                      },
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
              // Logout option
              AcccountSettingTile(
                title: 'Logout',
                icon: Icons.logout,
                onTap: () async {
                  showDialog(
                      context: context,
                      builder: (context) => CustomDialogue(
                            title: ("Logout"),
                            content: ("Are you sure you want to logout?"),
                            action: () async {
                              await AuthService.signOut();
                              Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(builder: (context) => const WelcomeScreen()),
                                  (route) => false);
                            },
                          ));
                },
              ),
              const SizedBox(height: 100),
            ],
          ),
        ));
  }
}

class AcccountSettingTile extends StatelessWidget {
  const AcccountSettingTile({
    super.key,
    required this.title,
    required this.icon,
    required this.onTap,
  });
  final String title;
  final IconData icon;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 30),
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 24),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: InkWell(
        onTap: onTap,
        child: Row(
          children: [
            // Display icon
            Icon(
              icon,
              color: whiteColor,
              size: 32,
            ),
            const SizedBox(width: 10),
            // Display title
            Text(title,
                style: bodyLargeTextStyle.copyWith(
                  color: whiteColor,
                  fontWeight: FontWeight.w500,
                )),
          ],
        ),
      ),
    );
  }
}
