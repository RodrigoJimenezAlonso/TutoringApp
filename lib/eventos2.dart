/*
import 'data.dart';
import 'package:flutter/material.dart';
import 'eventDialog.dart';
import 'meetingJitsi.dart';

class EventsController extends StatefulWidget {
  @override
  _EventsControllerState createState() => _EventsControllerState();
}

class _EventsControllerState extends State<EventsController> {
  late Data data;
  late Future<List<dynamic>> events;

  @override
  void initState() {
    super.initState();
    data = Data();
    events = data.getAllEvents();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Events'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () async {
              // Open the DatePicker and wait for the selected date and time
              final dynamic evt = await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => EvtController()),
              );

              // If a date was selected, do something with it
              if (evt != null) {
                // For example, add a new event with the selected date and time
                setState(() {
                  events = data.getAllEvents();
                });

                // Optionally, show a confirmation message
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text('New event created for $evt')),
                );
              }
            },
          ),
          IconButton(
          icon: Icon(Icons.add_a_photo),
          onPressed: () async {
          final meetJitsi mj = new meetJitsi();

          })
        ],
      ),
      body: FutureBuilder<List<dynamic>>(
        future: events,
        builder: (context, snapshot){
          if(snapshot.connectionState == ConnectionState.waiting){
            return Center(child: CircularProgressIndicator());
          }else if(snapshot.hasError){
            return Center(child: Text('error: ${snapshot.error}'));
          }else if(!snapshot.hasData || snapshot.data!.isEmpty){
            return Center(child: Text('no events found'));

          }else{
            return ListView.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index){
                  final event = snapshot.data![index];
                  return Card(
                    margin: EdgeInsets.all(10),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            event['title'],
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 10),
                          Text(
                            event['description'],
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                          SizedBox(height: 10),
                          Row(
                            children: [
                              Icon(Icons.schedule, color: Colors.grey),
                              SizedBox(width: 5),
                              Text(
                                'Start: ${event['startTime']}',
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                            ],
                          ),
                          SizedBox(height: 5),
                          Row(
                            children: [
                              Icon(Icons.schedule, color: Colors.grey),
                              SizedBox(width: 5),
                              Text(
                                'End: ${event['endTime']}',
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                            ],
                          ),
                          SizedBox(height: 10),
                          Row(
                            children: [
                              Icon(Icons.location_on, color: Colors.grey),
                              SizedBox(width: 5),
                              Text(
                                'Location: ${event['location']}',
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                });
          }
        },
      ),
    );
  }
}
*/
