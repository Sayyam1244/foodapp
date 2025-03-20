import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:helloworld/presentation/business_home/components/account/change_pass.dart';
import 'package:helloworld/presentation/business_home/components/account/edit_profile.dart';
import 'package:helloworld/presentation/welcome_screen.dart';
import 'package:helloworld/services/auth_service.dart';
import 'package:helloworld/services/firestore_service.dart';

class MyAcccount extends StatefulWidget {
  const MyAcccount({super.key});

  @override
  State<MyAcccount> createState() => _MyAcccountState();
}

class _MyAcccountState extends State<MyAcccount> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color(0xFF517F03),
        body: Center(
          child: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(height: MediaQuery.of(context).size.height * 0.1),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      height: 50,
                      width: 50,
                      clipBehavior: Clip.hardEdge,
                      decoration: const BoxDecoration(
                        color: Color(0xFFFFF4E2),
                        shape: BoxShape.circle,
                      ),
                      child: FirestoreService.instance.currentUser!.image != null
                          ? Image.network(
                              FirestoreService.instance.currentUser!.image!,
                              fit: BoxFit.cover,
                            )
                          : const Icon(Icons.person),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Hello, ${FirestoreService.instance.currentUser!.name}",
                          style: const TextStyle(
                            color: Color(0xFFFFF4E2),
                            fontSize: 20,
                          ),
                        ),
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
                                    const Icon(Icons.star, color: Colors.yellow),
                                    const SizedBox(width: 5),
                                    Text(
                                      "${averageRating.toStringAsFixed(1)} (${ratings.length})",
                                      style: const TextStyle(
                                        color: Color(0xFFFFF4E2),
                                        fontSize: 18,
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
                if (FirestoreService.instance.currentUser?.role == 'customer')
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "My Wallet",
                          style: TextStyle(color: Color(0xFFFFF4E2), fontSize: 18),
                        ),
                        const SizedBox(height: 5),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF4E2),
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
                              return Row(
                                children: [
                                  const Icon(
                                    Icons.account_balance_wallet_outlined,
                                    color: Color(0xFF517F03),
                                    size: 44,
                                  ),
                                  const SizedBox(width: 10),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "$points",
                                        style: const TextStyle(
                                          color: Color(0xFF517F03),
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const Text(
                                        "Points available",
                                        style: TextStyle(
                                          color: Color(0xFF517F03),
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          "You helped saved",
                          style: TextStyle(color: Color(0xFFFFF4E2), fontSize: 18),
                        ),
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
                              return Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      children: [
                                        Container(
                                            width: double.infinity,
                                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFFFF4E2),
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                            child: Center(
                                              child: Text(
                                                '${gmSaved.toInt()} g',
                                                style: const TextStyle(
                                                  color: Color(0xFF517F03),
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            )),
                                        const SizedBox(height: 5),
                                        const Text(
                                          "Food Rescued",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                          ),
                                        ),
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
                                              color: const Color(0xFFFFF4E2),
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                            child: Center(
                                              child: Text(
                                                '${co2.toInt()} g',
                                                style: const TextStyle(
                                                  color: Color(0xFF517F03),
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            )),
                                        const SizedBox(height: 5),
                                        const Text(
                                          "CO2",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                          ),
                                        ),
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
                AcccountSettingTile(
                  title: 'Delete Account',
                  icon: Icons.close,
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text("Delete Account"),
                        content: const Text("Are you sure you want to delete your account?"),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: const Text("Cancel"),
                          ),
                          TextButton(
                            onPressed: () async {
                              await FirestoreService.instance
                                  .deleteAccount(FirestoreService.instance.currentUser!.uid);
                              await AuthService.signOut();
                              Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(builder: (context) => const WelcomeScreen()),
                                  (route) => false);
                            },
                            child: const Text("Delete"),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(height: 20),
                AcccountSettingTile(
                  title: 'Logout',
                  icon: Icons.logout,
                  onTap: () async {
                    showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                              title: const Text("Logout"),
                              content: const Text("Are you sure you want to logout?"),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: const Text("Cancel"),
                                ),
                                TextButton(
                                  onPressed: () async {
                                    await AuthService.signOut();
                                    Navigator.pushAndRemoveUntil(
                                        context,
                                        MaterialPageRoute(builder: (context) => const WelcomeScreen()),
                                        (route) => false);
                                  },
                                  child: const Text("Logout"),
                                ),
                              ],
                            ));
                  },
                ),
                const SizedBox(height: 20),
              ],
            ),
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
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF4E2),
        borderRadius: BorderRadius.circular(30),
      ),
      child: InkWell(
        onTap: onTap,
        child: Row(
          children: [
            Icon(
              icon,
              color: const Color(0xFF517F03),
              size: 36,
            ),
            const SizedBox(width: 10),
            Text(
              title,
              style: const TextStyle(color: Color(0xFF517F03), fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}
