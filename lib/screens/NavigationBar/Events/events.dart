import 'dart:async';
import 'package:flutter/material.dart';
import '../../../datePicker.dart';
import 'package:proyecto_rr_principal/mysql.dart';
import 'package:provider/provider.dart';
import 'package:proyecto_rr_principal/providers/user_provider.dart';
import 'event_detail_screen.dart';
import 'package:intl/intl.dart';
import '../../../date_time_picker.dart';
import 'package:proyecto_rr_principal/screens/Settings/settings.dart';

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
    _startCleaningTimer();

  }

  void _startCleaningTimer(){
    Timer.periodic(Duration(hours: 1), (timer){
      _cleanOldEvents();
    });
  }

  Future<void> _cleanOldEvents()async{
    try{
      final conn = await MySQLHelper.connect();
      await conn.query('SET SQL_SAFE_UPDATES = 0',);

      await conn.query(
        'UPDATE events SET status = "finished" WHERE status != "finished" AND end_time < DATE_SUB(NOW(), INTERVAL 2 HOUR)',
      );
      await conn.query(
        'DELETE FROM events WHERE end_time < DATE_SUB(NOW(), INTERVAL 1 WEEK)'
      );
      await conn.query('SET SQL_SAFE_UPDATES = 1',);


      await conn.close();
      print('Eventos actualizados y eliminados correctamente');


    }catch(e){
      print('Error eliminando eventos pasados: $e');
    }
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
      final role = Provider.of<UserProvider>(context, listen: false).role;

      // Comprobación de null para userId y role
      if (userId == null || role == null) {
        throw Exception('User ID or role is null');
      }

      String query = "";
      List<dynamic> params = [userId];

      // Lógica de la consulta según el rol
      if (role == 'teacher') {
        query = "SELECT id, title, description, status, "
            "CAST(DATE_FORMAT(start_time, '%Y-%m-%dT%H:%y:%s') AS CHAR) AS start_time,"
            "CAST(DATE_FORMAT(end_time, '%Y-%m-%dT%H:%y:%s') AS CHAR) AS end_time "
            "FROM events WHERE user_id = ? AND status IN( 'available', 'accepted', 'pending')";
      } else if (role == 'student') {
        query = "SELECT id, title, description, status, "
            "CAST(DATE_FORMAT(start_time, '%Y-%m-%dT%H:%i:%s') AS CHAR) AS start_time,"
            "CAST(DATE_FORMAT(end_time, '%Y-%m-%dT%H:%i:%s') AS CHAR) AS end_time "
            "FROM events WHERE student_id = ? AND status IN('accepted', 'pending')";
      }

      final result = await conn.query(query, params);

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
              'status': row['status']?.toString() ?? 'available',
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
    final titleController = TextEditingController(text: eventToEdit?['title'] ?? '');
    final descriptionController = TextEditingController(text: eventToEdit?['description'] ?? '');
    selectedDate = eventToEdit?['start_time'] ?? selectedDate;

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
              Text('Selected Date: ${selectedDate.toString()}',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              child: Text(eventToEdit == null ? 'Add' : 'Update',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
              ),
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
                      'INSERT INTO events(title, description, start_time, end_time, user_id, status) VALUES(?,?,?,?,?, "available"), (INSERT INTO events(title, description, start_time, end_time, user_id, status) VALUES(?,?,?,?,?, "pending")',
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
    final role = Provider.of<UserProvider>(context, listen: false).role;
    final SettingsProvider themeProvider = Provider.of<SettingsProvider>(context, listen: false);
    return Scaffold(
      backgroundColor: themeProvider.isDarkMode == true ? Colors.grey[900] : Colors.grey[100],
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
            'Upcoming Events',
            style: TextStyle(
              color: themeProvider.isDarkMode == true ? Colors.white : Colors.black,
            ),
        ),
        backgroundColor: themeProvider.isDarkMode == true ? Colors.grey[900] : Colors.grey[100],
        elevation: 0,
        actions: [
          /*if(role == 'teacher')
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
            ),*/
          IconButton(
              icon: Icon(
                Icons.school,
                color: Colors.blue[800],
              ),
              onPressed: () {
                // do something
              }
          ),
        ],
      ),

      body: isLoading
          ? _buildLoadingEffect()
          : events.isEmpty
            ? _buildEmptyState()
            : _buildEventList()
    );
  }

  Widget _buildLoadingEffect(){
    return ListView.builder(
        padding: EdgeInsets.all(12),
        itemCount: 5,
        itemBuilder: (context,index){
          return Card(
            margin: EdgeInsets.symmetric(
              vertical: 8,
              horizontal: 16,
            ),
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              title: Container(
                height: 16,
                color:Colors.grey[300],
              ),

              subtitle: Container(
                height: 12,
                color:Colors.grey[200],
                margin: EdgeInsets.only(top: 6),
              ),

              trailing: Container(
                height: 12,
                width: 60,
                color:Colors.grey[200],
              ),

            ),
          );
        }
    );
  }

  Widget _buildEmptyState(){
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.event_note,
            size: 80,
            color: Colors.blue[300],
          ),
          SizedBox(
            height: 10,
          ),
          Text(
            'No Events Available...',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.blueGrey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventList() {

    final role = Provider.of<UserProvider>(context, listen: false).role;

    List<Map<String, dynamic>> createdEvents = events.where((
        event) => event['status'] == 'available').toList();
    List<Map<String, dynamic>> acceptedEvents = events.where((
        event) => event['status'] == 'accepted').toList();
    List<Map<String, dynamic>> pendingEvents = events.where((
        event) => event['status'] == 'pending').toList();

    return ListView(
      children: [
        if(role == 'teacher')...[
          _buildEventCard('Pending events', pendingEvents),
          _buildEventCard('Accepted events', acceptedEvents),
          _buildEventCard('Created events', createdEvents)
        ]else if(role == 'student')...[
          _buildEventCard('Waiting for confirmation', pendingEvents),
          _buildEventCard('Your accepted events', acceptedEvents),
        ]
      ],
    );
  }

  Widget _buildEventCard(String title, List<Map<String, dynamic>> events){
    if(events.isEmpty) return SizedBox.shrink();

    return Card(
      margin: EdgeInsets.all(12),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Divider(),
            ListView.builder(
                itemCount: events.length,
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemBuilder: (context , index){
                  final event = events[index];
                  return _buildEventItem(event);
                }
            )
          ],
        ),
      ),
    );


  }

  Widget _buildEventItem(Map<String, dynamic> event){
    final role = Provider.of<UserProvider>(context, listen: false).role;
    final formattedDate = DateFormat('dd/MM/yyyy HH:mm', 'es_ES').format(event['start_time']);
    Color statusColor;
    if(event['status'] == 'pending'){
      statusColor = Colors.orange;
    }else if(event['status'] == 'accepted'){
      statusColor = Colors.blue;
    }else{
      statusColor = Colors.green;
    }
    return ListTile(
      contentPadding: EdgeInsets.symmetric(
        vertical: 8,
      ),
      leading: CircleAvatar(
        backgroundColor: statusColor,
        child: Icon(
          Icons.event,
          color: Colors.white,
        ),
      ),
      title: Text(
        event['title'],
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            event['description'],
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 5,),
          Text(
            formattedDate,
            style: TextStyle(
              fontSize: 12,
              color: Colors.blueGrey,
            ),
          ),
        ],
      ),
      trailing: Text(
        event['status'].toUpperCase(),
        style: TextStyle(
            fontWeight: FontWeight.bold,
            color: statusColor
        ),
      ),
      onTap: () async {
        if(event['status'] == 'pending' && role == 'teacher' ){
          _showConfirmButton(context, event);
        }else{
          final update = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EventDetailScreen(event: event),
            ),
          );
          if (update != null) {
            await _fetchEvents();
          }
        }
      },
    );

  }

  void _showConfirmButton(BuildContext context, Map<String, dynamic> event){
    showDialog(
        context: context,
        builder: (BuildContext context){
          return AlertDialog(
            title: Text('Confirm class?'),
            content: Text('Are you sure you want to do this class?'),
            actions: [
              TextButton(
                  onPressed: (){
                    Navigator.pop(context);
                  },
                  child: Text('Cancel')
              ),
              ElevatedButton(
                  onPressed: ()async{
                    await _confirmEvent(event['id']);
                    Navigator.pop(context);
                    await _fetchEvents();
                  },
                  child: Text('Confirm'),
              )
            ],
          );
        }
    );
  }

  Future<void> _confirmEvent(int eventId)async{
    try{
      final conn = await MySQLHelper.connect();
      await conn.query(
        'UPDATE events SET status = "accepted" WHERE id = ?',
        [eventId]
      );
      await conn.close();
      print('Evento confirmado con id = $eventId');
    }catch(e){
      print('No se pudo aceptar el evento = $e');
    }
  }

}




