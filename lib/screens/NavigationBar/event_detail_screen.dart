import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:proyecto_rr_principal/mysql.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EventDetailScreen extends StatefulWidget {
  final Map<String, dynamic> event;

  EventDetailScreen({required this.event});

  @override
  _EventDetailScreenState createState()=> _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen>{
  late DateTime selectedStartTime;
  late DateTime selectedEndTime;

  @override
  void initState(){
    super.initState();
    selectedStartTime = widget.event['start_time'];
    selectedEndTime = widget.event['end_time'];


  }

  Future<int?> getStudentId()async{
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('student_id');
  }

  Future<void> _deleteEvent(BuildContext context)async{
    try{
      final conn = await MySQLHelper.connect();
      await conn.query(
          'DELETE FROM events WHERE id = ?',
          [
            widget.event['id']
          ]
      );
      Navigator.pop(context, true);
    }catch(e){
      print('Error deleting events: $e');
    }
  }


  Future<void> _editEvent(BuildContext context) async {
    final titleController = TextEditingController(text: widget.event['title']);
    final descriptionController = TextEditingController(text: widget.event['description']);

    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setDialogState) {
            return AlertDialog(
              title: Text('Edit Event'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
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
                      child: Text('Select Start Date & Time'),
                      onPressed: () async {
                        DateTime? newStartDate = await showDatePicker(
                          context: context,
                          initialDate: selectedStartTime,
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2101),
                        );
                        if (newStartDate != null) {
                          TimeOfDay? newStartTime = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.fromDateTime(selectedStartTime),
                          );
                          if (newStartTime != null) {
                            setDialogState(() {
                              selectedStartTime = DateTime(
                                newStartDate.year,
                                newStartDate.month,
                                newStartDate.day,
                                newStartTime.hour,
                                newStartTime.minute,
                              );
                            });
                          }
                        }
                      },
                    ),
                    Text(
                      'Selected Start Date: ${DateFormat('dd/MM/yyyy HH:mm').format(selectedStartTime)}',
                    ),
                    SizedBox(height: 10),
                    ElevatedButton(
                      child: Text('Select End Date & Time'),
                      onPressed: () async {
                        DateTime? newEndDate = await showDatePicker(
                          context: context,
                          initialDate: selectedEndTime,
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2101),
                        );
                        if (newEndDate != null) {
                          TimeOfDay? newEndTime = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.fromDateTime(selectedEndTime),
                          );
                          if (newEndTime != null) {
                            setDialogState(() {
                              selectedEndTime = DateTime(
                                newEndDate.year,
                                newEndDate.month,
                                newEndDate.day,
                                newEndTime.hour,
                                newEndTime.minute,
                              );
                            });
                          }
                        }
                      },
                    ),
                    Text(
                      'Selected End Date: ${DateFormat('dd/MM/yyyy HH:mm').format(selectedEndTime)}',
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
                      await conn.query(
                        'UPDATE events SET title = ?, description = ?, start_time = ?, end_time = ? WHERE id = ?',
                        [
                          titleController.text,
                          descriptionController.text,
                          selectedStartTime.toIso8601String(),
                          selectedEndTime.toIso8601String(),
                          widget.event['id'],
                        ],
                      );

                      Navigator.pop(context);
                      Navigator.pop(context, true);
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

  void _bookEvent(BuildContext context, int eventId){
    final messageController = TextEditingController();
    showDialog(
        context: context,
        builder: (context){
          return AlertDialog(
            title: Text('Book Event'),
            content: TextField(
              controller: messageController,
              decoration: InputDecoration(
                labelText: 'Message to Professor'
              ),
            ),
            actions: [
              TextButton(
                  onPressed: ()=> Navigator.pop(context),
                  child: Text('Cancel')
              ),
              ElevatedButton(
                  child: Text('Book a class'),
                  onPressed: ()async{
                    final message = messageController.text.trim();
                    final student_id = await getStudentId();
                    if(student_id != null){
                      try{
                        final conn = await MySQLHelper.connect();
                        await conn.query(
                            'INSERT INTO bookings(event_id, student_id, message) VALUES(?,?,?)',
                            [
                              eventId,
                              student_id,
                              message,
                            ],
                        );
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text('Booked Successfully')
                            ),
                        );
                      }catch(e){
                        print('Error Booking Event: $e');
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text('Error Booking Event')
                          ),
                        );
                      }
                    }else{
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text('Student Id not found')
                        ),
                      );
                    }
                  },
              ),
            ],
          );
        }
    );
  }

  @override
  Widget build(BuildContext context){
    final startTime = widget.event['start_time'];
    final endTime = widget.event['end_time'];
    final formatedStartTime = DateFormat('dd/MM/yyyy HH:mm', 'es_ES').format(startTime);
    final formatedEndTime = DateFormat('dd/MM/yyyy HH:mm', 'es_ES').format(endTime);

    return Scaffold(
        appBar: AppBar(
          title: Text('Event Details'),
        ),
        body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Title: ${widget.event['title']}', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
                SizedBox(
                  height: 10,
                ),

                Text('Description: ${widget.event['description']}', style: TextStyle(fontSize: 20,),),
                SizedBox(
                  height: 10,
                ),

                Text('Start Time: $formatedStartTime', style: TextStyle(fontSize: 20, ),),
                SizedBox(
                  height: 10,
                ),

                Text('End Time: $formatedEndTime', style: TextStyle(fontSize: 20, ),),
                SizedBox(
                  height: 20,
                ),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(
                        onPressed: ()=> _deleteEvent(context),
                        child: Text('Delete')
                    ),

                    ElevatedButton(
                        onPressed: ()=> _editEvent(context),
                        child: Text('Edit')
                    ),

                    ElevatedButton(
                        onPressed: ()=> _bookEvent(context, widget.event['id']),
                        child: Text('Book Event')
                    ),
                  ],
                ),
              ],
            ),
           ),
        );
  }
}