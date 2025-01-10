import 'package:flutter/material.dart';

class StudentProfileScreen extends StatelessWidget{
  @override
  Widget build(BuildContext context){
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

          TextField(
            decoration: InputDecoration(
                labelText: 'Email'
            ),
          ),

          TextField(
            decoration: InputDecoration(
                labelText: 'CAMBIAR CONTRASEÑA'
            ),
          ),

          SizedBox(
            height: 10,
          ),

        ],
      ),
    );
  }
}