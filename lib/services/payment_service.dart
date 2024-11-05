import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PaymentService{
  final String _apiUrl = 'https://api.stripe.com';
  Future<void> makePayment(int amount) async{
    try{
      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {
          'contentType': 'application/json'
        },
        body: json.encode({
          'amount': amount
        }),
      );
      if(response.statusCode != 200){
        throw Exception('Failed to make payment: ${response.body}');
      }

      final paymentIntentData = json.decode(response.body);
      await Stripe.instance.initPaymentSheet(
          paymentSheetParameters: SetupPaymentSheetParameters(
            paymentIntentClientSecret: paymentIntentData['client_secret'],
              merchantDisplayName: 'My App',
              style: ThemeMode.light,
          )
      );

      await Stripe.instance.presentPaymentSheet();
      print('payment successfully made');
    }catch(e){
      print('error: $e');
    }
}
}