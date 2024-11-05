import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:provider/provider.dart';
import 'eventos2.dart';
import 'events.dart';
import 'providers/event_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';


void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://apoqmydfyxjevyxvymoz.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImFwb3FteWRmeXhqZXZ5eHZ5bW96Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3Mjg4MTM4MTYsImV4cCI6MjA0NDM4OTgxNn0.Lp9FyHD3x6pKZ2smdR1ycyQSiAMea5NVvtaraZaQlIc',
  );
  Stripe.publishableKey = 'pk_test_51Q3h3zP0TUOqrBT5Mu4ludEI8Nd3Wvfhprjx55suOFbbZT87NFIcKKznHqKqfnqhTcK9UotvqcXytQhFM250NcWL00Gz7EE6rE';
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  //imporatr en el home el wallet screen
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_)=> EventProvider(),
      child: MaterialApp(
        title: 'date picker alert',
        theme: ThemeData(primarySwatch: Colors.blue),
        home: EventsController(),
      ),
    );


    /*Scaffold(
        appBar: AppBar(
          title: Text('Date Picker Alert'),
        ),
        body: EventsController(),*/
    //),
  }
}



