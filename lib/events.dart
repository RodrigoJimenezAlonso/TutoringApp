import 'package:flutter/material.dart';
import 'datePicker.dart';
import 'package:proyecto_rr_principal/mysql.dart';
import 'package:provider/provider.dart';
import 'package:proyecto_rr_principal/providers/user_provider.dart';

class EventsController extends StatefulWidget {
  @override
  _EventsControllerState createState() => _EventsControllerState();
}

class _EventsControllerState extends State<EventsController> {
  List<Map<String, dynamic>> events = [];


  @override
  void initState() {
    super.initState();
    _fetchEvents();
  }
  bool isLoading = true;
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
        'SELECT title, description, start_time, end_time FROM events WHERE user_id = ?',
        [userId],
      );
      print('Raw query result: $result');

      setState(() {
        events = result.map((row) {
          final startTime = row['start_time'].toString();
          final endTime = row['end_time'].toString();
          return {
            'title': row['title'] as String,
            'description': row['description'] as String,
            'start_time': DateTime.parse(startTime).toIso8601String(),
            'end_time': DateTime.parse(endTime).toIso8601String(),
          };
        }).toList();
      });
    } catch (e) {
      print('Error fetching events: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
      print('Finished fetching events.');
    }
  }

  Future<void> _addEventDialog(BuildContext context, DateTime selectedDate) async{
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();

    showDialog<void>(
        context: context,
        builder: (BuildContext context){
          return AlertDialog(
            title: Text('Add new event'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: InputDecoration(
                    labelText: 'title'
                  ),
                ),
                TextField(
                  controller: descriptionController,
                  decoration: InputDecoration(
                      labelText: 'description controller'
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                  onPressed: ()=> Navigator.pop(context),
                  child: Text('cancel'),
              ),
              ElevatedButton(
                child: Text('add'),
                onPressed: ()async{
                  if(titleController.text.isNotEmpty && descriptionController.text.isNotEmpty){
                    try{
                      final userId = Provider.of<UserProvider>(context, listen: false).userId;
                      if(userId == null){
                        print('Error UserId is null');
                        return;
                      }
                      final conn = await MySQLHelper.connect();
                      await conn.query(
                        'INSERT INTO events(title, description, start_time, end_time, user_id) VALUES(?,?,?,?,?)',
                        [
                          titleController.text,
                          descriptionController.text,
                          selectedDate.toIso8601String(),
                          selectedDate.add(Duration(hours: 1)).toIso8601String(),
                          userId,
                        ],
                      );
                      await conn.close();
                      await _fetchEvents();
                      Navigator.pop(context);
                    }
                    catch(e){
                      print('Could not add the event: $e');
                    }
                  }
                },
              ),
            ],
          );

        }
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
            onPressed: ()async {
              // Navega al componente DatePicker
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
        ? Center(child: CircularProgressIndicator(),)
        :  ListView.builder(
            itemCount: events.length,
            itemBuilder: (context, index) {
              final event = events[index];
              return ListTile(
                title: Text(event['title']),
                subtitle: Text(event['description']),
              );
            },
          ),
    );
  }
}
