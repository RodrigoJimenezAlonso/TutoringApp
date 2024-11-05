import 'package:flutter/material.dart';
import 'datePicker.dart'; // Replace with the correct path to your DatePicker file
import 'data.dart';

class EvtController extends StatefulWidget {
  @override
  _EvtControllerState createState() => _EvtControllerState();
}

class _EvtControllerState extends State<EvtController> {
  late Data data;

  @override
  void initState() {
    super.initState();
    data = Data();
    _fetchEvents();
  }

  Future<void> _fetchEvents()async{
    try{
      final events = await data.getAllEvents();
      print(events);
    }catch(e){
      print('error fetching events: $e');
    }
  }

  Future<Map<String, dynamic>?> _showEventDialog(BuildContext context) async {
    final TextEditingController titleController = TextEditingController();
    final TextEditingController descriptionController = TextEditingController();
    DateTime? selectedDate;

    return await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: Text('Add New Event'),
          contentPadding: EdgeInsets.all(20.0),
          children: [
            TextField(
              controller: titleController,
              decoration: InputDecoration(
                labelText: 'Title',
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: descriptionController,
              decoration: InputDecoration(
                labelText: 'Description',
              ),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              child: Text('Select Date & Time'),
              onPressed: () async {
                selectedDate = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => DatePicker()),
                );
              },
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  child: Text('Cancel'),
                  onPressed: () {
                    Navigator.pop(
                        context, null); // Close the dialog and return null
                  },
                ),
                SizedBox(width: 10),
                ElevatedButton(
                  child: Text('Add'),
                  onPressed: () {
                    if (titleController.text.isNotEmpty &&
                        descriptionController.text.isNotEmpty &&
                        selectedDate != null) {
                      final newEvent = {
                        "id": DateTime
                            .now()
                            .millisecondsSinceEpoch
                            .toString(),
                        "title": titleController.text,
                        "description": descriptionController.text,
                        "startTime": selectedDate!.toIso8601String(),
                        "endTime": DateTime.now().toIso8601String(),
                      };
                      Navigator.of(context).pop(newEvent);
                      Navigator.of(context).pop({
                        "id": DateTime
                            .now()
                            .millisecondsSinceEpoch
                            .toString(),
                        "title": titleController.text,
                        "description": descriptionController.text,
                        "startTime": selectedDate!.toIso8601String(),
                        "endTime": DateTime.now().toIso8601String(),
                      });
                    }
                  },
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  @override Widget build(BuildContext context) {
    return Center(
      child: ElevatedButton(
        onPressed: () async {
          final newEvent = await _showEventDialog(context);
          if(newEvent != null){
            await data.addEvent(newEvent);
            ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Event "${newEvent['title']}" added')),
            );
          }
        },
        child: Text('Create an Event'),
    ),
    );
  }
}