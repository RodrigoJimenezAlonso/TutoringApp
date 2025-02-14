import 'dart:convert';
import 'package:http/http.dart' as http;

class ChatGPTService {
  final String apiKey = "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"; // Usa una clave segura
  final String apiUrl = "https://api-inference.huggingface.co/models/facebook/blenderbot-400M-distill";

  Future<String> getResponse(String prompt) async {
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          "Authorization": "Bearer $apiKey",
          "Content-Type": "application/json",
        },
        body: jsonEncode({"inputs": prompt}),  // Solo envía `inputs`, no `model` ni `messages`
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data["generated_text"] ?? "No recibí respuesta.";
      } else {
        print("Error en la API: ${response.body}");
        return "Error al conectar con Hugging Face.";
      }
    } catch (e) {
      print("Excepción en Hugging Face API: $e");
      return "No se pudo conectar con Hugging Face.";
    }
  }
}
