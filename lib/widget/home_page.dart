import 'package:flutter/material.dart';
import 'package:proyecto_rr_principal/events.dart';
import 'package:proyecto_rr_principal/screens/NavigationBar/event_detail_screen.dart';
import 'package:proyecto_rr_principal/screens/NavigationBar/message_screen.dart';
import 'package:proyecto_rr_principal/screens/NavigationBar/search_screen.dart';
import 'package:proyecto_rr_principal/screens/NavigationBar/teacher_profile_screen.dart';
import 'package:proyecto_rr_principal/screens/NavigationBar/student_profile_screen.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    EventsController(),
    MessageScreen(),
    SearchScreen(),
    TeacherProfileScreen(),
    StudentProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    print('HomePage - initState: Página inicializada');
    print('HomePage - initState: Página inicial seleccionada: $_selectedIndex');
  }

  void _onItemTapped(int index) {
    print('HomePage - _onItemTapped: Tocaste el ícono con índice $index');
    setState(() {
      _selectedIndex = index;
      print('HomePage - _onItemTapped: Página cambiada a índice $_selectedIndex');
    });
  }

  @override
  Widget build(BuildContext context) {
    print('HomePage - build: Reconstruyendo la interfaz');
    print('HomePage - build: Página seleccionada: $_selectedIndex');

    return Scaffold(
      appBar: AppBar(
        title: Text('Home Page'),
        backgroundColor: Colors.white54,
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.event),
            label: 'Events',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.message),
            label: 'Messages',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Teacher Profile',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Student Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        backgroundColor: Colors.black,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white54,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}