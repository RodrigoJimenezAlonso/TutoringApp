import 'package:flutter/material.dart';

class BeginnerClassScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Clase para Principiantes")),
      body: Center(
        child: Text(
          "Bienvenido a la clase para principiantes",
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
