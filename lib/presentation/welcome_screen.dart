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
      backgroundColor: whiteColor, // Set background color
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center, // Center content vertically
          crossAxisAlignment: CrossAxisAlignment.center, // Center content horizontally
          children: [
            // Logo Section
            Column(
              children: [
                Image.asset(
                  'assets/logo.png', // Display logo
                  height: 200,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 10), // Add spacing below logo
              ],
            ),

            // Spacer
            const SizedBox(height: 50), // Add vertical spacing

            // "Who are you" Text
            const Text(
              "Who are you?", // Display title text
              style: titleTextStyle,
            ),

            // Spacer
            const SizedBox(height: 20), // Add vertical spacing

            // Buttons Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0), // Add horizontal padding
              child: Column(
                children: [
                  // Customer Button
                  PrimaryButton(
                      height: 80,
                      buttonText: 'Customer', // Button text
                      textSize: 20,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const CustomerLoginScreen(), // Navigate to CustomerLoginScreen
                          ),
                        );
                      }),
                  const SizedBox(height: 10), // Add spacing between buttons

                  // Business Button
                  PrimaryButton(
                      height: 80,
                      buttonText: 'Business', // Button text
                      textSize: 20,
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
