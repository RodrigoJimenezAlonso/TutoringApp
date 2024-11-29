import 'package:flutter/material.dart';
import 'package:proyecto_rr_principal/mysql.dart';

class Schedule{
  final String id;
  final String professorId;
  final DateTime date;
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final bool isBooked;

  Schedule({
    required this.id,
    required this.professorId,
    required this.date,
    required this.startTime,
    required this.endTime,
    this.isBooked = false,
  });



  factory Schedule.fromMap(Map<String, dynamic> map){
    final startTimeParts = map['startTime'].split(':');
    final endTimeParts = map['endTime'].split(':');

    return Schedule(
      id: map['id'],
      professorId: map['professor_id'],
      date: DateTime.parse(map['date']),
      startTime: TimeOfDay(
      hour: int.parse(startTimeParts[0]),
      minute: int.parse(startTimeParts[1]),
    ),
      endTime: TimeOfDay(
        hour: int.parse(endTimeParts[0]),
        minute: int.parse(endTimeParts[1]),
      ),
      isBooked: map['isBooked'] == 1,
    );
  }

  Map<String, dynamic> toMap(){
    return {
      'id': id,
      'professorId': professorId,
      'date': date.toIso8601String(),
      'startTime': '${startTime.hour.toString().padLeft(2,'0')}:${startTime.minute.toString().padLeft(2,'0')}',
      'endTime': '${endTime.hour.toString().padLeft(2,'0')}: ${endTime.minute.toString().padLeft(2,'0')}',
      'isBooked': isBooked ? 1 : 0,
    };
  }

  static Future<List<Schedule>> fetchSchedules() async{
    final conn = await MySQLHelper.connect();
    final result = await conn.query(
        'SELECT * FROM schedules',
    );

    return result.map((row){
      return Schedule.fromMap(row.fields);
    }).toList();


  }
  static Future<void> addSchedule(Schedule schedule) async{
    final conn = await MySQLHelper.connect();
    await conn.query(
      'INSERT INTO schedules(id, professor_id, date, start_time, end_time, is_booked) VALUES(?,?,?,?,?,?)',
      [
        schedule.id,
        schedule.professorId,
        schedule.date.toIso8601String(),
        '${schedule.startTime.hour.toString().padLeft(2,'0')}: ${schedule.startTime.minute.toString().padLeft(2,'0')}',
        '${schedule.endTime.hour.toString().padLeft(2,'0')}: ${schedule.endTime.minute.toString().padLeft(2,'0')}',
        schedule.isBooked ? 1 : 0,
      ]
    );
  }
}