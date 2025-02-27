import 'package:flutter/material.dart';
import 'package:mysql1/mysql1.dart';
import 'package:proyecto_rr_principal/mysql.dart';
import 'package:flutter_neat_and_clean_calendar/flutter_neat_and_clean_calendar.dart';
import 'dart:typed_data';
import 'payment_page.dart';

class TeacherProfileScreen extends StatefulWidget {
  final int teacherId; //El professor
  final int studentId;

  TeacherProfileScreen({required this.teacherId, required this.studentId});

  @override
  _TeacherProfileScreenState createState() => _TeacherProfileScreenState();
}

class _TeacherProfileScreenState extends State<TeacherProfileScreen> {
  Map<DateTime, List<NeatCleanCalendarEvent>> _events = {};
  String name = '';
  String subject = '';
  String bio = '';
  String _name = "";
  String _email = "";
  Uint8List? imageBytes;
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    _loadTeacherInfo();
    _loadTeacherData();
    _loadEvents();
    _fetchAvailability();
  }

  Future<void> _loadTeacherInfo() async {
    final conn = await MySQLHelper.connect();
    final result = await conn.query(
        'SELECT name, subject, bio FROM teachers WHERE id = (SELECT teacher_id FROM users WHERE id = ?)',
        [widget.teacherId]);
    await conn.close();
    if (result.isNotEmpty) {
      setState(() {
        name = result.first['name'].toString();
        subject = result.first['subject'].toString();
        bio = result.first['bio']?.toString() ?? '';
      });
    }
  }

  Future<void> _loadTeacherData() async {
    try {
      final conn = await MySQLHelper.connect();
      final result = await conn.query(
        'SELECT username, email, profile_picture FROM users WHERE id = ?',
        [widget.teacherId],
      );

      if (result.isEmpty)
        throw Exception('No se encontró el estudiante con el ID dado');

      final data = result.first;
      setState(() {
        _name = data['username'] ?? '';
        _email = data['email'] ?? '';

        final blobData = data['profile_picture'];
        if (blobData != null && blobData is Blob) {
          imageBytes = Uint8List.fromList(blobData.toBytes());
        } else {
          imageBytes = null;
        }
      });
    } catch (e) {
      print('Error loading student data: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Error al cargar datos: $e'),
            backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _fetchAvailability() async {
    try {
      final conn = await MySQLHelper.connect();
      print('Conectando a la base de datos...');


      final result = await conn.query(
        '''
        SELECT * FROM events 
        WHERE user_id = ? AND status = "available"
        ORDER BY start_time
        ''',
        [widget.teacherId],
      );

      await conn.close();

      final events = <DateTime, List<NeatCleanCalendarEvent>>{};

      for (var row in result) {
        final startTime = row['start_time'] as DateTime;
        final endTime = row['end_time'] as DateTime;
        final availabilityId = row['id'];

        final event = NeatCleanCalendarEvent(
          'Available Slot',
          startTime: startTime,
          endTime: endTime,
          id: availabilityId.toString(),
          description: 'Click for details',
          color: Colors.blue,
        );

        final eventDate = DateTime(startTime.year, startTime.month, startTime.day);

        if (!events.containsKey(eventDate)) {
          events[eventDate] = [];
        }
        events[eventDate] = (events[eventDate] ?? [])..add(event);
      }

      print('Eventos cargados antes de setState: ${events.length}');

      setState(() {
        _events = events;
      });
    } catch (e) {
      print('Error al obtener la disponibilidad: $e');
    }
  }


  Future<void> _loadEvents() async {
    final conn = await MySQLHelper.connect();
    final result = await conn.query(
      'SELECT * FROM events WHERE user_id = ? AND status = "available"',
      [widget.teacherId],
    );
    print('RESULTTAdo consulta:  ${widget.teacherId}');
    await conn.close();

    Map<DateTime, List<NeatCleanCalendarEvent>> events = {};
    for (var row in result) {
      DateTime startTime = DateTime.parse(row['start_time'].toString());
      DateTime endTime = DateTime.parse(row['end_time'].toString());

      NeatCleanCalendarEvent event = NeatCleanCalendarEvent(
        row['title'].toString(),
        description: row['description']?.toString() ?? '',
        startTime: startTime,
        endTime: endTime,
        color: Colors.blue,
        id: row['id'].toString(),
      );

      DateTime eventDate = DateTime(startTime.year, startTime.month, startTime.day);
      events.putIfAbsent(eventDate, () => []).add(event);
    }

    setState(() {
      _events = events;
    });
  }

  Future<void> _bookClass(int availabilityId) async {
    try {
      final conn = await MySQLHelper.connect();
      await conn.query(
        'UPDATE events SET status = "pending" WHERE id = ?',
        [availabilityId],
      );
      await conn.close();

      print('Clase reservada correctamente');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Waiting for teacher to accept the event!'),
        ),
      );

      await _fetchAvailability();

      setState(() {});
    } catch (e) {
      print('Error al reservar la clase: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error Booking Class, please try again!'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        automaticallyImplyLeading: true,
        backgroundColor: Colors.grey[100],
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Teacher Profile',
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(children: [
              CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.blue[300],
                  backgroundImage: imageBytes != null
                      ? MemoryImage(imageBytes!)
                      : AssetImage('assets/images/profile_placeholder.png')),
              SizedBox(
                height: 10,
              ),
              Text(
                _name,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center, // Centra el texto
              ),
              SizedBox(
                height: 8,
              ),
              Text(
                _email,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[800],
                ),
                textAlign: TextAlign.center, // Centra el texto
              ),
              SizedBox(
                height: 8,
              ),
              Text(
                'Subject: $subject',
                style: TextStyle(
                  fontSize: 14,
                ),
                textAlign: TextAlign.center, // Centra el texto
              ),
              SizedBox(
                height: 8,
              ),
              Text(
                'Biography: $bio',
                style: TextStyle(
                  fontSize: 14,
                ),
                textAlign: TextAlign.center, // Centra el texto
              ),
            ]),
          ),
          SizedBox(
            height: 500,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Container(
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 10,
                        spreadRadius: 2,
                        offset: Offset(0, 4),
                      ),
                    ]),
                child: _events.isEmpty
                    ? Center(
                  child: CircularProgressIndicator(),
                )
                    : Calendar(
                  startOnMonday: true,
                  weekDays: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'],
                  eventsList:
                  _events.entries.expand((entry) => entry.value).toList(),
                  isExpandable: true,
                  eventDoneColor: Colors.green,
                  selectedColor: Colors.purple,
                  todayColor: Colors.red,
                  eventColor: Colors.grey,
                  locale: 'en_US',
                  todayButtonText: 'Today',
                  expandableDateFormat: 'EEEE, dd MMMM yyyy',
                  onEventSelected: (event) {
                    //print("Event selected: ${event.title}, description: ${event.description}");
                    final availabilityId = int.tryParse(event.id ?? '');
                    if (availabilityId != null) {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          backgroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16)),
                          title: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Meeting with ${name} for ${subject}',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                "Event Details",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildEventDetail(Icons.access_time, "Start Time",
                                  _formatDateTime(event.startTime)),
                              _buildEventDetail(Icons.access_time_filled, "End Time",
                                  _formatDateTime(event.endTime)),
                            ],
                          ),
                          actions: [
                            TextButton(
                              child: Text("Book Class",
                                  style: TextStyle(color: Colors.blue[800])),
                              onPressed: () {
                                paymentPage(context, int.parse(
                                  event.id.toString()
                                ), widget.studentId);

                              },
                            ),
                            TextButton(
                              child: Text("Close",
                                  style: TextStyle(color: Colors.red)),
                              onPressed: () {
                                Navigator.pop(context);
                              },
                            ),
                          ],
                        ),
                      );
                    }
                  },
                ),
              ),
            ),
          )
        ]),
      ),
    );
  }

  List<NeatCleanCalendarEvent> getSelectedDayEvents() {
    return _selectedDate != null ? _events[_selectedDate] ?? [] : [];
  }

  String? getEventId(NeatCleanCalendarEvent event) {
    if (event.id == null || event.id!.isEmpty) {
      print("El evento no tiene un ID asignado.");
      return null;
    }

    try {
      String eventId = event.id.toString();
      print("ID del evento seleccionado: $eventId");
      return eventId;
    } catch (e) {
      print("Error al obtener el ID del evento: $e");
      return null;
    }
  }

  Widget _buildEventDetail(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.blue[600]),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              "$label: $value",
              style: TextStyle(fontSize: 14, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return "${dateTime.day}/${dateTime.month}/${dateTime.year} - ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}";
  }
}