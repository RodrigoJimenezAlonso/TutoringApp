import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:proyecto_rr_principal/mysql.dart';

class ChatScreen extends StatefulWidget {
  final int alumnoId;
  final int profesorId;
  final String senderType;

  ChatScreen({
    required this.alumnoId,
    required this.profesorId,
    required this.senderType,
  });

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final messageController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: FutureBuilder<List<Map<String, dynamic>>>(
            future: _messageLoader(widget.alumnoId, widget.profesorId),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Center(child: CircularProgressIndicator());
              }

              final messages = snapshot.data;
              if (messages == null || messages.isEmpty) {
                return Center(child: Text('No messages'));
              }

              return ListView.builder(
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  final message = messages[index];
                  final senderId = message['sender_id'];
                  final recipientId = message['recipient_id'];
                  final senderName = message['sender_name'];
                  final text = message['text'];
                  final timeStamp = message['time_stamp'];

                  String formattedTimeStamp = formatDate(timeStamp);

                  final senderType = senderId == widget.alumnoId ? 'You' : 'Professor';

                  return ListTile(
                    title: Text(text),
                    subtitle: Text('$senderName ($senderType)'),
                    trailing: Text(formattedTimeStamp),
                  );
                },
              );
            },
          ),
        ),
        TextField(
          controller: messageController,
          decoration: InputDecoration(
            labelText: 'Type your message',
            suffixIcon: IconButton(
              icon: Icon(Icons.send),
              onPressed: () async {
                final message = messageController.text.trim();
                if (message.isNotEmpty) {
                  await _messageSender(
                    widget.alumnoId,
                    widget.profesorId,
                    message,
                    widget.senderType,
                  );
                  messageController.clear();

                  setState(() {});
                }
              },
            ),
          ),
        ),
      ],
    );
  }

  Future<List<Map<String, dynamic>>> _messageLoader(int alumnoId, int profesorId) async {
    final conn = await MySQLHelper.connect();
    final result = await conn.query(
      'SELECT * FROM messages WHERE (sender_id = ? AND recipient_id = ?) OR (sender_id = ? AND recipient_id = ?) ORDER BY time_stamp ASC',
      [
        alumnoId,
        profesorId,
        profesorId,
        alumnoId,
      ],
    );
    await conn.close();
    return result.map((row) => row.fields).toList();
  }

  Future<void> _messageSender(int senderId, int recipientId, String message, String senderType) async {
    final conn = await MySQLHelper.connect();
    final senderName = senderType == 'Student' ? 'Student' : 'Professor';
    await conn.query(
      'INSERT INTO messages(sender_id, recipient_id, sender_name, text, time_stamp, is_read) VALUES(?, ?, ?, ?, ?, ?)',
      [
        senderId,
        recipientId,
        senderName,
        message,
        DateTime.now().toIso8601String(),
        0,
      ],
    );
    await conn.close();
  }

  String formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}