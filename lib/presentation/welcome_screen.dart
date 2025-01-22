import 'package:flutter/material.dart';
import 'business_login_screen.dart'; // Import the BusinessLoginScreen class
import 'customer_login_screen.dart'; // Import the CustomerLoginScreen class

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF517F03), // Green background
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Logo Section
            Column(
              children: [
                Image.asset(
                  'assets/logo.png', // Replace with your logo asset path
                  height: 200, // Increased logo height to make it larger
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 10),
              ],
            ),

            // Spacer
            const SizedBox(height: 50),

            // "Are you a" Text
            const Text(
              "Are you a",
              style: TextStyle(
                fontSize: 18,
                color: Colors.white,
                fontWeight: FontWeight.w500,
                fontFamily: 'Roboto',
              ),
            ),

            // Spacer
            const SizedBox(height: 20),

            // Buttons Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              const CustomerLoginScreen(), // Navigate to CustomerLoginScreen
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          const Color(0xFFFFF4E2), // Beige button color
                      foregroundColor: const Color(0xFF517F03), // Text color
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 20),
                    ),
                    child: const Center(
                      child: Text(
                        "Customer",
                        style: TextStyle(
                          fontSize: 18, // Increased button font size
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Roboto',
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              const BusinessLoginScreen(), // Navigate to BusinessLoginScreen
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          const Color(0xFFFFF4E2), // Beige button color
                      foregroundColor: const Color(0xFF517F03), // Text color
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 20),
                    ),
                    child: const Center(
                      child: Text(
                        "Business",
                        style: TextStyle(
                          fontSize: 18, // Increased button font size
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Roboto',
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
