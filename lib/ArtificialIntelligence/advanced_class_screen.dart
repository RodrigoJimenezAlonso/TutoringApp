import 'package:flutter/material.dart';

class AdvancedClassScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Clase Avanzada")),
      body: Center(
        child: Text(
          "Bienvenido a la clase avanzada",
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
