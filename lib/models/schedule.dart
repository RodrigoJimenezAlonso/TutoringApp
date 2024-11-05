import 'package:flutter/material.dart';

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

  Map<String, dynamic> toMap(){
    return {
      'professorId': professorId,
      'date': date.toIso8601String(),
      'startTime': '${startTime.hour.toString().padLeft(2,'0')}:${startTime.minute.toString().padLeft(2,'0')}',
      'endTime': '${endTime.hour.toString().padLeft(2,'0')}: ${endTime.minute.toString().padLeft(2,'0')}',
      'isBooked': isBooked,
    };
  }

  static Schedule fromMap(String id, Map<String, dynamic> map){
    final timeParts = map['startTime'].split(':');
    final endTimeParts = map['endTime'].split(':');

    return Schedule(
      id: id,
      professorId: map['professorId'],
      date: DateTime.parse(map['date']),
      startTime: TimeOfDay(
        hour: int.parse(timeParts[0]),
        minute: int.parse(timeParts[1]),
      ),
      endTime: TimeOfDay(
        hour: int.parse(endTimeParts[0]),
        minute: int.parse(endTimeParts[1]),
      ),
      isBooked: map['isBooked']??false,
    );


  }

}