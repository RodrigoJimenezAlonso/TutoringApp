import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:proyecto_rr_principal/mysql.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BookingScreen extends StatelessWidget{
  Future<int?> _getStudentId()async{
  final prefs = await SharedPreferences.getInstance();
  return prefs.getInt(
    'student_id'
  );
}
  @override
  Widget build(BuildContext context){
    return FutureBuilder<int?>(
        future: _getStudentId(),
        builder: (context, snapshot){
          if(!snapshot.hasData){
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          final studentId = snapshot.data;
          if(studentId == null){
            return Center(
              child: Text('Student Id Not Found'),
            );
          }

          return FutureBuilder<List<Map<String, dynamic>>>(
              future: _obtenerReserva(studentId),
              builder: (context, snapshot){
                if(!snapshot.hasData){
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }
                final reservas = snapshot.data;
                return ListView.builder(
                  itemCount: reservas?.length,
                  itemBuilder: (context, index){
                    final reserva = reservas?[index];
                    return ListTile(
                      title: Text('Event: ${reserva?['event_id']}'),
                      subtitle: Text('Status: ${reserva?['state']}'),
                    );
                  },
                );
              }
          );
        }
    );
  }

  Future<List<Map<String, dynamic>>> _obtenerReserva(int alumnoId)async{

    try{
      final conn = await MySQLHelper.connect();
      final result = await conn.query('SELECT * FROM bookings WHERE student_id = ?', [alumnoId]);
      return result.map((row)=> row.fields).toList();
    }catch(e){
      print('Error on Booking Screen.dart: $e');
      return [];
    }


  }


}