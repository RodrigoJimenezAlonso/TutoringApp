import 'package:flutter/material.dart';
import 'package:proyecto_rr_principal/screens/Settings/contact_support_screen.dart';
import 'package:provider/provider.dart';
import 'package:proyecto_rr_principal/screens/Settings/settings.dart';

class HelpFAQScreen extends StatelessWidget {
  final List<Map<String, String>> faqs = [
    {
      "question": "How do I find a tutor?",
      "answer": "You can search for a tutor using the search bar on the home screen or explore categories."
    },
    {
      "question": "How can I book a session?",
      "answer": "To book a session, select a tutor, choose an available time slot, and complete the payment process."
    },
    {
      "question": "Can I cancel or reschedule a session?",
      "answer": "Yes, you can cancel or reschedule a session from the 'My Sessions' section at least 24 hours in advance."
    },
    {
      "question": "What payment methods do you accept?",
      "answer": "We accept GooglePay, ApplePay, AmazonPay and PayPal."
    },
    {
      "question": "How can I contact support?",
      "answer": "You can reach us through the 'Support' section in the app or email us at support@tutorfinder.com."
    },
    {
      "question": "Do I need to create an account?",
      "answer": "Yes, creating an account is required to book sessions and track your progress."
    },
    {
      "question": "Are the tutors verified?",
      "answer": "Yes, all tutors go through a verification process to ensure quality and security."
    },
  ];

  @override
  Widget build(BuildContext context) {
    final SettingsProvider themeProvider = Provider.of<SettingsProvider>(context, listen: false);
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text("Help & FAQs", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
              child: ListView.builder(
                itemCount: faqs.length,
                itemBuilder: (context, index) {
                  final faq = faqs[index];
                  return Card(
                    elevation: 1,
                    margin: EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Theme(
                      data: Theme.of(context).copyWith(
                        dividerColor: Colors.transparent, // Hide default divider
                      ),
                      child: ExpansionTile(
                        iconColor: Colors.blueAccent,
                        collapsedIconColor: Colors.grey[600],
                        title: Text(
                          faq["question"]!,
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: themeProvider.isDarkMode == true ? Colors.white : Colors.black87),
                        ),
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
                            child: Text(
                              faq["answer"]!,
                              style: TextStyle(fontSize: 14, color: themeProvider.isDarkMode == true ? Colors.grey[100] : Colors.grey[800], height: 1.4),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          Divider(height: 1, color: Colors.grey[300]), // Soft separation line

          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Text(
                  "Can't find your answer?",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87),
                ),
                SizedBox(height: 6),
                Text(
                  "Reach out to our support team for further assistance.",
                  style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ContactSupportScreen()), // Correct navigation
                    );
                  }, // This can be connected to support later
                  icon: Icon(Icons.headset_mic, color: Colors.white),
                  label: Text("Contact Support", style: TextStyle(fontSize: 16, color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                ),
                SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
