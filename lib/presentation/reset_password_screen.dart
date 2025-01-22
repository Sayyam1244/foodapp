import 'package:flutter/material.dart';
import 'package:helloworld/services/auth_service.dart';
import 'package:helloworld/utils/app_validator.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({Key? key}) : super(key: key);

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final emailController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF517F03), // Green background
      appBar: AppBar(
        title: const Text(
          "Reset Password",
          style: TextStyle(color: Color(0xFFFFF4E2)), // Beige color for text
        ),
        backgroundColor: const Color(0xFF517F03), // Match the background color
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // Navigate back
          },
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Enter your email to reset password:",
                  style: TextStyle(
                    fontSize: 18,
                    color: Color(0xFFFFF4E2), // Beige color for text
                  ),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: emailController,
                  validator: AppValidator.emptyCheck,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: const Color(0xFFFFF4E2), // Beige background
                    border: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(30.0), // Rounded corners
                      borderSide: BorderSide.none, // No border line
                    ),
                    hintText: "example@example.com",
                  ),
                ),
                const SizedBox(height: 30), // Space below email input
                Center(
                  child: ElevatedButton(
                    onPressed: () async {
                      if (!formKey.currentState!.validate()) {
                        return;
                      }

                      await AuthService.resetPass(emailController.text);
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: const Text("Reset Link Sent"),
                            content: const Text(
                                "A password reset link has been sent to your email."),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: const Text("OK"),
                              ),
                            ],
                          );
                        },
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          const Color(0xFFAECE77), // Darker Green button color
                      foregroundColor: Colors.white, // Text color
                      padding: const EdgeInsets.symmetric(
                          horizontal: 50, vertical: 15),
                    ),
                    child: const Text(
                      "Send Reset Link",
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                ),
                const SizedBox(height: 20), // Space below button
              ],
            ),
          ),
        ),
      ),
    );
  }
}
