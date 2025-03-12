import 'package:flutter/material.dart';

import 'dead_end_screen.dart';

class ContactSupportScreen extends StatefulWidget {
  @override
  _ContactSupportScreenState createState() => _ContactSupportScreenState();
}

class _ContactSupportScreenState extends State<ContactSupportScreen> {
  final TextEditingController _messageController = TextEditingController();

  // Simulated chat messages
  List<Map<String, String>> messages = [
    {"sender": "support", "text": "Hi! How can we assist you today? 😊"},
    {"sender": "user", "text": "I have a question about booking a tutor."},
    {"sender": "support", "text": "Sure! What would you like to know?"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Contact Support", style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final message = messages[index];
                bool isUser = message["sender"] == "user";

                return Align(
                  alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 14),
                    margin: EdgeInsets.symmetric(vertical: 5),
                    decoration: BoxDecoration(
                      color: isUser ? Colors.blueAccent : Colors.grey[300],
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      message["text"]!,
                      style: TextStyle(
                        color: isUser ? Colors.white : Colors.black87,
                        fontSize: 14,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          Divider(height: 1, color: Colors.grey[300]),

          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: "Type a message...",
                      hintStyle: TextStyle(color: Colors.grey[600]),
                      filled: true,
                      fillColor: Colors.grey[100],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                FloatingActionButton(
                  onPressed: () {
                    // Fake sending effect
                    if (_messageController.text.isNotEmpty) {
                      setState(() {
                        messages.add({"sender": "user", "text": _messageController.text});
                        _messageController.clear();
                      });
                    }
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => DeadEndScreen()),
                    );
                  },
                  backgroundColor: Colors.blueAccent,
                  child: Icon(Icons.send, color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
