import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:proyecto_rr_principal/auth/login_page.dart';
import 'package:proyecto_rr_principal/date_time_picker.dart';
import 'package:proyecto_rr_principal/screens/NavigationBar/booking_screen.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:shared_preferences/shared_preferences.dart';


class TeacherProfileScreen extends StatelessWidget{
  @override
  Widget build(BuildContext context){

    void _logOut()async{
      final prefs = await SharedPreferences.getInstance();
      prefs.setBool('isLoggedIn', false);

      Navigator.pushReplacement(context, MaterialPageRoute(
        builder: (context)=>LoginPage(),
      ));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Teacher Profile'),
      ),
      body: Column(
        children: [
          TextField(
            decoration: InputDecoration(
              labelText: 'Name'
            ),
          ),

          TextField(
            decoration: InputDecoration(
                labelText: 'Description'
            ),
          ),

          SizedBox(
            height: 10,
          ),

          Expanded(
              child: TableCalendar(
                  focusedDay: DateTime.now(),
                  firstDay: DateTime.now(),
                  lastDay: DateTime.now().add(Duration(days: 365)),

                  onDaySelected: (selectedDay, focusedDay){
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_)=> EventReservationScreen(selectedDay),
                        ),
                    );
                  }
              ),
          ),

          /*ElevatedButton(
              onPressed: _logOut(),
              child: Text('Log Out'),
          ),*/
        ],
      ),
    );
  }
}


class EventReservationScreen extends StatelessWidget{
  final DateTime selectedDay;
  EventReservationScreen(this.selectedDay);



  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: Text('Book Event'),
      ),
      body: Center(
        child: Text('Book event for: $selectedDay'),
      ),
    );
  }
}
