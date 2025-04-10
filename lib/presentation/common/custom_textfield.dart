import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:helloworld/utils/colors.dart';
import 'package:helloworld/utils/textstyles.dart';

// A custom reusable text field widget
class CustomTextField extends StatelessWidget {
  const CustomTextField({
    super.key,
    required this.controller, // Controller for text input
    required this.hintText, // Placeholder text
    this.labelText, // Optional label text
    this.validator, // Validation function
    this.obscureText = false, // Hides text for passwords
    this.suffixIcon, // Icon at the end of the text field
    this.prefixIcon, // Icon at the start of the text field
    this.inputFormatters, // Input format restrictions
    this.onChanged, // Callback for text changes
    this.keyboardType, // Keyboard type (e.g., text, number)
  });

  final TextEditingController? controller;
  final String? hintText;
  final String? labelText;
  final String? Function(String?)? validator;
  final bool obscureText;
  final Widget? suffixIcon;
  final Widget? prefixIcon;
  final List<TextInputFormatter>? inputFormatters;
  final void Function(String)? onChanged;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start, // Aligns children to the start
      children: [
        if (labelText != null) ...[
          // Displays label text if provided
          Text(labelText!,
              style: bodyLargeTextStyle.copyWith(
                color: greyColor, // Label text color
              )),
          const SizedBox(height: 10), // Adds spacing below the label
        ],
        TextFormField(
          validator: validator, // Applies validation logic
          controller: controller, // Binds text input to the controller
          obscureText: obscureText, // Toggles text visibility
          inputFormatters: inputFormatters, // Applies input restrictions
          onChanged: onChanged, // Triggers on text change
          keyboardType: keyboardType, // Sets keyboard type
          decoration: InputDecoration(
            errorMaxLines: 3,
            filled: true, // Enables background fill
            fillColor: Colors.grey.shade100, // Background color
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4.0), // Rounded corners
              borderSide: BorderSide.none, // No border
            ),
            hintText: hintText, // Placeholder text
            suffixIcon: suffixIcon, // Adds suffix icon
            prefixIcon: prefixIcon, // Adds prefix icon
          ),
        ),
      ],
    );
  }
}
