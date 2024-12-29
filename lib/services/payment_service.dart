/*
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PaymentService{
  final String _secretKey = 'sk_test_51Q3h3zP0TUOqrBT5DRT5yKOps5PgU5UkYImyzd3FmVnY6o9Y6mGA6iIvHx5AExFb4kroF5gd52t4waMQPaQGg7eY00n4MkAWsb';
  final String _apiUrl = 'https://api.stripe.com/v1/payment_intents';
  Future<void> makePayment(int amount) async{
    try{
      final paymentIntentData = await _createPaymentIntent(amount);
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

  Future<Map<String, dynamic>> _createPaymentIntent(int amount)async{
    try{
      final response  = await http.post(
          Uri.parse(_apiUrl),
          headers: {
            'Authorization': 'bearer $_secretKey',
            'Content-Type': 'application/x-www/form-urlencoded',
          },
          body: {
            'amount': (amount * 100).toString(),
            'currency': 'usd',
          }
      );
      if(response.statusCode != 200){
        throw Exception('Error creating payment intent ${response.body}');
      }
      return json.decode(response.body);
    }catch(e){
      print('Error creating payment intent: $e');
      rethrow;
    }
  }
}*/
