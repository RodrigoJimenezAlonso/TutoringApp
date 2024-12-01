import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:proyecto_rr_principal/mysql.dart';
import '../models/schedule.dart';
import '../screens/schedule_form.dart';

class ProfessorSchedule extends StatelessWidget{

final String professorId;
ProfessorSchedule({
  required this.professorId,
});


Future<void> _deleteSchedule(BuildContext context, String scheduleID)async{
  final messenger = ScaffoldMessenger.of(context);

  try{
    final conn = await MySQLHelper.connect();
    await conn.query(
        'DELETE FROM schedules WHERE id = ?',
        [scheduleID]
    );

    await conn.close();
    messenger.showSnackBar(
      const SnackBar(content: Text('Schedule has been eliminated successfully')),
    );
  }catch(e){
    messenger.showSnackBar(
      const SnackBar(content: Text('Schedule has not been eliminated')),
    );
  }
}


Future<List<Schedule>> _professorSchedule()async{
  final conn = await MySQLHelper.connect();
  final result = await conn.query(
    'SELECT id ,date, start_time, end_time FROM schedules WHERE professor_id = ?',
    [professorId],
  );

  await conn.close();
  return result.map((row){
    return Schedule.fromMap({
      'id': row['id'],
      'date': row['date'],
      'startTime': row['start_time'],
      'endTime': row['end_time'],
    });
  }).toList();
}
  @override

  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Schedule'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: (){
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context)=> ScheduleForm(professorId: professorId),)
              );
            },
          ),
        ],
      ),
      body: FutureBuilder(
        future: _professorSchedule(),
        builder: (context, snapshot){
          if(snapshot.connectionState == ConnectionState.waiting){
            return const Center(child: CircularProgressIndicator());
          }
          if(snapshot.hasError){
            return Center(child: Text('error: ${snapshot.error}'),);
          }
          if(!snapshot.hasData || snapshot.data!.isEmpty){
            return const Center(child: Text('not found schedules'),);
          }
          final List<Schedule> schedules = snapshot.data as List<Schedule>;
          return ListView.builder(
              itemCount: schedules.length,
              itemBuilder: (context, index){
                final schedule = schedules[index];
                return ListTile(
                  title: Text(
                      '${DateFormat.yMd().format(schedule.date)}:${schedule.startTime.format(context)}-${schedule.endTime.format(context)}'
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () async{
                      await _deleteSchedule(context, schedule.id);

                    },
                  ),
                );
              },
          );
        },
      ),
    );
  }
}