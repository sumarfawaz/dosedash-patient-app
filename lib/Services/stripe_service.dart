import 'package:DoseDash/Algorithms/GetUserLocation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
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

  // Create Payment Intent
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

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        print('Failed to create payment intent: ${response.body}');
        return null;
      }
    } catch (err) {
      print('Error creating payment intent: $err');
      return null;
    }
  }

  // Initialize and Present Payment Sheet
  static Future<bool> initPaymentSheet(BuildContext context, String amount, String currency) async {
    try {
      final paymentIntent = await createPaymentIntent(amount, currency);

      if (paymentIntent == null) {
        print('Failed to create payment intent');
        return false;
      }

      // Initialize the Payment Sheet
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: paymentIntent['client_secret'],
          merchantDisplayName: 'Dose Dash',
          style: ThemeMode.light,
        ),
      );

      // Present the Payment Sheet
      await Stripe.instance.presentPaymentSheet();

      // If no exception, payment was successful
      return true;
    } catch (e) {
      if (e is StripeException) {
        print('Error from Stripe: ${e.error.localizedMessage}');
      } else {
        print('Unknown error: $e');
      }
      return false; // Payment failed
    }
  }
}
