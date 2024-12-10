import '../models/schedule.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:proyecto_rr_principal/mysql.dart';

class AvailableSchedule extends StatelessWidget {
  final String professorId;

  AvailableSchedule({
    required this.professorId,
  });

  Future<void> _bookSchedule(Schedule schedule, BuildContext context) async {
    try {
      final conn = await MySQLHelper.connect();
      final result = await conn.query(
          'UPDATE schedules SET isBooked = ? WHERE id = ?',
          [
            true, schedule.id
          ],
      );
      if(result.affectedRows == 0){
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Unsuccessfully booked')
          )
        );
      }else{
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Successfully booked')
            )
        );
      }
      await conn.close();
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
      final conn = await MySQLHelper.connect();
      final result = await conn.query(
          'SELECT * FROM schedules WHERE professorId = ? AND isBooked = ?',
          [
            professorId, false
          ],
      );
      final schedules = result.map((row)=> row.fields).toList();
      await conn.close();
      return schedules;
    }catch(e){
      print('error fetching schedules: $e');
      return [];
    }
  }
}