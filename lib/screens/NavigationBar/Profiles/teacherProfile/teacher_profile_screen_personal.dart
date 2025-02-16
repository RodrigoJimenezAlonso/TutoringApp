import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mysql1/mysql1.dart';
import 'package:proyecto_rr_principal/mysql.dart';
import 'package:flutter_neat_and_clean_calendar/flutter_neat_and_clean_calendar.dart';
import 'dart:typed_data';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:proyecto_rr_principal/screens/NavigationBar/Profiles/teacherProfile/edit_teacher_profile_screen_personal.dart';
import 'package:proyecto_rr_principal/auth/login_page.dart';
import 'package:proyecto_rr_principal/screens/Settings/billing_details_screen.dart';
import 'package:proyecto_rr_principal/screens/Settings/help_faqs_screen.dart';
import 'package:proyecto_rr_principal/screens/Settings/notification_setting_screen.dart';
import 'package:proyecto_rr_principal/screens/Settings/settings.dart';


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


  Future<void> _loadEvents() async {
    final conn = await MySQLHelper.connect();
    final result = await conn.query(
      'SELECT id, title, description, start_time, end_time FROM events WHERE user_id = ?',
      [widget.userId],
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


  Future<void> _logOut() async {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
          (route) => false,
    );
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

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder( // Se agrega StatefulBuilder para actualizar el estado dentro del diálogo
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: Text(
                "Add Event",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: Colors.blue[600],
                ),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: titleController,
                      decoration: InputDecoration(
                        labelText: "Title",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    SizedBox(height: 12),
                    TextField(
                      controller: descController,
                      decoration: InputDecoration(
                        labelText: "Description",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    OutlinedButton.icon(
                      icon: Icon(Icons.calendar_today, color: Colors.blue[600]),
                      label: Text(
                        "Date: ${"${selectedDate.day}/${selectedDate.month}/${selectedDate.year}"}",
                        style: TextStyle(color: Colors.blue[600]),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.blue[600]!),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: () async {
                        DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: selectedDate,
                          firstDate: DateTime.now(),
                          lastDate: DateTime(2100),
                        );
                        if (picked != null) {
                          setState(() => selectedDate = picked); // Actualiza la fecha
                        }
                      },
                    ),
                    SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            icon: Icon(Icons.access_time, color: Colors.blue[600]),
                            label: Text(
                              "Start: \n${selectedStartTime.format(context)}",
                              style: TextStyle(color: Colors.blue[600]),
                            ),
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: Colors.blue[600]!),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            onPressed: () async {
                              TimeOfDay? picked = await showTimePicker(
                                context: context,
                                initialTime: selectedStartTime,
                              );
                              if (picked != null) {
                                setState(() => selectedStartTime = picked); // Se actualiza la hora de inicio
                              }
                            },
                          ),
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton.icon(
                            icon: Icon(Icons.access_time_filled, color: Colors.blue[600]),
                            label: Text(
                              "End: \n${selectedEndTime.format(context)}",
                              style: TextStyle(color: Colors.blue[600]),
                            ),
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: Colors.blue[600]!),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            onPressed: () async {
                              TimeOfDay? picked = await showTimePicker(
                                context: context,
                                initialTime: selectedEndTime,
                              );
                              if (picked != null) {
                                setState(() => selectedEndTime = picked); // Se actualiza la hora de finalización
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
                      'INSERT INTO events (user_id, title, description, start_time, end_time) VALUES (?, ?, ?, ?, ?)',
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
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.grey[100],
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Teacher Profile',
          style: TextStyle(color: Colors.black),
        ),
        actions: [
          IconButton(icon: Icon(Icons.add), color: Colors.black, onPressed: _showAddEventDialog),
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
                      color: Colors.white,
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
                      eventColor: Colors.grey,
                      locale: 'en_US',
                      todayButtonText: 'Today',
                      expandableDateFormat: 'EEEE, dd MMMM yyyy',
                      onEventSelected: (event) {
                        String? eventId = getEventId(event);
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            backgroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            title: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Meeting with -name- for -subject- ${event.summary}',
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
                                onPressed: () => _deleteEvent(context, eventId!),
                              ),
                              TextButton(
                                child: Text("Close"),
                                onPressed: () => Navigator.pop(context),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20,),

              ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.blue.withOpacity(0.2),
                  child: Icon(Icons.settings, color: Colors.blue),
                ),
                title: Text('Settings', style: TextStyle(fontSize: 16, color: Colors.black)),
                trailing: Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 16),
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
                  child: Icon(Icons.account_balance_wallet, color: Colors.blue),
                ),
                title: Text('Billing Details', style: TextStyle(fontSize: 16, color: Colors.black)),
                trailing: Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 16),
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
                  child: Icon(Icons.notifications, color: Colors.blue),
                ),
                title: Text('Notifications', style: TextStyle(fontSize: 16, color: Colors.black)),
                trailing: Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 16),
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
                  child: Icon(Icons.info, color: Colors.blue),
                ),
                title: Text('Help & FAQs', style: TextStyle(fontSize: 16, color: Colors.black)),
                trailing: Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 16),
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
                onTap: _logOut,
              ),
              SizedBox(height: 20,),
            ],
          ),
        ),
      ),
    );
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

    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setDialogState) {
            return AlertDialog(
              title: Text('Edit Event',
                style: TextStyle(
                  color: Colors.blueAccent,
                  fontWeight: FontWeight.bold,
                ),
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
                    try {
                      final conn = await MySQLHelper.connect();
                      String formattedStartTime = DateFormat('yyyy-MM-dd HH:mm:ss').format(selectedStartTime);
                      String formattedEndTime = DateFormat('yyyy-MM-dd HH:mm:ss').format(selectedEndTime);

                      await conn.query(
                        'UPDATE events SET title = ?, description = ?, start_time = ?, end_time = ? WHERE id = ?',
                        [
                          titleController.text,
                          descriptionController.text,
                          formattedStartTime,
                          formattedEndTime,
                          eventData['id'],
                        ],
                      );

                      Navigator.pop(context);
                      Navigator.pop(context, true);
                      _loadEvents();

                    } catch (e) {
                      print('Error updating events: $e');
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