import 'package:flutter/material.dart';
import 'datePicker.dart';
import 'package:proyecto_rr_principal/mysql.dart';
import 'package:provider/provider.dart';
import 'package:proyecto_rr_principal/providers/user_provider.dart';
import 'screens/NavigationBar/event_detail_screen.dart';
import 'package:intl/intl.dart';
import 'date_time_picker.dart';

class EventsController extends StatefulWidget {
  @override
  _EventsControllerState createState() => _EventsControllerState();
}

class _EventsControllerState extends State<EventsController> {
  List<Map<String, dynamic>> events = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchEvents();
  }

  Future<void> _fetchEvents() async {
    print('Fetching events...');
    setState(() {
      isLoading = true;
    });

    try {
      final conn = await MySQLHelper.connect();
      print('Connected to database.');

      final userId = Provider.of<UserProvider>(context, listen: false).userId;
      if (userId == null) {
        throw Exception('User ID is null');
      }

      final result = await conn.query(
        "SELECT id, title, description, "
            "CAST(DATE_FORMAT(start_time, '%Y-%m-%dT%H:%i:%s') AS CHAR) AS start_time, "
            "CAST(DATE_FORMAT(end_time, '%Y-%m-%dT%H:%i:%s') AS CHAR) AS end_time "
            "FROM events WHERE user_id = ?",
        [userId],
      );

      print('Raw query result: $result');

      setState(() {
        events = result.map((row) {
          try {
            final startTimeString = row['start_time']?.toString() ?? '';
            final endTimeString = row['end_time']?.toString() ?? '';

            if (startTimeString.isEmpty || endTimeString.isEmpty) {
              throw Exception('Empty start_time or end_time for row: $row');
            }

            return {
              'id': row['id'] ?? 0,
              'title': row['title']?.toString() ?? 'No Title',
              'description': row['description']?.toString() ?? 'No description',
              'start_time': DateTime.tryParse(row['start_time']?.toString() ?? '') ?? DateTime.now(),
              'end_time': DateTime.tryParse(row['end_time']?.toString() ?? '') ?? DateTime.now(),
            };
          } catch (e) {
            print('Error parsing DateTime for row: $row, error: $e');
            return null;
          }
        }).where((event) => event != null).cast<Map<String, dynamic>>().toList();
      });

      print('Eventos cargados: $events');
    } catch (e) {
      print('Error fetching events: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
      print('Finished fetching events. Estado de isLoading: $isLoading');
    }
  }

  Future<void> _addEventDialog(BuildContext context, DateTime selectedDate, {Map<String, dynamic>? eventToEdit}) async {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();

    if (eventToEdit != null) {
      titleController.text = eventToEdit['title'];
      descriptionController.text = eventToEdit['description'];
      selectedDate = eventToEdit['start_time'];
    }

    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(eventToEdit == null ? 'Add new event' : 'Edit Event'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: InputDecoration(
                  labelText: 'Title',
                ),
              ),
              TextField(
                controller: descriptionController,
                decoration: InputDecoration(
                  labelText: 'Description',
                ),
              ),
              SizedBox(height: 10,),
              ElevatedButton(
                child: Text('Select a New Date'),
                onPressed:()async{
                  DateTime? newSelectedDate = await selectedDateTime(context, selectedDate);
                  if(newSelectedDate != null){
                    setState(() {
                      selectedDate = newSelectedDate;
                    });
                  }
                },
              ),
              SizedBox(height: 10,),
              Text('Selected Date: ${selectedDate.toString()}'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              child: Text(eventToEdit == null ? 'Add' : 'Update'),
              onPressed: () async {
                final title = titleController.text.trim();
                final description = descriptionController.text.trim();

                if (title.isEmpty || description.isEmpty) {
                  print('Error: Title or description is empty.');
                  return;
                }

                try {
                  final userId = Provider.of<UserProvider>(context, listen: false).userId;
                  if (userId == null) {
                    throw Exception('User ID is null');
                  }

                  final conn = await MySQLHelper.connect();
                  if (eventToEdit == null) {
                    await conn.query(
                      'INSERT INTO events(title, description, start_time, end_time, user_id) VALUES(?,?,?,?,?)',
                      [
                        title,
                        description,
                        selectedDate.toIso8601String(),
                        selectedDate.add(Duration(hours: 1)).toIso8601String(),
                        userId,
                      ],
                    );
                    print('Evento añadido: $title, $description');
                  } else {
                    await conn.query(
                      'UPDATE events SET title = ?, description = ?, start_time = ?, end_time = ? WHERE id = ?',
                      [
                        title,
                        description,
                        selectedDate.toIso8601String(),
                        selectedDate.add(Duration(hours: 1)).toIso8601String(),
                        eventToEdit['id'],
                      ],
                    );
                    print('Evento actualizado con ID: ${eventToEdit['id']}');
                  }

                  await conn.close();
                  await _fetchEvents();
                  Navigator.pop(context);
                } catch (e) {
                  print('Could not add or update the event: $e');
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
    return Scaffold(
      appBar: AppBar(
        title: Text('Events'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () async {
              final selectedDate = await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => DatePicker()),
              );
              if (selectedDate != null) {
                _addEventDialog(context, selectedDate);
              }
            },
          ),
        ],
      ),
      body: isLoading
          ? Center(
        child: CircularProgressIndicator(),
      )
          : events.isEmpty
          ? Center(
        child: Text('No events available.'),
      )
          : ListView.builder(
        itemCount: events.length,
        itemBuilder: (context, index) {
          final event = events[index];
          final startTime = event['start_time'];
          final formattedDate = DateFormat('dd/MM/yyyy HH:mm', 'es_ES').format(startTime);

          return ListTile(
            title: Text(
              event['title'],
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(event['description']),
            trailing: Text(
              formattedDate,
            ),
            onTap: () async {
              final updated = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EventDetailScreen(event: event),
                ),
              );
              if (updated != null) {
                await _fetchEvents();
              }
            },
          );
        },
      ),
    );
  }
}