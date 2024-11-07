import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/schedule.dart';
import '../screens/schedule_form.dart';

class ProfessorSchedule extends StatelessWidget{

final String professorId;
ProfessorSchedule({
  required this.professorId,
});
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
        future: Supabase.instance.client
            .from('schedules')
            .select()
            .eq('professorId', professorId),
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
          final List<Schedule> schedules = (snapshot.data! as List<dynamic>)
              .map((doc){
                final Map<String, dynamic> scheduleData = doc as Map<String, dynamic>;
                return Schedule.fromMap(scheduleData['id'], scheduleData);
          }).toList();
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
                      final response = await Supabase.instance.client
                          .from('schedules')
                          .delete()
                          .eq('id', schedule.id);
                      if(response.error != null){
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Failed to delete Schedule: ${response.error!.message}'))
                        );
                      }

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