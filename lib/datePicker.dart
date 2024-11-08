import 'package:flutter/material.dart';


class DatePicker extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: ElevatedButton(
        onPressed: () async {
          final DateTime? pickedDate = await showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime(2000),
            lastDate: DateTime(2101),
          );

          if (pickedDate != null) {
            // Mostrar el selector de tiempo después de seleccionar la fecha
            final TimeOfDay? pickedTime = await showTimePicker(
              context: context,
              initialTime: TimeOfDay.fromDateTime(DateTime.now()),
            );

            if (pickedTime != null) {
              // Combinar la fecha y la hora
              final DateTime selectedDateTime = DateTime(
                pickedDate.year,
                pickedDate.month,
                pickedDate.day,
                pickedTime.hour,
                pickedTime.minute,
              );

              // Devolver la fecha seleccionada y cerrar el widget
              Navigator.of(context).pop(selectedDateTime);
            }
          }
        },
        child: Text('Pick a date and time'),
      ),
    );
  }
}
