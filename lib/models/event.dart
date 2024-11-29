class Event {
  final String id;
  final String title;
  final String description;
  final DateTime startTime;
  final DateTime endTime;
  final String userId; // Campo para el user_id

  Event({
    required this.id,
    required this.title,
    required this.description,
    required this.startTime,
    required this.endTime,
    required this.userId, // Inicializa el user_id
  });

  // Convierte el evento a un Map para insertar en la base de datos
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'start_time': startTime.toIso8601String(),
      'end_time': endTime.toIso8601String(),
      'user_id': userId, // Incluye el user_id en el Map
    };
  }

  // Crea una instancia de Event a partir de un Map (usado al cargar eventos de la base de datos)
  static Event fromMap(Map<String, dynamic> map) {
    return Event(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      startTime: DateTime.parse(map['start_time']),
      endTime: DateTime.parse(map['end_time']),
      userId: map['user_id'], // Obtén el user_id desde el Map
    );
  }
}
