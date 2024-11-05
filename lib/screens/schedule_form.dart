import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import '../models/schedule.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ScheduleForm extends StatefulWidget{
  final String professorId;
  ScheduleForm({
    required this.professorId,
});

  @override
  _ScheduleFormState createState() => _ScheduleFormState();
}
class _ScheduleFormState extends State<ScheduleForm>{
  final _formKey = GlobalKey<FormState>();
  DateTime? _selectedDate;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;

  Future<void> _saveSchedule() async{
    if(_formKey.currentState?.validate()?? false){
      final schedule = Schedule(
        id: '',
        professorId: widget.professorId,
        date: _selectedDate!,
        startTime: _startTime!,
        endTime: _endTime!,
      );
      try{

        final response = await Supabase.instance.client
          .from('schedules')
          .insert(schedule.toMap());
        if(response.error != null){
          throw response.error!;
        }

        Navigator.pop(context);
      }catch(e){
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Error on saving Schedule: $e'),
          )
        );
      }

    }

  }

  DateTime _convertTimeOfDayToDateTime(TimeOfDay time){
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day, time.hour, time.minute);
  }

  @override

  Widget build(BuildContext context){

    return Scaffold(
      appBar: AppBar(
        title: const Text('add available schedule'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'select a date'),
                readOnly: true,
                onTap: ()async{
                  final selectedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(Duration(days: 365)),
                  );
                  if(selectedDate != null){
                    setState(() {
                      _selectedDate = selectedDate;
                    });
                  }
                },
                validator: (value){
                  if(_selectedDate == null){
                    return 'please select a date';
                  }
                  return null;
                },
                controller: TextEditingController(
                  text: _selectedDate != null
                      ? DateFormat.yMd().format(_selectedDate!)
                      : '',
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Start Time'),
                readOnly: true,
                onTap: ()async{
                  final selectedTime = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.now(),
                  );
                  if(selectedTime != null){
                    setState(() {
                      _startTime = selectedTime;
                    });
                  }
                },
                validator: (value){
                  if(_endTime == null){
                    return 'please select an end time';
                  }else if(_startTime != null && _convertTimeOfDayToDateTime(_endTime!)
                  .isBefore(_convertTimeOfDayToDateTime(_startTime!))){
                    return 'end time must be after the start time';
                  }
                  return null;
                },
                controller: TextEditingController(
                  text: _startTime != null
                      ? _startTime!.format(context)
                      : '',
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                decoration: const InputDecoration(labelText: 'End Time'),
                readOnly: true,
                onTap: ()async{
                  final selectedTime = await showTimePicker(
                    context: context,
                    initialTime: _startTime?? TimeOfDay.now(),
                  );
                  if(selectedTime != null){
                    setState(() {
                      _endTime = selectedTime;
                    });
                  }
                },
                validator: (value){
                  if(_endTime == null){
                    return 'please select a start time';
                  }else if(_startTime != null && _convertTimeOfDayToDateTime(_endTime!)
                      .isBefore(_convertTimeOfDayToDateTime(_startTime!)) ){
                    return "the final time must be after the beginning time";
                  }
                  return null;
                },
                controller: TextEditingController(
                  text: _endTime != null
                      ? _endTime!.format(context)
                      : '',
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                  onPressed: _saveSchedule,
                  child: const Text('save schedule'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}



