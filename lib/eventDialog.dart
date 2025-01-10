import 'package:flutter/material.dart';
import 'datePicker.dart';
import 'data.dart';
import 'package:proyecto_rr_principal/mysql.dart';

class EvtController extends StatefulWidget {
  @override
  _EvtControllerState createState() => _EvtControllerState();
}

class _EvtControllerState extends State<EvtController> {
  List<Map<String, dynamic>> _events = [];

  @override
  void initState() {
    super.initState();
    _fetchEvents();
  }

  Future<void> _fetchEvents() async {
    try{
      final conn = await MySQLHelper.connect();
      final result = await conn.query(
          'SELECT id , title, description, start_time, end_time, FROM events'
      );
      final events = result.map(
              (row)=> {
            'id': row['id'],
            'title': row['title'],
            'description': row['description'],
            'startTime': row['start_time'],
            'endTime': row['end_time'],
          }
      ).toList();
      await conn.close();
    }
    catch(e){
      print('Error eventDialog: $e');
    }
  }

  Future<Map<String, dynamic>?> _addEventDialog(BuildContext context, DateTime selectedDate, {Map<String, dynamic>? eventToEdit}) async {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();

    if(eventToEdit != null){
      titleController.text = eventToEdit['title'];
      descriptionController.text = eventToEdit['description'];
    }
    return showDialog<Map<String, dynamic>>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(eventToEdit == null ? 'Add new event' : 'Edit Event'),
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
              child: Text(eventToEdit == null ? 'Add' : 'Update'),
              onPressed: () async {
                if (titleController.text.isNotEmpty &&
                    descriptionController.text.isNotEmpty &&
                    selectedDate != null) {
                  final newEvent = {
                    "id": eventToEdit?['id'],
                    "title": titleController.text,
                    "description": descriptionController.text,
                    "startTime": selectedDate!.toIso8601String(),
                    "endTime": selectedDate!.add(Duration(hours: 1)).toIso8601String(),
                  };
                  try {
                    final conn = await MySQLHelper.connect();
                    if (eventToEdit == null) {
                      await conn.query(
                        'INSERT INTO events (title, description, start_time, end_time) VALUES(?,?,?,?)',
                        [
                          newEvent['title'],
                          newEvent['description'],
                          newEvent['startTime'],
                          newEvent['endTime'],
                        ],
                      );
                    } else {
                      var result = await conn.query(
                        'UPDATE events SET title = ?, description = ?, start_time = ?, end_time = ? WHERE id = ?',
                        [
                          newEvent['title'],
                          newEvent['description'],
                          newEvent['startTime'],
                          newEvent['endTime'],
                          newEvent['id'],
                        ],
                      );
                      print('Actualizando evento con ID: ${newEvent['id']}');
                      print('Nuevos valores: ${newEvent['title']}, ${newEvent['description']}, ${newEvent['startTime']}, ${newEvent['endTime']}');
                      if (result.affectedRows! > 0) {
                        print('Evento actualizado correctamente');
                      } else {
                        print('No se actualizó ningún evento');
                      }
                    }
                    await conn.close();
                    Navigator.pop(context, newEvent);
                  } catch (e) {
                    print('Error adding/updating Event: $e');
                  }
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
          title: Text('Events: '),
          actions: [
            IconButton(
              icon: Icon(Icons.add),
              onPressed: () async {
                final selectedDate = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DatePicker(),
                    )
                );
                if(selectedDate != null){
                  _addEventDialog(context, selectedDate);
                }
              },
            ),]
      ),
      body: ListView.builder(
        itemCount: _events.length,
        itemBuilder: (context, index) {
          final event = _events[index];
          return ListTile(
            title: Text(event['title']),
            subtitle: Text(event['description']),
          );
        },
      ),
    );
  }
}