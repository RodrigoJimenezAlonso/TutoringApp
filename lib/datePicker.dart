import 'package:flutter/material.dart';

class DatePicker extends StatefulWidget {
  @override
  _DatePicker createState() => _DatePicker();
}

class _DatePicker extends State<DatePicker> {

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null) {
      // Show the time picker after selecting the date
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(DateTime.now()),
      );

      if (pickedTime != null) {
        // Combine the date and time
        final DateTime selectedDateTime = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          pickedTime.hour,
          pickedTime.minute,
        );

        // Return the selected date and close the widget
        Navigator.of(context).pop(selectedDateTime);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ElevatedButton(
        onPressed: () => _selectDate(context),
        child: Text('Pick a date'),
      ),
    );
  }
}