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
  final List<String> subjects = [
    'Mathematics',
    'English Language and Literature',
    'Science',
    'History',
    'Geography',
    'Physical Education (P.E.)',
    'Biology',
    'Chemistry',
    'Physics',
    'Art and Design',
    'Music',
    'Information and Communication Technology (ICT)',
    'Business Studies',
    'Foreign Languages',
    'Religious Education (R.E.)',
  ];

  TextEditingController bioController = TextEditingController();
  String? selectedSubject;

  Future<void> _loadTeacherInfo()async{
    final conn = await MySQLHelper.connect();
    var result = await conn.query(
      'SELECT subject, bio FROM teachers WHERE id = (SELECT teacher_id FROM users WHERE id = ?)',
      [widget.userId],
    );
    await conn.close();
    if(result.isNotEmpty){
      setState(() {
        selectedSubject = result.first['subject'];
        bioController.text = result.first['bio'] ?? '';
      });
    }

  }

  Future<void> _updateTeacherInfo()async{

    if(selectedSubject == null || bioController.text.isEmpty){
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please Select a Subject and type your Bio!'))
      );
      return;
    }

    try{
      final conn = await MySQLHelper.connect();
      var result = await conn.query(
        'UPDATE teachers SET subject = ?, bio = ? WHERE id = (SELECT teacher_id FROM users WHERE id = ?)',
        [selectedSubject, bioController.text, widget.userId],
      );
      await conn.close();
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Profile updated successfully'))
      );
    }catch(e){
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating the profile${e.toString()}'))
      );
    }

  }


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
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Update profile',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 10,),
                  DropdownButtonFormField<String>(
                      value: selectedSubject,
                      decoration: InputDecoration(
                        labelText: 'Subject',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      items: subjects.map((subject){
                        return DropdownMenuItem(
                          child: Text(subject),
                          value: subject,
                        );
                      }).toList(),
                      onChanged: (value){
                        setState(() {
                          selectedSubject = value!;
                        });
                      }
                  ),
                  SizedBox(height: 20),
                  TextFormField(
                    controller: bioController,
                    maxLines: 4,
                    decoration: InputDecoration(
                      labelText: 'Biography',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                      onPressed: _updateTeacherInfo,
                      child: Text('Save changes'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
                padding: const EdgeInsets.all(16.0),
              child: Text(
                'Your Events',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),

            ),
            SizedBox(
              height: 500,
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