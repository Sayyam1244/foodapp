import 'package:flutter/material.dart';
import 'package:helloworld/utils/colors.dart';
import 'package:helloworld/utils/textstyles.dart';

// A reusable primary button widget
class PrimaryButton extends StatelessWidget {
  final String buttonText; // Text displayed on the button
  final VoidCallback onTap; // Callback function when button is pressed
  final double? height; // Optional height for the button
  final double? textSize; // Optional text size for the button text

  const PrimaryButton({
    Key? key,
    required this.buttonText,
    required this.onTap,
    this.height, // Optional height parameter
    this.textSize, // Optional text size parameter
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height, // Use the height if provided
      child: ElevatedButton(
        onPressed: onTap, // Trigger the callback when pressed
        style: ElevatedButton.styleFrom(
          backgroundColor: cardColor, // Button background color
          foregroundColor: primaryColor, // Button text color
          shape: RoundedRectangleBorder(
            side: const BorderSide(color: primaryColor),
            borderRadius: BorderRadius.circular(4), // Rounded corners
          ),
          padding: const EdgeInsets.symmetric(vertical: 20), // Vertical padding
        ),
        child: Center(
          child: Text(
            buttonText, // Display the button text
            style: bodyLargeTextStyle.copyWith(
              color: primaryColor, // Text color
              fontSize: textSize ?? 16, // Use textSize if provided, otherwise default to 16
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
