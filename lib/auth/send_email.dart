import 'package:http/http.dart' as http;
import 'dart:convert';

Future<void> sendEmail(String toEmail, String subject, String body) async {
  final apiKey = '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'; // Aquí va tu API Key
  final url = Uri.parse('https://api.sendgrid.com/v3/mail/send');

  final headers = {
    'Authorization': 'Bearer $apiKey',
    'Content-Type': 'application/json',
  };

  final body = json.encode({
    'personalizations': [
      {
        'to': [
          {'email': toEmail},
        ],
        'subject': subject,
      },
    ],
    'from': {'email': 'rjalonso1003@gmail.com'}, // Aquí tu correo verificado de SendGrid
    'content': [
      {
        'type': 'text/plain',
        //'value': body,
      },
    ],
  });

  try {
    final response = await http.post(url, headers: headers, body: body);

    if (response.statusCode == 202) {
      print('Email sent successfully');
    } else {
      print('Failed to send email: ${response.body}');
    }
  } catch (e) {
    print('Error sending email: $e');
  }
}