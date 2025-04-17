// sk_test_51R6Z3nBGD7AXTYNzs16tMD4Fn5I9LrsJ1gPZhmnKjGI5IJulccagHhIxAbWVdJOR52JchQAiOh3GDZ6rVhAHeHbo00lhBRRKim
// pk_test_51R6Z3nBGD7AXTYNznwAcY7cYzxlqtOG2ioqeZPn5KeJhNjPmXYjD5luqnzne1OSjTqLfhkXnrqd12VLdsx6wN3nZ0014A6z9Yg
import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:helloworld/main.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_stripe/flutter_stripe.dart';

class StripeService {
  static String secretKey =
      'sk_test_51R6Z3nBGD7AXTYNzs16tMD4Fn5I9LrsJ1gPZhmnKjGI5IJulccagHhIxAbWVdJOR52JchQAiOh3GDZ6rVhAHeHbo00lhBRRKim';
  static String publishableKey =
      'pk_test_51R6Z3nBGD7AXTYNznwAcY7cYzxlqtOG2ioqeZPn5KeJhNjPmXYjD5luqnzne1OSjTqLfhkXnrqd12VLdsx6wN3nZ0014A6z9Yg';
  StripeService._();

  static final StripeService _instance = StripeService._();

  static StripeService get instance => _instance;
  static final headers = {
    'Authorization': 'Bearer $secretKey',
    'Content-Type': 'application/x-www-form-urlencoded',
    "Stripe-Version": '2023-10-16',
  };

  Future<Map<String, dynamic>> _createPaymentIntents(String amount) async {
    const String url = 'https://api.stripe.com/v1/payment_intents';
    var response = await http.post(Uri.parse(url), headers: headers, body: {
      'amount': _calculateAmount(amount),
      'currency': 'SAR',
      'payment_method_types[]': 'card',
    });
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      String error = json.decode(response.body)['error']['message'];
      throw Exception(error);
    }
  }

  Future<void> payment(
    String amount, {
    Function(String)? onSuccess,
    Function()? onCancelled,
  }) async {
    await _initializeStripe();

    try {
      var paymentIntent = await _createPaymentIntents(amount);

      await _presentPaymentSheet(
        paymentIntent['client_secret'],
      );

      onSuccess?.call(paymentIntent['id']);
    } on StripeException catch (e) {
      onCancelled?.call();
      _handleStripeError(e);
    } catch (e) {
      onCancelled?.call();
      _handleOtherErrors(e);
    }
  }

  Future<void> _initializeStripe() async {
    Stripe.publishableKey = publishableKey;
    await Stripe.instance.applySettings();
  }

  String _calculateAmount(String amount) {
    final a = (double.parse(amount)) * 100;
    return a.toInt().toString();
  }

  void _handleStripeError(StripeException error) {
    ScaffoldMessenger.of(navigatorKey.currentContext!).showSnackBar(
      SnackBar(
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.only(bottom: 10, left: 10, right: 10),
          content: Text(
            error.error.localizedMessage ?? '',
          )),
    );
    log('StripeException occurred: ${error.error.localizedMessage}');
    // Handle Stripe exceptions (e.g., display an error message)
  }

  void _handleOtherErrors(error) {
    String data = error.toString();
    data = data.replaceAll('Exception: ', '');
    // showToast(data);
    ScaffoldMessenger.of(navigatorKey.currentContext!).showSnackBar(
      SnackBar(
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.only(bottom: 10, left: 10, right: 10),
          content: Text(' $data')),
    );
    log('An error occurred: $error');
    // Handle other types of exceptions (e.g., network errors, JSON parse errors)
  }

  Future<void> _presentPaymentSheet(
    String paymentIntentClientSecret,
  ) async {
    await Stripe.instance.initPaymentSheet(
      paymentSheetParameters: SetupPaymentSheetParameters(
        merchantDisplayName: 'Food saver',
        paymentIntentClientSecret: paymentIntentClientSecret,
      ),
    );

    await Stripe.instance.presentPaymentSheet();
  }
}
