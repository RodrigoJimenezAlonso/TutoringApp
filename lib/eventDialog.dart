import 'package:flutter/material.dart';
import 'datePicker.dart';
import 'data.dart';

class EvtController extends StatefulWidget {
  @override
  _EvtControllerState createState() => _EvtControllerState();
}

class _EvtControllerState extends State<EvtController> {
  final Data _data = Data();
  List<Map<String, dynamic>> _events = [];

  @override
  void initState() {
    super.initState();
    _fetchEvents();
  }

  Future<void> _fetchEvents() async {
    try {
      final events = await _data.getAllEvents();
      setState(() {
        _events = events;
      });
    } catch (e) {
      print('Error fetching events: $e');
    }
  }

  Future<Map<String, dynamic>?> _showEventDialog(BuildContext context) async {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    DateTime? selectedDate;

    return showDialog<Map<String, dynamic>>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add New Event'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: titleController,
                  decoration: InputDecoration(labelText: 'Title'),
                ),
                TextField(
                  controller: descriptionController,
                  decoration: InputDecoration(labelText: 'Description'),
                ),
                SizedBox(height: 10),
                ElevatedButton(
                  child: Text('Select Date & Time'),
                  onPressed: () async {
                    selectedDate = await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => DatePicker()),
                    );
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: Text('Cancel'),
              onPressed: () => Navigator.pop(context, null),
            ),
            ElevatedButton(
              child: Text('Add'),
              onPressed: () {
                if (titleController.text.isNotEmpty &&
                    descriptionController.text.isNotEmpty &&
                    selectedDate != null) {
                  final newEvent = {
                    "id": DateTime.now().millisecondsSinceEpoch.toString(),
                    "title": titleController.text,
                    "description": descriptionController.text,
                    "startTime": selectedDate!.toIso8601String(),
                    "endTime": DateTime.now().toIso8601String(),
                  };
                  Navigator.pop(context, newEvent);
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          ElevatedButton(
            onPressed: () async {
              final newEvent = await _showEventDialog(context);
              if (newEvent != null) {
                await _data.addEvent(newEvent);
                _fetchEvents(); // Refresh the events list after adding a new event
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Event "${newEvent['title']}" added')),
                );
              }
            },
            child: Text('Create an Event'),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _events.length,
              itemBuilder: (context, index) {
                final event = _events[index];
                return ListTile(
                  title: Text(event['title']),
                  subtitle: Text(event['description']),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}