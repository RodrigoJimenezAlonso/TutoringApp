import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:proyecto_rr_principal/auth/login_page.dart';
import 'package:proyecto_rr_principal/screens/Settings/theme_provider.dart';
import 'package:proyecto_rr_principal/widget/home_page.dart';
import 'providers/event_provider.dart';
import 'package:proyecto_rr_principal/mysql.dart';
import 'providers/user_provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/Settings/settings.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    final conn = await MySQLHelper.connect();
    print('MySQL conectado correctamente');
    await conn.close();
  } catch (e) {
    print('Error al conectar con MySQL: $e');
    throw Exception('Could not connect to MYSQL: $e');
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProxyProvider<UserProvider, EventProvider>(
          create: (context) => EventProvider(userProvider: Provider.of<UserProvider>(context, listen: false)),
          update: (context, userProvider, previous) => EventProvider(userProvider: userProvider),
        ),
        ChangeNotifierProvider(create: (context) => ThemeProvider()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settings, child) {
        return MaterialApp(
          title: 'Date Picker Alert',
          debugShowCheckedModeBanner: false,
          localizationsDelegates: [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: [
            const Locale('en', ''),
            const Locale('es', 'ES'),
          ],
          theme: settings.isDarkMode ? ThemeData.dark() : ThemeData.light(),
          home: LoginPage(),
        );
      },
    );
  }



  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    print("home: Estado de login desde SharedPreferences - $isLoggedIn");
    return prefs.containsKey('student_id');
  }
}
