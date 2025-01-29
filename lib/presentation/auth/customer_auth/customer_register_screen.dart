import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:helloworld/presentation/customer_home/customer_home.dart';
import 'package:helloworld/services/auth_service.dart';
import 'package:helloworld/utils/app_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CustomerRegisterScreen extends StatefulWidget {
  const CustomerRegisterScreen({Key? key}) : super(key: key);

  @override
  State<CustomerRegisterScreen> createState() => _CustomerRegisterScreenState();
}

class _CustomerRegisterScreenState extends State<CustomerRegisterScreen> {
  final customerName = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final phoneNumbercontroller = TextEditingController();
  final formKey = GlobalKey<FormState>();
  final passRulesList = [
    "• Password must contain at least one letter",
    "• Password must contain at least one number",
    "• Password must be longer than 8 characters",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF517F03), // Green background
      appBar: AppBar(
        title: const Text(
          "Customer Register",
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
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  const Text(
                    "Name:",
                    style: TextStyle(
                      fontSize: 18,
                      color: Color(0xFFFFF4E2), // Beige color for text
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: customerName,
                    validator: AppValidator.emptyCheck,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: const Color(0xFFFFF4E2), // Beige background
                      border: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(30.0), // Rounded corners
                        borderSide: BorderSide.none, // No border line
                      ),
                      hintText: "Enter your name",
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "Email:",
                    style: TextStyle(
                      fontSize: 18,
                      color: Color(0xFFFFF4E2), // Beige color for text
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: emailController,
                    validator: AppValidator.emailCheck,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: const Color(0xFFFFF4E2), // Beige background
                      border: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(30.0), // Rounded corners
                        borderSide: BorderSide.none, // No border line
                      ),
                      hintText: "Enter your email",
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "Phone Number:",
                    style: TextStyle(
                      fontSize: 18,
                      color: Color(0xFFFFF4E2), // Beige color for text
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    controller: phoneNumbercontroller,
                    validator: AppValidator.phoneCheck,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: const Color(0xFFFFF4E2), // Beige background
                      border: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(30.0), // Rounded corners
                        borderSide: BorderSide.none, // No border line
                      ),
                      hintText: "Enter your Phone Number",
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "Password:",
                    style: TextStyle(
                      fontSize: 18,
                      color: Color(0xFFFFF4E2), // Beige color for text
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: passwordController,
                    obscureText: true,
                    validator: AppValidator.passwordCheck,
                    decoration: InputDecoration(
                      errorMaxLines: 3,
                      filled: true,
                      fillColor: const Color(0xFFFFF4E2), // Beige background
                      border: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(30.0), // Rounded corners
                        borderSide: BorderSide.none, // No border line
                      ),
                      hintText: "Enter your password",
                    ),
                  ),
                  const SizedBox(height: 10),
                  ...passRulesList.map(
                    (e) => Text(
                      e,
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),

                  // const Text(
                  //   'Password must contain at least one letter and one number, and be longer than 8 characters',
                  //   maxLines: 3,
                  // ),
                  const SizedBox(height: 30),
                  Center(
                    child: ElevatedButton(
                      onPressed: () async {
                        if (!formKey.currentState!.validate()) {
                          return;
                        }
                        final val = await AuthService.signUpWithEmailPassword(
                          phoneNumber: phoneNumbercontroller.text,
                          email: emailController.text,
                          password: passwordController.text,
                          name: customerName.text,
                          role: "customer",
                        );
                        if (val is User) {
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const CustomerHomeScreen(),
                            ),
                            (route) => false,
                          );
                        } else {
                          showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: const Text("Failed to register"),
                                content: Text(val),
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
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(
                            0xFFAECE77), // Darker Green register button color
                        foregroundColor: Colors.white, // Text color
                        padding: const EdgeInsets.symmetric(
                            horizontal: 50, vertical: 15),
                      ),
                      child: const Text(
                        "Register",
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20), // Space below the button
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
