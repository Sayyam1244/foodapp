import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:helloworld/utils/textstyles.dart';

class CustomTextField extends StatelessWidget {
  const CustomTextField({
    super.key,
    required this.controller,
    required this.hintText,
    this.labelText,
    this.validator,
    this.obscureText = false,
    this.suffixIcon,
    this.prefixIcon,
    this.inputFormatters,
    this.onChanged,
  });

  final TextEditingController? controller;
  final String? hintText;
  final String? labelText;
  final String? Function(String?)? validator;
  final bool obscureText;
  final Widget? suffixIcon;
  final Widget? prefixIcon; // Added prefixIcon
  final List<TextInputFormatter>? inputFormatters;
  final void Function(String)? onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (labelText != null) ...[
          Text(labelText!, style: bodyLargeTextStyle),
          const SizedBox(height: 10),
        ],
        TextFormField(
          validator: validator,
          controller: controller,
          obscureText: obscureText,
          inputFormatters: inputFormatters,
          onChanged: onChanged,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.grey.shade100,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4.0),
              borderSide: BorderSide.none,
            ),
            hintText: hintText,
            suffixIcon: suffixIcon,
            prefixIcon: prefixIcon, // Added prefixIcon to InputDecoration
          ),
        ),
      ],
    );
  }
}
