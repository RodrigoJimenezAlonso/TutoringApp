import 'package:flutter/material.dart';
import 'package:proyecto_rr_principal/auth/login_page.dart';
import 'package:proyecto_rr_principal/mysql.dart';
import 'package:flutter_neat_and_clean_calendar/flutter_neat_and_clean_calendar.dart';

class TeacherProfileScreenPersonal extends StatefulWidget {
  final int userId;

  TeacherProfileScreenPersonal({required this.userId});

  @override
  _TeacherProfileScreenPersonalState createState() =>
      _TeacherProfileScreenPersonalState();
}

class _TeacherProfileScreenPersonalState
    extends State<TeacherProfileScreenPersonal> {
  Map<DateTime, List<NeatCleanCalendarEvent>> _events = {};

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    final conn = await MySQLHelper.connect();
    final result = await conn.query(
      '''
      SELECT title, description, start_time, end_time
      FROM events
      WHERE user_id = ?
      ''',
      [widget.userId],
    );
    await conn.close();

    Map<DateTime, List<NeatCleanCalendarEvent>> events = {};
    for (var row in result) {
      DateTime startTime = DateTime.parse(row['start_time']);
      DateTime endTime = DateTime.parse(row['end_time']);

      NeatCleanCalendarEvent event = NeatCleanCalendarEvent(
        row['title'],
        description: row['description'],
        startTime: startTime,
        endTime: endTime,
        color: Colors.blue,
      );

      DateTime eventDate =
      DateTime(startTime.year, startTime.month, startTime.day);
      if (!events.containsKey(eventDate)) {
        events[eventDate] = [];
      }
      events[eventDate]!.add(event);
    }

    setState(() {
      _events = events;
    });
  }

  void _logOut(BuildContext context) async {
    final conn = await MySQLHelper.connect();
    await conn.close();

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => LoginPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Teacher Profile'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () => _logOut(context),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Your Events',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Calendar(
              startOnMonday: true,
              weekDays: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'],
              eventsList: _events.entries
              .expand((entry)=>entry.value).toList(),
              isExpandable: true,
              eventDoneColor: Colors.green,
              selectedColor: Colors.purple,
              todayColor: Colors.red,
              eventColor: Colors.grey,
              locale: 'en_US',
              todayButtonText: 'Today',
              expandableDateFormat: 'EEEE, dd MMMM yyyy',
              onEventSelected: (event) {
                _showEventDetails(context, event);
              },
            ),
          ),

        ],
      ),
    );
  }

  void _showEventDetails(BuildContext context, NeatCleanCalendarEvent event) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(event.summary),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Description: ${event.description ?? "No description"}'),
              SizedBox(height: 8),
              Text(
                  'Time: ${event.startTime.hour}:${event.startTime.minute} - ${event.endTime.hour}:${event.endTime.minute}'),
            ],
          ),
          actions: [
            TextButton(
              child: Text('Close'),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        );
      },
    );
  }
}


class EventReservationScreen extends StatelessWidget{
  final DateTime selectedDay;
  EventReservationScreen(this.selectedDay);



  @override
  Widget build(BuildContext context){
    return Scaffold(
        appBar: AppBar(
          title: Text('Book Event'),
        ),
        body: Center(
            child: Text('Book event for: $selectedDay'),

        ),

    );
  }
}