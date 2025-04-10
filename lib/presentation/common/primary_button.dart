import 'package:flutter/material.dart';
import 'package:helloworld/utils/colors.dart';
import 'package:helloworld/utils/textstyles.dart';

// A reusable primary button widget
class PrimaryButton extends StatelessWidget {
  final String buttonText; // Text displayed on the button
  final VoidCallback onTap; // Callback function when button is pressed

  const PrimaryButton({
    Key? key,
    required this.buttonText,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onTap, // Trigger the callback when pressed
      style: ElevatedButton.styleFrom(
        backgroundColor: cardColor, // Button background color
        foregroundColor: primaryColor, // Button text color
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4), // Rounded corners
        ),
        padding: const EdgeInsets.symmetric(vertical: 20), // Vertical padding
      ),
      child: Center(
        child: Text(
          buttonText, // Display the button text
          style: bodyLargeTextStyle.copyWith(
            color: primaryColor, // Text color
            fontSize: 16, // Font size
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
