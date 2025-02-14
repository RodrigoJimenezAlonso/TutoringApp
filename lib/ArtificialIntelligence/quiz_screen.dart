import 'package:flutter/material.dart';
import 'chatgpt_service.dart';
import 'beginner_class_screen.dart';
import 'intermediate_class_screen.dart';
import 'advanced_class_screen.dart';
import 'dart:convert';

class QuizScreen extends StatefulWidget {
  @override
  _QuizScreenState createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  final ChatGPTService chatGPTService = ChatGPTService();
  List<String> questions = [];
  List<String> answers = [];
  int currentQuestionIndex = -1;
  String response = "";
  TextEditingController answerController = TextEditingController();
  bool isLoading = false;
  String userTopic = "";

  @override
  void initState() {
    super.initState();
    _askUserInterest();
  }

  /// **1️⃣ Preguntar al usuario qué quiere aprender**
  void _askUserInterest() async {
    setState(() => isLoading = true);

    try {
      String prompt = "Pregúntale al usuario qué tema quiere aprender.";
      String chatResponse = await chatGPTService.getResponse(prompt);

      setState(() {
        response = chatResponse.isNotEmpty ? chatResponse : "¿Qué tema te gustaría aprender?";
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        response = "Error al conectar con ChatGPT. Intenta de nuevo.";
        isLoading = false;
      });
    }
  }

  /// **2️⃣ Generar preguntas basadas en el tema elegido**
  void generateQuestions(String topic) async {
    if (topic.trim().isEmpty) return;

    setState(() {
      isLoading = true;
      userTopic = topic;
    });

    try {
      String prompt = "Genera una lista de 5 preguntas en JSON para evaluar el nivel en $topic. Usa solo formato JSON sin explicaciones. Ejemplo: [\"Pregunta 1\", \"Pregunta 2\"]";
      String chatResponse = await chatGPTService.getResponse(prompt);

      List<String> generatedQuestions = _parseQuestions(chatResponse);

      if (generatedQuestions.isNotEmpty) {
        setState(() {
          questions = generatedQuestions;
          currentQuestionIndex = 0;
          isLoading = false;
        });
      } else {
        setState(() {
          response = "No se pudieron generar preguntas. Intenta otro tema.";
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        response = "Error al generar preguntas. Intenta de nuevo.";
        isLoading = false;
      });
    }
  }

  /// **3️⃣ Extraer preguntas del JSON**
  List<String> _parseQuestions(String jsonString) {
    try {
      List<dynamic> parsedList = jsonDecode(jsonString);
      return parsedList.cast<String>(); // Convertir dinámico a String
    } catch (e) {
      print("Error al parsear preguntas: $e");
      return [];
    }
  }

  /// **4️⃣ Avanzar a la siguiente pregunta**
  void nextQuestion() async {
    if (answerController.text.trim().isEmpty) return;

    setState(() {
      answers.add(answerController.text);
      answerController.clear();
      currentQuestionIndex++;
    });

    if (currentQuestionIndex == questions.length) {
      setState(() => isLoading = true);

      try {
        String prompt = "Evalúa mi nivel en $userTopic con estas respuestas:\n";
        for (int i = 0; i < questions.length; i++) {
          prompt += "${questions[i]} - Respuesta: ${answers[i]}\n";
        }
        prompt += "Dime mi nivel (principiante, intermedio o avanzado).";

        String chatResponse = await chatGPTService.getResponse(prompt);

        setState(() {
          response = chatResponse;
          isLoading = false;
        });

        // **5️⃣ Redirigir a la clase correspondiente**
        Future.delayed(Duration(seconds: 2), () {
          if (response.toLowerCase().contains("principiante")) {
            Navigator.push(context, MaterialPageRoute(builder: (context) => BeginnerClassScreen()));
          } else if (response.toLowerCase().contains("intermedio")) {
            Navigator.push(context, MaterialPageRoute(builder: (context) => IntermediateClassScreen()));
          } else {
            Navigator.push(context, MaterialPageRoute(builder: (context) => AdvancedClassScreen()));
          }
        });
      } catch (e) {
        setState(() {
          response = "Error al evaluar tu nivel. Intenta de nuevo.";
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Evaluación de Nivel")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: isLoading
            ? Center(child: CircularProgressIndicator())
            : Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (currentQuestionIndex == -1) ...[
              Text(response, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              TextField(controller: answerController, decoration: InputDecoration(labelText: "Escribe tu tema")),
              ElevatedButton(
                  onPressed: () {
                    if (answerController.text.trim().isNotEmpty) {
                      generateQuestions(answerController.text);
                      answerController.clear();
                    }
                  },
                  child: Text("Continuar")),
            ] else if (currentQuestionIndex < questions.length) ...[
              Text(questions[currentQuestionIndex], style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              TextField(controller: answerController),
              ElevatedButton(onPressed: nextQuestion, child: Text("Siguiente")),
            ] else ...[
              Text("Tu nivel es:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Text(response, style: TextStyle(fontSize: 20, color: Colors.blue)),
            ],
          ],
        ),
      ),
    );
  }
}
