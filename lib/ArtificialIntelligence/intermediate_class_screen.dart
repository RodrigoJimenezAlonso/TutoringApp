import 'package:flutter/material.dart';

class IntermediateClassScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Clase Intermedia")),
      body: Center(
        child: Text(
          "Bienvenido a la clase intermedia",
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
