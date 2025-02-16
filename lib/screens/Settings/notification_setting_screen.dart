import 'package:flutter/material.dart';

class NotificationSettingsScreen extends StatefulWidget {
  @override
  _NotificationSettingsScreenState createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends State<NotificationSettingsScreen> {
  bool classReminders = true;
  bool newMessages = true;
  bool promotionalEmails = false;
  bool appUpdates = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text("Notification Settings", style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.grey[100],
        elevation: 1,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionTitle("Push Notifications"),
            SizedBox(height: 10),
            _buildNotificationTile("Class Reminders", classReminders, (value) {
              setState(() => classReminders = value);
            }),
            _buildNotificationTile("New Messages", newMessages, (value) {
              setState(() => newMessages = value);
            }),

            Divider(height: 40),

            _sectionTitle("Email Notifications"),
            SizedBox(height: 10),
            _buildNotificationTile("Promotional Emails", promotionalEmails, (value) {
              setState(() => promotionalEmails = value);
            }),
            _buildNotificationTile("App Updates", appUpdates, (value) {
              setState(() => appUpdates = value);
            }),

            SizedBox(height: 20),

            _saveSettingsButton(),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildNotificationTile(String title, bool value, Function(bool) onChanged) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
            Transform.scale(
              scale: 0.8, // Adjusts switch size
              child: Switch(
                value: value,
                onChanged: onChanged,
                activeColor: Colors.white,
                activeTrackColor: Colors.blue,
                inactiveTrackColor: Colors.grey[300],
                inactiveThumbColor: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _saveSettingsButton() {
    return ElevatedButton(
      onPressed: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Notification settings updated!")),
        );
      },
      child: Text("Save Settings", style: TextStyle(fontSize: 16, color: Colors.white)),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blueAccent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        minimumSize: Size(double.infinity, 50),
      ),
    );
  }
}
