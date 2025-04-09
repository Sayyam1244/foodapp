import 'package:flutter/material.dart';
import 'package:helloworld/services/auth_service.dart';
import 'package:helloworld/utils/app_validator.dart';
import 'package:helloworld/utils/colors.dart';
import 'package:helloworld/utils/textstyles.dart';
import 'package:helloworld/presentation/common/custom_textfield.dart';
import 'package:helloworld/presentation/common/primary_button.dart';

// Screen for resetting the password
class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({Key? key}) : super(key: key);

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  // Controller for email input field
  final emailController = TextEditingController();

  // Key for form validation
  final formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteColor, // Background color of the screen
      appBar: AppBar(
        backgroundColor: Colors.transparent, // Transparent app bar
        title: Text(
          "Reset Password",
          style: headlineTextStyle.copyWith(color: primaryColor), // Title style
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: primaryColor), // Back button
          onPressed: () {
            Navigator.pop(context); // Navigate back
          },
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0), // Padding around the content
          child: Form(
            key: formKey, // Form key for validation
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Instruction text
                Text(
                  "Enter your email to reset password:",
                  style: bodyLargeTextStyle.copyWith(color: primaryColor),
                ),
                const SizedBox(height: 20), // Spacing
                // Email input field
                CustomTextField(
                  labelText: 'Email',
                  controller: emailController,
                  hintText: 'example@example.com',
                  validator: AppValidator.emailCheck, // Email validation
                ),
                const SizedBox(height: 30), // Spacing
                // Button to send reset link
                Center(
                  child: PrimaryButton(
                    buttonText: "Send Reset Link",
                    onTap: () async {
                      // Validate form
                      if (!formKey.currentState!.validate()) {
                        return;
                      }

                      // Call reset password service
                      await AuthService.resetPass(emailController.text);

                      // Show confirmation dialog
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: const Text("Reset Link Sent"),
                            content: const Text("A password reset link has been sent to your email."),
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
