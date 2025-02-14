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
                    SizedBox(height: 10,),
                    _buildTextField(descriptionController, 'Description'),
                    SizedBox(height: 20),
                    _buildDateTimePicker(
                        context,
                        setDialogState,
                        label: 'Start Date and Time',
                        selectedDateTime: selectedStartTime,
                        onDateTimeSelected: (newDateTime){
                          setDialogState(()=> selectedStartTime = newDateTime);
                        }
                    ),
                    SizedBox(height: 10,),
                    _buildDateTimePicker(
                        context,
                        setDialogState,
                        label: 'End Date and Time',
                        selectedDateTime: selectedEndTime,
                        onDateTimeSelected: (newDateTime){
                          setDialogState(()=> selectedEndTime = newDateTime);
                        }
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

  @override
  Widget build(BuildContext context){
    final startTime = widget.event['start_time'];
    final endTime = widget.event['end_time'];
    final formatedStartTime = DateFormat('dd/MM/yyyy HH:mm', 'es_ES').format(startTime);
    final formatedEndTime = DateFormat('dd/MM/yyyy HH:mm', 'es_ES').format(endTime);

    return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: true,
          iconTheme: IconThemeData(
            color: Colors.white, //change your color here
          ),
          title: Text('Event Details',
            style: TextStyle(
              color: Colors.white
            ),
          ),
          backgroundColor: Colors.blueAccent,
          centerTitle: true,
          elevation: 0,
        ),
        body: Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 4,
                  child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildDetailedRow(
                            'Event',
                            widget.event['title'],
                          ),
                          _buildDetailedRow(
                            'Description',
                            widget.event['description'],
                          ),
                          _buildDetailedRow(
                            'Start Time',
                            formatedStartTime,
                          ),
                          _buildDetailedRow(
                            'End Time',
                            formatedEndTime,
                          ),
                        ],
                      ),
                  ),
                ),


                SizedBox(height: 20,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildActionButton(
                        'Delete',
                        Colors.red,
                        Icons.delete,
                        ()=>_deleteEvent(context),
                    ),
                    _buildActionButton(
                      'Edit',
                      Colors.blue,
                          Icons.edit,
                          ()=>_editEvent(context),
                    ),
                    _buildActionButton(
                      'Book Event',
                      Colors.green,
                          Icons.book,
                          ()=>_bookEvent(context, widget.event['id']),
                    ),
                  ],
                )
              ],
            ),
           ),
        );
  }

  Widget _buildDetailedRow(String label, String value){
    return Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 5.0,
        ),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.blueAccent,
            ),
          ),
          Expanded(
              child: Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),
          )
        ],
      ),
    );
  }


  Widget _buildActionButton(String label, Color color, IconData icon, VoidCallback onPressed){
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: color,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(
            color: color,
          ),
        ),
        padding: EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 12,
        )
      ),
        onPressed: onPressed,
        icon: Icon(icon, color: Colors.white),
        label: Text(
            label,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
    );
  }
}