import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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
  
  Future<void> _deleteEvent(int eventId)async{
    try{
      final conn = await MySQLHelper.connect();
      await conn.query(
          'DELETE FROM events WHERE id = ?',
          [
            eventId
          ],
      );
      await conn.close();
      setState(() {
        _events.removeWhere((event)=> event['id'] == eventId);
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(
        'Event Deleted Successfully',
      )));
    }catch(e){
      print('Error deleting Event: $e');
    }
  }

  Future<Map<String, dynamic>?> _addEventDialog(BuildContext context, {Map<String, dynamic>? eventToEdit}) async {
    final titleController = TextEditingController(text: eventToEdit?['title']);
    final descriptionController = TextEditingController(text: eventToEdit?['description']);
    DateTime? selectedDate = eventToEdit?['startTime'];
    
    return showDialog<Map<String, dynamic>>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
            builder: (context,setDialogState){
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
                        child: Text( selectedDate == null
                            ? 'Select Date & Time'
                            : DateFormat('dd/MM/yyyy HH:mm').format(selectedDate!)
                        ),
                        onPressed: () async {
                          final pickedDate = await Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => DatePicker()),
                          );
                          if(pickedDate != null){
                            setDialogState((){
                              selectedDate = pickedDate;
                            });
                          }
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
            }
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
                final newEvent = await _addEventDialog(context);
                if(newEvent != null){
                  _fetchEvents();
                }
              },
            ),]
      ),
      body: ListView.builder(
        itemCount: _events.length,
        itemBuilder: (context, index) {
          final event = _events[index];
          return Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            elevation: 3,
            margin: EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 5,
            ),
            child: ListTile(
              title: Text(
                event['title'],
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),

              subtitle: Text(
                '${event['description']} \n ${DateFormat('dd/MM/yyyy HH:mm').format(event['startTime'])}',
                style: TextStyle(
                  color: Colors.grey[700],
                ),
              ),
              
              isThreeLine: true,
              leading: Icon(Icons.event, color: Colors.blueAccent,),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                      onPressed: ()async{
                        final updateEvent = await _addEventDialog(context, eventToEdit: event);
                        if(updateEvent != null ){
                          _fetchEvents();
                        }
                      }, 
                      icon: Icon(Icons.edit, color: Colors.blueAccent,)
                  ),
                  
                  IconButton(
                      onPressed: ()=> _deleteEvent(event['id']), 
                      icon: Icon(Icons.delete, color: Colors.redAccent,)
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}