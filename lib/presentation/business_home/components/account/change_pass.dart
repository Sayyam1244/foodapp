import 'package:flutter/material.dart';
import 'package:helloworld/presentation/common/custom_textfield.dart';
import 'package:helloworld/presentation/common/primary_button.dart';
import 'package:helloworld/services/auth_service.dart';
import 'package:helloworld/utils/app_validator.dart';
import 'package:helloworld/utils/colors.dart';
import 'package:helloworld/utils/textstyles.dart';

class ChangePassScreen extends StatefulWidget {
  const ChangePassScreen({Key? key}) : super(key: key);

  @override
  State<ChangePassScreen> createState() => _ChangePassScreenState();
}

class _ChangePassScreenState extends State<ChangePassScreen> {
  // Controller for the new password input field
  final newPasswordController = TextEditingController();

  // Form key to validate the form
  final formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteColor, // Set background color
      appBar: AppBar(
        backgroundColor: Colors.transparent, // Transparent app bar
        title: Text(
          "Change Password",
          style: headlineTextStyle.copyWith(color: primaryColor), // App bar title style
        ),
        centerTitle: true, // Center the title
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0), // Add padding around the form
          child: Form(
            key: formKey, // Attach form key
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20), // Add spacing
                CustomTextField(
                  labelText: 'New Password:', // Label for the text field
                  controller: newPasswordController, // Attach controller
                  hintText: 'Enter new password', // Placeholder text
                  validator: AppValidator.passwordCheck, // Password validation
                  obscureText: true, // Hide password input
                ),
                const SizedBox(height: 30), // Add spacing
                Center(
                  child: PrimaryButton(
                    buttonText: 'Change Password', // Button text
                    onTap: () async {
                      // Validate form
                      if (!formKey.currentState!.validate()) {
                        return;
                      }

                      // Call change password service
                      final val = await AuthService.changePassword(
                        newPasswordController.text,
                      );

                      if (val == true) {
                        // Show success message
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Password changed successfully"),
                          ),
                        );
                        Navigator.pop(context); // Navigate back
                      } else {
                        // Show error dialog
                        showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: const Text("Failed to change password"),
                              content: Text(val.toString()), // Display error message
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context); // Close dialog
                                  },
                                  child: const Text("OK"),
                                ),
                              ],
                            );
                          },
                        );
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
