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

  Future<void> _fetchAvailability() async{
    final conn = await MySQLHelper.connect();
    final result = await conn.query(
      'SELECT * FROM availability WHERE teacher_id = ? AND status = "available" ORDER BY date, start_time',
      [widget.teacherId],
    );
    print('result: $result');
    await conn.close();
    final events = <DateTime, List<NeatCleanCalendarEvent>> {};
    for(var row in result){
      final date = (row['date'] as DateTime).toLocal();
      final startTime = row['start_time'] as Duration;
      final endTime = row['end_time'] as Duration;
      final availabilityId = row['id'];

      final eventStartTime = DateTime(
        date.year,
        date.month,
        date.day,
      ).add(startTime);

      final eventEndTime = DateTime(
        date.year,
        date.month,
        date.day,
      ).add(endTime);

      final event = NeatCleanCalendarEvent(
        'Available Slot',
        startTime: eventStartTime,
        endTime: eventEndTime,
        description: availabilityId.toString(),
        color: Colors.blue,
      );

      if(!events.containsKey(date)){
        events[date] = [];
      }
      events[date]!.add(event);
    }
    setState(() {
      _events = events;
    });
  }

  Future<void> _bookClass(int availabilityId)async{
    final conn = await MySQLHelper.connect();
    try{
      await conn.query(
        'UPDATE availability SET status = "booked" WHERE id = ?',
        [availabilityId],
      );
      await conn.close();
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Class Successfully Booked!'),
          )
      );
      await _fetchAvailability();
    }catch(e){
      print('Error Booking Class $e');
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error Booking Class, please try again!'),
          )
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