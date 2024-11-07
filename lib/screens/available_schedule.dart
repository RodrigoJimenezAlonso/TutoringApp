import '../models/schedule.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AvailableSchedule extends StatelessWidget {
  final String professorId;

  AvailableSchedule({
    required this.professorId,
  });

  Future<void> _bookSchedule(Schedule schedule, BuildContext context) async {
    try {
      final response = await Supabase.instance.client
          .from('schedules')
          .update({'isBooked': true})
          .eq('id', schedule.id)
          .maybeSingle();

      if (response == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Booked unsuccessfully')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Booked successfully')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Booking unsuccessful: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Available Schedule'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _fetchSchedules(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          final response = snapshot.data;

          if (response == null || response.isEmpty) {
            return const Center(child: Text('No schedules available'));
          }

          final schedules = response.map((data) {
            return Schedule.fromMap(data['id'], data as Map<String, dynamic>);
          }).toList();

          return ListView.builder(
            itemCount: schedules.length,
            itemBuilder: (context, index) {
              final schedule = schedules[index];
              return ListTile(
                title: Text(
                  '${DateFormat.yMd().format(schedule.date)}: '
                      '${schedule.startTime.format(context)}-'
                      '${schedule.endTime.format(context)}',
                ),
                trailing: ElevatedButton(
                  onPressed: () => _bookSchedule(schedule, context),
                  child: const Text('Book'),
                ),
              );
            },
          );
        },
      ),
    );
  }
  Future<List<Map<String, dynamic>>> _fetchSchedules()async{
    try{
      final response = await Supabase.instance.client
          .from('schedules')
          .select('*')
          .eq('professorId', professorId)
          .eq('isBooked', false);
      return response as List<Map<String, dynamic>>;
    }catch(e){
      print('error fetching schedules: $e');
      return [];
    }
  }
}