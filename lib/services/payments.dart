import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;
import 'package:stash_app/config.dart';
import 'package:stash_app/store.dart';

Future<String> paymentsCreateIntent(String token, int tier) async {
  var response = await http.get(
    Uri.parse('${config['backend_url']}/api/stripe/intent?tier=$tier'),
    headers: {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token"
    },
  );

  if (response.statusCode != 200) {
    throw Exception("${response.statusCode} ${response.body}");
  }

  var body = jsonDecode(utf8.decode(response.bodyBytes));
  var clientSecret = body['clientSecret'];

  return clientSecret;
}

Future<void> startSubscriptionPayment(User user, int tier) async {
  final data = await paymentsCreateIntent(user.token, tier);

  await Stripe.instance.initPaymentSheet(
    paymentSheetParameters: SetupPaymentSheetParameters(
      customFlow: false,
      merchantDisplayName: 'Stash',
      paymentIntentClientSecret: data,
      // Customer keys
      // customerEphemeralKeySecret: data['ephemeralKey'],
      // customerId: data['customer'],
      // Extra options
      // applePay: const PaymentSheetApplePay(
      //   merchantCountryCode: 'ES',
      // ),
      googlePay: const PaymentSheetGooglePay(
        merchantCountryCode: 'ES',
        testEnv: true,
      ),
      style: ThemeMode.dark,
    ),
  );

  await Stripe.instance.presentPaymentSheet();
}
