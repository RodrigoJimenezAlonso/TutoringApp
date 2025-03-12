import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mysql1/mysql1.dart';
import 'package:provider/provider.dart';
import 'package:proyecto_rr_principal/mysql.dart';
import 'package:flutter_neat_and_clean_calendar/flutter_neat_and_clean_calendar.dart';
import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';
import 'package:proyecto_rr_principal/screens/NavigationBar/Profiles/teacherProfile/edit_teacher_profile_screen_personal.dart';
import 'package:proyecto_rr_principal/auth/login_page.dart';
import 'package:proyecto_rr_principal/screens/Settings/billing_details_screen.dart';
import 'package:proyecto_rr_principal/screens/Settings/help_faqs_screen.dart';
import 'package:proyecto_rr_principal/screens/Settings/notification_setting_screen.dart';
import 'package:proyecto_rr_principal/screens/Settings/settings.dart';
import 'package:proyecto_rr_principal/screens/NavigationBar/Events/event_automation.dart';
import 'package:proyecto_rr_principal/screens/Settings/settings.dart';


import '../../../../models/event.dart';


class TeacherProfileScreenPersonal extends StatefulWidget {
  final int userId;

  TeacherProfileScreenPersonal({required this.userId});

  @override
  _TeacherProfileScreenPersonalState createState() => _TeacherProfileScreenPersonalState();
}

class _TeacherProfileScreenPersonalState extends State<TeacherProfileScreenPersonal> {
  Map<DateTime, List<NeatCleanCalendarEvent>> _events = {};
  String name = '';
  String subject = '';
  String bio = '';
  String _name = "";
  String _email = "";
  String studentName = "";
  int eventId = 0;
  int studentId = 0;
  Uint8List? imageBytes;
  final ImagePicker _picker = ImagePicker();
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    _loadTeacherInfo();
    _loadTeacherData();
    _loadEvents();
  }

  Future<void> _loadTeacherInfo()async{
    final conn = await MySQLHelper.connect();
    final result = await conn.query(
        'SELECT name, subject, bio FROM teachers WHERE id = (SELECT teacher_id FROM users WHERE id = ?)',
        [
          widget.userId
        ]
    );
    await conn.close();
    if(result.isNotEmpty){
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
        [widget.userId],
      );

      if (result.isEmpty) throw Exception('No se encontró el estudiante con el ID dado');

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
        SnackBar(content: Text('Error al cargar datos: $e'), backgroundColor: Colors.red),
      );
    }
  }

  Color _getEventColor(String status){
    switch(status){
      case 'available':
        return Colors.green;
      case 'not_available':
        return Colors.red;
      case 'pending':
        return Colors.orange;
      case 'accepted':
        return Colors.blue;
      default:
        return Colors.purple;
    }
  }

  void _showChangeStatusDialog(String eventId, String currentState){
    showDialog(
        context: context,
        builder: (context){
          String selectedStatus = currentState;
          return AlertDialog(
            title: Text('Change event status'),
            content: DropdownButton<String>(
                value: selectedStatus,
                onChanged: (String? newValue){
                  if(newValue != null){
                    setState(() {
                      selectedStatus = newValue;
                    });
                  }
                },
                items: ['available', 'not_available', 'pending', 'accepted']
                  .map((status)=> DropdownMenuItem(child: Text(status), value: status)).toList(),
            ),
            actions: [
              TextButton(
                  onPressed: ()=> Navigator.pop(context),
                  child: Text('Cancel'),
              ),
              ElevatedButton(
                  onPressed: ()async{
                    final conn = await MySQLHelper.connect();
                    await conn.query(
                      'UPDATE events SET status = ? WHERE id = ?',
                      [
                        selectedStatus, eventId
                      ]
                    );
                    await conn.close();
                    _loadEvents();
                    Navigator.pop(context);
                  },
                  child: Text('Save'),
              )
            ],
          );
        }
    );
  }

  Future<void> _loadEvents() async {
    final conn = await MySQLHelper.connect();
    final result = await conn.query(
      'SELECT id, title, description, start_time, end_time, status FROM events WHERE user_id = ?',
      [widget.userId],
    );

    final resultAvailability = await conn.query(
      '''
      SELECT date, start_time, end_time, status 
      FROM availability a INNER JOIN users u ON a.teacher_id = u.teacher_id 
      WHERE u.id = ? AND a.status = "available"
      ORDER BY a.date, a.start_time
      ''',
      [
        widget.userId
      ]
    );

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
        color: _getEventColor(row['status'].toString()),
        id: row['id'].toString(),
      );

      DateTime eventDate = DateTime(startTime.year, startTime.month, startTime.day);
      events.putIfAbsent(eventDate, () => []).add(event);
    }

    for (var row in resultAvailability) {
      DateTime date = DateTime.parse(row['date'].toString());
      TimeOfDay startTime = TimeOfDay(
          hour: int.parse(row['start_time'].toString().split(":")[0]),
          minute: int.parse(row['start_time'].toString().split(":")[1]),
      );
      TimeOfDay endTime = TimeOfDay(
        hour: int.parse(row['end_time'].toString().split(":")[0]),
        minute: int.parse(row['end_time'].toString().split(":")[1]),
      );
      bool isAvailable = row['status'].toString() == 'available';
      NeatCleanCalendarEvent availabilityEvent = NeatCleanCalendarEvent(
          isAvailable ? 'Available' : 'Not Available',
          description: 'Click to check availability',
          startTime: DateTime(date.year,date.month, date.day, startTime.hour, startTime.minute),
          endTime: DateTime(date.year,date.month, date.day, endTime.hour, endTime.minute),
          color: isAvailable ? Colors.green : Colors.red,
      );
      DateTime eventDate = DateTime(date.year,date.month, date.day);
      events.putIfAbsent(eventDate, ()=> []).add(availabilityEvent);
    }
    setState(() {
      _events = events;
    });
  }

  Future<void> _logOut() async {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
          (route) => false,
    );
  }

  Future<void> _loadStudentSharingMeeting(int eventId) async {
    try {
      final conn = await MySQLHelper.connect();
      final result = await conn.query(
          'SELECT student_id FROM events WHERE id = ?',
          [eventId]
      );

      if (result.isEmpty || result.first['student_id'] == null) {
        setState(() {
          studentId = 0;
          studentName = "-student-";
        });
        await conn.close();
        return;
      }

      final data = result.first;
      int tempStudentId = data['student_id'];

      setState(() {
        studentId = tempStudentId;
      });

      await conn.close();

      if (studentId > 0) {
        await _studentIdFromEvent();
      }

    } catch (e) {
      print('Error loading student ID: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar datos: $e'), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _studentIdFromEvent() async {
    if (studentId == 0) {
      return;
    }

    try {
      final conn = await MySQLHelper.connect();
      final result = await conn.query(
        'SELECT username FROM users WHERE id = ?',
        [studentId],
      );

      await conn.close();

      if (result.isEmpty) {
        setState(() {
          studentName = "Unknown";
        });
        return;
      }

      final data = result.first;
      String tempStudentName = data['username'] ?? "Unknown";

      setState(() {
        studentName = tempStudentName;
      });

    } catch (e) {
      print('Error loading student name: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar el nombre del estudiante: $e'), backgroundColor: Colors.red),
      );
    }
  }

  void _showAddEventDialog() {
    TextEditingController titleController = TextEditingController();
    TextEditingController descController = TextEditingController();
    DateTime selectedDate = DateTime.now();
    TimeOfDay selectedStartTime = TimeOfDay.now();
    TimeOfDay selectedEndTime = TimeOfDay(
      hour: selectedStartTime.hour + 1,
      minute: selectedStartTime.minute,
    );

    String selectedStatus = "available";

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: Text("Add Event",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.blue[600]),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: titleController,
                      decoration: InputDecoration(
                        labelText: "Title",
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                    SizedBox(height: 12),
                    TextField(
                      controller: descController,
                      decoration: InputDecoration(
                        labelText: "Description",
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                    SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: selectedStatus,
                      onChanged: (String? newValue) {
                        setState(() => selectedStatus = newValue!);
                      },
                      items: ["available", "not_available"]
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value.toUpperCase()),
                        );
                      }).toList(),
                      decoration: InputDecoration(
                        labelText: "Status",
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                    SizedBox(height: 12),
                    OutlinedButton.icon(
                      icon: Icon(Icons.calendar_today, color: Colors.blue[600]),
                      label: Text("Date: ${selectedDate.day}/${selectedDate.month}/${selectedDate.year}",
                        style: TextStyle(color: Colors.blue[600]),
                      ),
                      onPressed: () async {
                        DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: selectedDate,
                          firstDate: DateTime.now(),
                          lastDate: DateTime(2100),
                        );
                        if (picked != null) {
                          setState(() => selectedDate = picked);
                        }
                      },
                    ),
                    SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            icon: Icon(Icons.access_time, color: Colors.blue[600]),
                            label: Text("Start: \n${selectedStartTime.format(context)}",
                              style: TextStyle(color: Colors.blue[600]),
                            ),
                            onPressed: () async {
                              TimeOfDay? picked = await showTimePicker(
                                context: context,
                                initialTime: selectedStartTime,
                              );
                              if (picked != null) {
                                setState(() => selectedStartTime = picked);
                              }
                            },
                          ),
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton.icon(
                            icon: Icon(Icons.access_time_filled, color: Colors.blue[600]),
                            label: Text("End: \n${selectedEndTime.format(context)}",
                              style: TextStyle(color: Colors.blue[600]),
                            ),
                            onPressed: () async {
                              TimeOfDay? picked = await showTimePicker(
                                context: context,
                                initialTime: selectedEndTime,
                              );
                              if (picked != null) {
                                setState(() => selectedEndTime = picked);
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  child: Text("Cancel", style: TextStyle(color: Colors.grey[600])),
                  onPressed: () => Navigator.pop(context),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[600],
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: Text("Save", style: TextStyle(color: Colors.white)),
                  onPressed: () async {
                    final conn = await MySQLHelper.connect();
                    await conn.query(
                      'INSERT INTO events (user_id, title, description, start_time, end_time, status, student_id) VALUES (?, ?, ?, ?, ?, ?, ?)',
                      [
                        widget.userId,
                        titleController.text,
                        descController.text,
                        DateTime(selectedDate.year, selectedDate.month, selectedDate.day,
                            selectedStartTime.hour, selectedStartTime.minute)
                            .toIso8601String(),
                        DateTime(selectedDate.year, selectedDate.month, selectedDate.day,
                            selectedEndTime.hour, selectedEndTime.minute)
                            .toIso8601String(),
                        selectedStatus,
                        null
                      ],
                    );
                    await conn.close();
                    _loadEvents();
                    Navigator.pop(context);
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final SettingsProvider themeProvider = Provider.of<SettingsProvider>(context, listen: false);
    return Scaffold(
      backgroundColor: themeProvider.isDarkMode == true ? Colors.grey[900] : Colors.grey[100],
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: themeProvider.isDarkMode == true ? Colors.grey[900] : Colors.grey[100],
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Teacher Profile',
          style: TextStyle(color: themeProvider.isDarkMode == true ? Colors.white : Colors.black),
        ),
        actions: [
          PopupMenuButton<int>(
            icon: Icon(Icons.add, color: themeProvider.isDarkMode == true ? Colors.white : Colors.black),
            color: themeProvider.isDarkMode == true ? Colors.white : Colors.grey[800], // Fondo oscuro como en el ejemplo de Chrome
            elevation: 10,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            offset: Offset(0,50),
            onSelected: (int choice) {
              if (choice == 0) {
                _showAddEventDialog();
              } else if (choice == 1) {
                //_navigateToEventAutomation();
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<int>>[
              PopupMenuItem<int>(
                value: 0,
                child: ListTile(
                  leading: Icon(Icons.flash_on, color: themeProvider.isDarkMode == true ? Colors.black : Colors.white),
                  title: Text('One-time event', style: TextStyle(color: themeProvider.isDarkMode == true ? Colors.black : Colors.white)),
                  onTap: _showAddEventDialog,
                ),
              ),
              PopupMenuItem<int>(
                value: 1,
                child: ListTile(
                  leading: Icon(Icons.smart_toy_rounded, color: themeProvider.isDarkMode == true ? Colors.black : Colors.white),
                  title: Text('Event automation', style: TextStyle(color: themeProvider.isDarkMode == true ? Colors.black : Colors.white)),
                    onTap: ()async{
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EventAutomationPage(userId: widget.userId),
                        ),
                      ).then((value) {
                        if (value == true) {
                          _loadEvents();
                        }
                      });
                    },
                ),
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center, // Asegura la alineación central
                  children: [
                    SizedBox(height: 20),
                    Center(
                      child: CircleAvatar(
                        radius: 50,
                        backgroundImage: imageBytes != null
                            ? MemoryImage(imageBytes!)
                            : null,
                      ),
                    ),
                    SizedBox(height: 10,),
                    Text(
                      _name,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center, // Centra el texto
                    ),
                    SizedBox(height: 8,),
                    Text(
                      _email,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[800],
                      ),
                      textAlign: TextAlign.center, // Centra el texto
                    ),
                    SizedBox(height: 8,),
                    Text(
                      'Subject: $subject',
                      style: TextStyle(
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center, // Centra el texto
                    ),
                    SizedBox(height: 8,),
                    Text(
                      'Biography: $bio',
                      style: TextStyle(
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center, // Centra el texto
                    ),
                    SizedBox(height: 15),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EditTeacherProfileScreen(teacherId: widget.userId),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[800],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        padding: EdgeInsets.symmetric(horizontal: 40, vertical: 10),
                      ),
                      child: Text(
                        'Edit Profile',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 500,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: themeProvider.isDarkMode == true ? Colors.grey[600] : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 10,
                          spreadRadius: 2,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Calendar(
                      startOnMonday: true,
                      weekDays: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'],
                      eventsList: _events.entries.expand((entry) => entry.value).toList(),
                      isExpandable: true,
                      eventDoneColor: Colors.green,
                      selectedColor: Colors.purple,
                      todayColor: Colors.red,
                      eventColor: themeProvider.isDarkMode == true ? Colors.black : Colors.grey,
                      locale: 'en_US',
                      todayButtonText: 'Today',
                      expandableDateFormat: 'EEEE, dd MMMM yyyy',
                      onEventSelected: (event)async {
                        int? eventId = int.tryParse(event.id.toString()); // Convierte el ID a entero si es posible
                        if (eventId != null) {
                          await _loadStudentSharingMeeting(eventId); // Esperamos que cargue el nombre
                        } else {
                          print("Error: No se pudo obtener el ID del evento.");
                        }
                        _studentIdFromEvent();
                        if(event.summary == 'Available' || event.summary == 'Not Available'){
                          _toggleAvailability(event);

                        }else if(event.summary == 'Pending' || event.summary == 'Canceled'){
                            //_handlePendingOrCanceled(event);
                          print('Evento cancelado o pendiente');
                          }else {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              backgroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              title: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    studentName.isNotEmpty ? 'Meeting with $studentName for $subject \n\nEvent title: ${event.summary}' : 'Meeting with -student- for $subject \n\nEvent title: ${event.summary}',
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
                                      color: themeProvider.isDarkMode == true ? Colors.black : Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildEventDetail(Icons.description, "Description", event.description ?? "No description"),
                                  _buildEventDetail(Icons.access_time, "Start Time", _formatDateTime(event.startTime)),
                                  _buildEventDetail(Icons.access_time_filled, "End Time", _formatDateTime(event.endTime)),
                                ],
                              ),
                              actions: [
                                TextButton(
                                  child: Text("Edit", style: TextStyle(color: Colors.green)),
                                  onPressed: () {
                                    String? eventId = getEventId(event);
                                    if (eventId != null) {
                                      final selectedEvent = {
                                        'id': int.parse(eventId),
                                        'title': event.summary,
                                        'description': event.description ?? '',
                                        'start_time': event.startTime.toIso8601String(),
                                        'end_time': event.endTime.toIso8601String(),
                                      };
                                      _editEvent(context, selectedEvent);
                                    } else {
                                      print("Error: El evento no tiene un ID válido.");
                                    }
                                  },
                                ),

                                TextButton(
                                  child: Text("Delete", style: TextStyle(color: Colors.red)),
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: Text("Confirm Deletion"),
                                          content: Text("Are you sure you want to delete this event? This action cannot be undone."),
                                          actions: [
                                            TextButton(
                                              child: Text("Cancel", style: TextStyle(color: Colors.black)),
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              },
                                            ),
                                            TextButton(
                                              child: Text("Delete", style: TextStyle(color: Colors.red)),
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                                String? eventId = getEventId(event);
                                                if (eventId != null) {
                                                  _deleteEvent(context, eventId);
                                                } else {
                                                  print("Error: No se pudo obtener el ID del evento.");
                                                }
                                              },
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  },
                                ),

                                TextButton(
                                  child: Text("Close", style: TextStyle(color: Colors.black)),
                                  onPressed: () => Navigator.pop(context),
                                ),
                              ],
                            ),
                          );
                        }
                      },
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20,),

              ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.blue.withOpacity(0.2),
                  child: Icon(Icons.settings, color: themeProvider.isDarkMode == true ? Colors.white : Colors.blue),
                ),
                title: Text('Settings', style: TextStyle(fontSize: 16, color: themeProvider.isDarkMode == true ? Colors.white : Colors.black)),
                trailing: Icon(Icons.arrow_forward_ios, color: themeProvider.isDarkMode == true ? Colors.white : Colors.grey, size: 16),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SettingsScreen()), // Correct navigation
                  );
                },
              ),
              ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.blue.withOpacity(0.2),
                  child: Icon(Icons.account_balance_wallet, color: themeProvider.isDarkMode == true ? Colors.white : Colors.blue),
                ),
                title: Text('Billing Details', style: TextStyle(fontSize: 16, color: themeProvider.isDarkMode == true ? Colors.white : Colors.black)),
                trailing: Icon(Icons.arrow_forward_ios, color: themeProvider.isDarkMode == true ? Colors.white : Colors.grey, size: 16),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => BillingDetailsScreen()), // Correct navigation
                  );
                },
              ),
              ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.blue.withOpacity(0.2),
                  child: Icon(Icons.notifications, color: themeProvider.isDarkMode == true ? Colors.white : Colors.blue),
                ),
                title: Text('Notifications', style: TextStyle(fontSize: 16, color: themeProvider.isDarkMode == true ? Colors.white : Colors.black)),
                trailing: Icon(Icons.arrow_forward_ios, color: themeProvider.isDarkMode == true ? Colors.white : Colors.grey, size: 16),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => NotificationSettingsScreen()),
                  );
                },
              ),
              ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.blue.withOpacity(0.2),
                  child: Icon(Icons.info, color: themeProvider.isDarkMode == true ? Colors.white : Colors.blue),
                ),
                title: Text('Help & FAQs', style: TextStyle(fontSize: 16, color: themeProvider.isDarkMode == true ? Colors.white : Colors.black)),
                trailing: Icon(Icons.arrow_forward_ios, color: themeProvider.isDarkMode == true ? Colors.white : Colors.grey, size: 16),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => HelpFAQScreen()), // Correct navigation
                  );
                },
              ),
              SizedBox(height: 20),
              ListTile(
                leading: Icon(Icons.logout, color: Colors.red),
                title: Text(
                  'Logout',
                  style: TextStyle(fontSize: 16, color: Colors.red, fontWeight: FontWeight.bold),
                ),
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text("Confirm Logout"),
                        content: Text("Are you sure you want to log out?"),
                        actions: [
                          TextButton(
                            child: Text("Cancel", style: TextStyle(color: Colors.black)),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                          TextButton(
                            child: Text("Logout", style: TextStyle(color: Colors.red)),
                            onPressed: () {
                              Navigator.of(context).pop();
                              _logOut();
                            },
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
              SizedBox(height: 20,),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _toggleAvailability(NeatCleanCalendarEvent event)async{
    final conn = await MySQLHelper.connect();
    DateTime eventDate = event.startTime;
    String startTime = "${eventDate.hour} : ${eventDate.minute}";
    String endTime = "${event.endTime.hour} : ${event.endTime.minute}";
    final result = await conn.query(
      'SELECT a.id , a.status FROM availability a INNER JOIN users u ON a.teacher_id = u.teacher_id WHERE u.id = ? AND a.date = ? AND a.start_time = ? AND a.end_time = ?',
      [
        widget.userId, eventDate.toIso8601String().split("t")[0], startTime, endTime
      ]
    );
    if(result.isNotEmpty){
      int availabilityId = result.first['id'];
      String newStatus = (result.first['status'] == 'available') ? 'not_available' : 'available';
      await conn.query(
        'UPDATE availability SET status = ? WHERE id = ?',
        [
          newStatus, availabilityId
        ]
      );
      print('ENTRANDO EN EL IF DEL TOGGLEAVAILABILITY');
    }

    await conn.close();
    _loadEvents();
  }

  List<NeatCleanCalendarEvent> getSelectedDayEvents() {
    return _selectedDate != null
        ? _events[_selectedDate] ?? []
        : [];
  }

  String? getEventId(NeatCleanCalendarEvent event) {
    if (event.id == null || event.id!.isEmpty) {
      print("⚠️ El evento no tiene un ID asignado.");
      return null;
    }

    try {
      String eventId = event.id.toString();
      print("✅ ID del evento seleccionado: $eventId");
      return eventId;
    } catch (e) {
      print("❌ Error al obtener el ID del evento: $e");
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

  Future<void> _deleteEvent(BuildContext context, String eventId) async {
    try {
      final conn = await MySQLHelper.connect();
      await conn.query(
          'DELETE FROM events WHERE id = ?',
          [int.parse(eventId)]
      );
      await conn.close();

      print("Deleting event with ID: $eventId"); // Debugging

      // Recargar eventos después de eliminar
      _loadEvents();

      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Event deleted successfully'))
      );

      Navigator.pop(context); // Cerrar el diálogo
    } catch (e) {
      print('Error deleting event: $e');
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting event'))
      );
    }
  }

  Future<void> _editEvent(BuildContext context, Map<String, dynamic> eventData) async {
    final titleController = TextEditingController(text: eventData['title']);
    final descriptionController = TextEditingController(text: eventData['description']);

    DateTime selectedStartTime = DateTime.parse(eventData['start_time']);
    DateTime selectedEndTime = DateTime.parse(eventData['end_time']);
    String initialStatus = eventData['status'] ?? 'available';
    bool isAvailable = initialStatus == 'available';

    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setDialogState) {
            return AlertDialog(
              title: Text(
                'Edit Event',
                style: TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildTextField(titleController, 'Title'),
                    SizedBox(height: 10),
                    _buildTextField(descriptionController, 'Description'),
                    SizedBox(height: 20),
                    _buildDateTimePicker(
                      context,
                      setDialogState,
                      label: 'Start Date and Time',
                      selectedDateTime: selectedStartTime,
                      onDateTimeSelected: (newDateTime) {
                        setDialogState(() => selectedStartTime = newDateTime);
                      },
                    ),
                    SizedBox(height: 10),
                    _buildDateTimePicker(
                      context,
                      setDialogState,
                      label: 'End Date and Time',
                      selectedDateTime: selectedEndTime,
                      onDateTimeSelected: (newDateTime) {
                        setDialogState(() => selectedEndTime = newDateTime);
                      },
                    ),
                    SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Available', style: TextStyle(fontSize: 16)),
                        Switch(
                          value: isAvailable,
                          onChanged: (value) {
                            setDialogState(() => isAvailable = value);
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Cancel'),
                ),
                ElevatedButton(
                  child: Text('Save'),
                  onPressed: () async {
                    final conn = await MySQLHelper.connect();
                    try {
                      String formattedStartTime = DateFormat('yyyy-MM-dd HH:mm:ss').format(selectedStartTime);
                      String formattedEndTime = DateFormat('yyyy-MM-dd HH:mm:ss').format(selectedEndTime);
                      String availabilityStatus = isAvailable ? 'available' : 'not_available';

                      await conn.query(
                        'UPDATE events SET title = ?, description = ?, start_time = ?, end_time = ?, status = ? WHERE id = ?',
                        [
                          titleController.text,
                          descriptionController.text,
                          formattedStartTime,
                          formattedEndTime,
                          availabilityStatus,
                          eventData['id'],
                        ],
                      );
                      Navigator.pop(context);
                      Navigator.pop(context, true);
                      _loadEvents();
                    } catch (e) {
                      print('Error updating event: $e');
                    } finally {
                      await conn.close();
                    }
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildTextField(TextEditingController controller, String label){
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: Colors.blueAccent,
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(
            color: Colors.blueAccent,
          ),
        ),
      ),
    );
  }

  Widget _buildDateTimePicker(
      BuildContext context,
      StateSetter setDialogState,{
        required String label,
        required DateTime selectedDateTime ,
        required ValueChanged<DateTime> onDateTimeSelected,
      }){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ElevatedButton(
          onPressed: ()async{
            final newDate = await showDatePicker(
              context: context,
              initialDate: selectedDateTime,
              firstDate: DateTime(2000),
              lastDate: DateTime(2101),
            );
            if(newDate != null){
              final newDateTime = DateTime(
                newDate.year,
                newDate.month,
                newDate.day,
                newDate.hour,
                newDate.minute,
              );
              onDateTimeSelected(newDateTime);
            }
          },
          child: Text(label),
        ),
        Text('Selected: ${DateFormat('dd/MM/yyyy HH:mm').format(selectedDateTime)}'),
      ],
    );
  }
}