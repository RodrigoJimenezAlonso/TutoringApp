import 'models/event.dart';
import 'package:flutter/material.dart';
import 'datePicker.dart';
import 'providers/event_provider.dart';
import 'package:provider/provider.dart';

class EventsController extends StatefulWidget {
  @override
  _EventsControllerState createState() => _EventsControllerState();
}

class _EventsControllerState extends State<EventsController> {
  late List<dynamic> events;

  @override
  void initState() {
    super.initState();
    //data = Data();
    //events = data.getAllEvents();
    Future.microtask(() => Provider.of<EventProvider>(context, listen: false).loadEvents());
  }

  @override
  Widget build(BuildContext context) {
    events = Provider.of<EventProvider>(context).events;
    return Scaffold(
      appBar: AppBar(
        title: Text('Events'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              // Navigate to DatePicker component
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => DatePicker()),
              ).then((selectedDate) {
                if (selectedDate != null) {
                  _showEventDialog(selectedDate);
                }
              });
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: events.length,
        itemBuilder: (context, index) {
          final event = events[index];
          return _buildEventCard(event);
        },
      ),
    );
  }

  Widget _buildEventCard(Map<String, dynamic> event) {
    return Card(
      margin: EdgeInsets.all(10),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              event['title'],
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            Text(
              event['description'],
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 10),
            _buildEventTimeRow(Icons.schedule, 'start: ${event['startTime']}'),
            SizedBox(height: 5),
            _buildEventTimeRow(Icons.schedule, 'end: ${event['endTime']}'),
            SizedBox(height: 10),
            _buildEventLocationRow(event['location']),
          ],
        ),
      ),
    );
  }

  Widget _buildEventTimeRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: Colors.grey,),
        SizedBox(width: 5),
        Text(
          text,
          style: TextStyle(color: Colors.grey[600]),
        ),
      ],
    );
  }

  Widget _buildEventLocationRow(String location) {
    return Row(
      children: [
        Icon(Icons.location_on, color: Colors.grey,),
        SizedBox(width: 5),
        Text(
          'location: $location',
          style: TextStyle(color: Colors.grey[600]),
        ),
      ],
    );
  }

  Future<void> _showEventDialog(DateTime selectedDate) async {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add New Event'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: InputDecoration(labelText: 'Title'),
              ),
              SizedBox(height: 10),
              TextField(
                controller: descriptionController,
                decoration: InputDecoration(labelText: 'Description'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              child: Text('Add'),
              onPressed: () {
                final newEvent = Event(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  title: titleController.text,
                  description: descriptionController.text,
                  startTime: selectedDate,
                  endTime: selectedDate.add(Duration(hours: 1)),
                );
                Provider.of<EventProvider>(context, listen: false).addEvent(newEvent);
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }
}
