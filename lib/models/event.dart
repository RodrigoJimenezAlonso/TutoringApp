import 'package:flutter/material.dart';

class Event{
  final String id;
  final String title;
  final String description;
  final String? location;
  final DateTime startTime;
  final DateTime endTime;

  Event({
    required this.id,
    required this.title,
    required this.description,
    required this.startTime,
    required this.endTime,
    this.location,
  });

  factory Event.fromMap(Map<String, dynamic> map){
    return Event(
        id: map['id'],
        title: map['title'],
        description: map['description'],
        location: map['location'],
        startTime: DateTime.parse(map['startTime']),
        endTime: DateTime.parse(map['endTime'])
    );
  }

  Map<String, dynamic> toMap(){
    return {
      'id': id,
      'location': location,
      'description': description,
      'title': title,
      'endTime': endTime.toIso8601String(),
      'startTime': startTime.toIso8601String(),
    };
  }


}

