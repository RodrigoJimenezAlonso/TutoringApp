import 'package:flutter/material.dart';
import '../../../mysql.dart';

class EventAutomationPage extends StatefulWidget {
  final int userId;
  EventAutomationPage({required this.userId});

  @override
  _EventAutomationPageState createState() => _EventAutomationPageState();
}

class _EventAutomationPageState extends State<EventAutomationPage> {
  final List<String> _days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
  final List<bool> _selectedDays = List.generate(7, (index) => false);
  TimeOfDay _startTime = TimeOfDay(hour: 9, minute: 0);
  int _numHours = 1;
  List<Map<String, dynamic>> _scheduledClasses = [];

  void _pickStartTime(BuildContext context) async {
    TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _startTime,
    );
    if (picked != null) {
      setState(() {
        _startTime = picked;
      });
    }
  }

  Future<void> _generateClasses() async {
    final conn = await MySQLHelper.connect();
    DateTime today = DateTime.now();
    DateTime startDate = today;

    for (int week = 0; week < 10; week++) {
      for (int i = 0; i < _days.length; i++) {
        if (_selectedDays[i]) {
          DateTime classDate = startDate.add(Duration(days: (i - today.weekday + 1) % 7 + (week * 7)));
          for (int j = 0; j < _numHours; j++) {
            DateTime eventStartTime = DateTime(
                classDate.year,
                classDate.month,
                classDate.day,
                _startTime.hour + j,
                _startTime.minute
            );
            DateTime eventEndTime = eventStartTime.add(Duration(hours: 1));

            await conn.query(
              'INSERT INTO events (user_id, title, description, start_time, end_time, is_automated, status, student_id) VALUES (?, ?, ?, ?, ?, ?, ?, ?)',
              [
                widget.userId,
                'Available class slot',
                'Click to book this meeting!',
                eventStartTime.toIso8601String(),
                eventEndTime.toIso8601String(),
                1,
                'available',
                null
              ],
            );
          }
        }
      }
    }
    await _loadEvents();
    if (mounted) {
      Navigator.pop(context, true);
    }


  }

  Future<void> _loadEvents() async {
    final conn = await MySQLHelper.connect();
    final results = await conn.query(
        'SELECT * FROM events WHERE user_id = ? AND is_automated = 1',
        [
          widget.userId
        ],
    );

    _scheduledClasses = results.map((row) {
      String startTime = row['start_time'].toString();
      List<String> dateTimeParts = startTime.contains('T') ? startTime.split('T') : [startTime, '00:00'];
      return {
        'date': dateTimeParts[0],
        'time': dateTimeParts.length > 1 ? dateTimeParts[1].substring(0, 5) : '00:00',
      };
    }).toList();

    await conn.close();
    setState(() {});
  }

  Future<void> _clearAutomatedClasses() async {
    final conn = await MySQLHelper.connect();
    await conn.query(
        'DELETE FROM events WHERE user_id = ? AND is_automated = 1',
        [
          widget.userId
        ],
    );
    await conn.close();
    await _loadEvents();
    await _loadEvents();
    if (mounted) {
      Navigator.pop(context, true); // Envía "true" para indicar que se debe recargar
    }
  }

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        automaticallyImplyLeading: true,
        title: Text("Event Automation"),
        backgroundColor: Colors.grey[100],
        foregroundColor: Colors.black,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
                "Select the days for the events:",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16
                )
            ),
            SizedBox(height: 10,),
            Wrap(
              spacing: 8.0,
              children: List.generate(_days.length, (index) {
                return FilterChip(
                  label: Text(
                      _days[index],
                      style: TextStyle(
                          color: _selectedDays[index] ? Colors.white : Colors.black
                      ),
                  ),
                  selected: _selectedDays[index],
                  onSelected: (bool selected) {
                    setState(() {
                      _selectedDays[index] = selected;
                    });
                  },
                  selectedColor: Colors.blue,
                  backgroundColor: Colors.white,
                );
              }),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Start Time:",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16
                  ),
                ),
                ElevatedButton(
                  onPressed: () => _pickStartTime(context),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                  child: Text(
                      _startTime.format(context),
                      style: TextStyle(
                          color: Colors.white
                      )
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                    "Number of Hours:",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16
                    ),
                ),
                DropdownButton<int>(
                  value: _numHours,
                  onChanged: (int? newValue) {
                    setState(() {
                      _numHours = newValue!;
                    });
                  },
                  items: List.generate(6, (index) => index + 1)
                      .map<DropdownMenuItem<int>>(
                        (int value) => DropdownMenuItem<int>(
                      value: value,
                      child: Text(value.toString()),
                    ),
                  ).toList(),
                ),
              ],
            ),
            SizedBox(height: 80),
            ElevatedButton(
              onPressed: _generateClasses,
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Colors.blue[800]),
              ),
              child: Text(
                "Generate Events",
                style: TextStyle(color: Colors.white),
              ),
            ),
            SizedBox(height: 30,),
            ElevatedButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text("Confirmation"),
                      content: Text("Are you sure you want to delete ALL automation events?"),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: Text("Cancel"),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop(); // Cerrar el diálogo
                            _clearAutomatedClasses();
                          },
                          child: Text("Delete", style: TextStyle(color: Colors.red)),
                        ),
                      ],
                    );
                  },
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: Text(
                  "Clear Automated Events",
                  style: TextStyle(
                      color: Colors.white
                  ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
