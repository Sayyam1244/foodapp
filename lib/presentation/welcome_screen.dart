import 'package:flutter/material.dart';
import 'package:helloworld/presentation/auth/customer_auth/customer_login_screen.dart';
import 'package:helloworld/presentation/common/primary_button.dart';
import 'package:helloworld/utils/colors.dart';
import 'package:helloworld/utils/textstyles.dart';
import 'auth/business_auth/business_login_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteColor,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Logo Section
            Column(
              children: [
                Image.asset(
                  'assets/logo.png',
                  height: 200,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 10),
              ],
            ),

            // Spacer
            const SizedBox(height: 50),

            // "Are you a" Text
            const Text(
              "Who are you",
              style: titleTextStyle,
            ),

            // Spacer
            const SizedBox(height: 20),

            // Buttons Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                children: [
                  PrimaryButton(
                      buttonText: 'Customer',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const CustomerLoginScreen(), // Navigate to BusinessLoginScreen
                          ),
                        );
                      }),
                  const SizedBox(height: 10),
                  PrimaryButton(
                      buttonText: 'Business',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const BusinessLoginScreen(), // Navigate to BusinessLoginScreen
                          ),
                        );
                      }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
