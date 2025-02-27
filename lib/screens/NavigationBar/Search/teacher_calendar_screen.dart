import 'package:flutter/material.dart';
import 'package:proyecto_rr_principal/mysql.dart';
import 'package:flutter_neat_and_clean_calendar/flutter_neat_and_clean_calendar.dart';
import '../chat/chat_screen.dart';


class TeacherCalendarScreen extends StatefulWidget {
  final int teacherId;
  final int alumnoId;

  TeacherCalendarScreen({
    required this.teacherId,
    required this.alumnoId,
  });

  @override
  _TeacherCalendarScreenState createState()=> _TeacherCalendarScreenState();

}

class _TeacherCalendarScreenState extends State<TeacherCalendarScreen>{

  Map<DateTime, List<NeatCleanCalendarEvent>> _events = {};

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

      print('Consulta ejecutada para el teacherId: ${widget.teacherId}');
      print('Número de eventos encontrados: ${result.length}');

      if (result.isEmpty) {
        print('No se encontraron eventos disponibles para este profesor.');
      }

      await conn.close();

      final events = <DateTime, List<NeatCleanCalendarEvent>>{};

      for (var row in result) {
        final startTime = row['start_time'] as DateTime;
        final endTime = row['end_time'] as DateTime;
        final availabilityId = row['id'];
        final eventStatus = row['status'];

        /*if(endTime.isBefore(DateTime.now())){
          if(eventStatus != 'finished'){
            await conn.query(
              'UPDATE events SET status = "finished" WHERE id = ?',
              [
                availabilityId
              ]
            );
          }
        }*/

        final event = NeatCleanCalendarEvent(
          'Available Slot',
          startTime: startTime,
          endTime: endTime,
          description: availabilityId.toString(),
          color: Colors.blue,
        );

        final eventDate = DateTime(startTime.year, startTime.month, startTime.day);

        if (!events.containsKey(eventDate)) {
          events[eventDate] = [];
        }
        events[eventDate]!.add(event);
      }

      print('Eventos cargados antes de setState: ${events.length}');

      setState(() {
        _events = events;
      });

    } catch (e) {
      print('Error al obtener la disponibilidad: $e');
    }
  }


  Future<void> _bookClass(int availabilityId) async {
    try {
      final conn = await MySQLHelper.connect();
      print('Actualizando el estado del evento con id: $availabilityId');

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

      setState(() {
      });

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
  void initState(){
    super.initState();
    _fetchAvailability();
  }



  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: Text('Teacher Availability'),
      ),
      body: SafeArea(
        child: _events.isEmpty
            ? Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
          child: Column(
            children: [
              Calendar(
                startOnMonday: true,
                weekDays: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'],
                eventsList: _events.entries
                    .expand((entry) => entry.value)
                    .toList(),
                isExpandable: true,
                eventDoneColor: Colors.green,
                selectedColor: Colors.purple,
                todayColor: Colors.red,
                eventColor: Colors.grey,
                locale: 'en_US',
                todayButtonText: 'Today',
                allDayEventText: 'All Day',
                multiDayEndText: 'End',
                isExpanded: true,
                eventListBuilder: (BuildContext context,
                    List<NeatCleanCalendarEvent> events) {
                  return ListView.builder(
                    physics: NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: events.length,
                    itemBuilder: (context, index) {
                      final event = events[index];
                      final availabilityId =
                      int.tryParse(event.description ?? '');
                      return ListTile(
                        title: Text(event.summary),
                        subtitle: Text(
                            '${event.startTime.hour}:${event.startTime.minute.toString().padLeft(2, '0')} - ${event.endTime.hour}:${event.endTime.minute.toString().padLeft(2, '0')}'),
                        trailing: ElevatedButton(
                          onPressed: availabilityId != null
                              ? () => _bookClass(availabilityId)
                              : null,
                          child: Text('Book'),
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: (){
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context)=>ChatScreen(
                  alumnoId: widget.alumnoId,
                  profesorId: widget.teacherId,
                ),
              )
          );
        },
        child: Icon(Icons.chat),
        backgroundColor: Colors.blue,
        tooltip: 'Chat With Teacher',
      ),
    );

  }
}