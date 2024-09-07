import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart'; // Import flutter_stripe instead of stripe_flutter
import 'package:http/http.dart' as http;
import 'dart:convert';

class StripeService {
  static String apiBase = 'https://api.stripe.com/v1';
  static String paymentApiUrl = '${StripeService.apiBase}/payment_intents';
  static String secretKey = 'sk_test_51PnzGOENPvFTECCdECjj16VxYY1qrlyhMrXP4npcH6VoG4SdugN8u6V3CjbWS58GJHztFLDpvMfvwffMkVWGNvhz00eiejZvlv'; // Replace with your Stripe Secret Key

  static Map<String, String> headers = {
    'Authorization': 'Bearer $secretKey',
    'Content-Type': 'application/x-www-form-urlencoded'
  };

  static Future<Map<String, dynamic>?> createPaymentIntent(String amount, String currency) async {
    try {
      Map<String, dynamic> body = {
        'amount': amount,
        'currency': currency,
        'payment_method_types[]': 'card'
      };

      var response = await http.post(
        Uri.parse(paymentApiUrl),
        headers: headers,
        body: body,
      );

      return jsonDecode(response.body);
    } catch (err) {
      print('Error creating payment intent: $err');
      return null;
    }
  }

  static Future<void> initPaymentSheet(BuildContext context, String amount, String currency) async {
    try {
      final paymentIntent = await createPaymentIntent(amount, currency);

      if (paymentIntent == null) {
        print('Failed to create payment intent');
        return;
      }

      // Initialize the Payment Sheet with the paymentIntentClientSecret from the payment intent
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: paymentIntent['client_secret'], // Error could be related to this line if the response is incorrect.
          merchantDisplayName: 'Dose Dash', // Customize your merchant name here
          style: ThemeMode.light, // Choose between light and dark mode
         // merchantCountryCode: 'LK', // Correct country code for Sri Lanka is 'LK'
        ),
      );

      await Stripe.instance.presentPaymentSheet(); // Present the payment sheet to the user

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Payment Successful')));
    } catch (e) {
      if (e is StripeException) {
        print('Error from Stripe: ${e.error.localizedMessage}');
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Payment failed: ${e.error.localizedMessage}')));
      } else {
        print('Unknown error: $e');
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Payment failed')));
      }
    }
  }
}