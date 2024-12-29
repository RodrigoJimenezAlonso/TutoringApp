import 'package:flutter/material.dart';
//import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:provider/provider.dart';
import 'package:proyecto_rr_principal/auth/login_page.dart';
import 'providers/event_provider.dart';
import 'package:proyecto_rr_principal/mysql.dart';
import 'providers/user_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  //Stripe.publishableKey = 'pk_test_51Q3h3zP0TUOqrBT5Mu4ludEI8Nd3Wvfhprjx55suOFbbZT87NFIcKKznHqKqfnqhTcK9UotvqcXytQhFM250NcWL00Gz7EE6rE';
  try{
    final conn = await MySQLHelper.connect();
    print('MySql connected successfully');
    await conn.close();
  }
  catch(e){
    throw Exception('Could not connect to MYSQL: $e');
  }
  runApp(const MyApp());
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  //imporatr en el home el wallet screen
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
            create: (_)=> EventProvider(),
        ),
        ChangeNotifierProvider(
          create: (_)=> UserProvider(),
        )
      ],
      child: MaterialApp(
        title: 'date picker alert',
        theme: ThemeData(primarySwatch: Colors.blue),
        home: LoginPage(),
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



