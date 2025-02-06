import 'package:flutter/material.dart';
import 'package:proyecto_rr_principal/events.dart';
import 'package:proyecto_rr_principal/screens/NavigationBar/event_detail_screen.dart';
import 'package:proyecto_rr_principal/screens/NavigationBar/message_screen.dart';
import 'package:proyecto_rr_principal/screens/NavigationBar/search_screen.dart';
import 'package:proyecto_rr_principal/screens/NavigationBar/teacher_profile_screen_personal.dart';
import 'package:proyecto_rr_principal/screens/NavigationBar/student_profile_screen.dart';

class HomePage extends StatefulWidget {
  final int alumnoId;
  final int profesorId;
  final int userID;
  final String role;

  HomePage({
    required this.alumnoId,
    required this.profesorId,
    required this.userID,
    required this.role,
  });

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {

    print('UserRole : ${widget.role}');

    final List<NavigationItem> navItems = widget.role.trim().toLowerCase() == 'teacher'
        ? [
      NavigationItem(
        label: 'Events',
        icon: Icons.event,
        page: EventsController(),
      ),
      NavigationItem(
        label: 'Messages',
        icon: Icons.message,
        page: MessageScreen(
          userId: widget.alumnoId,
          role: widget.role,
          alumnoId: widget.alumnoId,
          professorId: widget.profesorId,
        ),
      ),
      NavigationItem(
        label: 'Search',
        icon: Icons.search,
        page: SearchScreen(),
      ),
      NavigationItem(
        label: 'Teacher Profile',
        icon: Icons.person,
        page: TeacherProfileScreenPersonal(
          userId: widget.userID,
        ),
      ),
    ]
        : [
      NavigationItem(
        label: 'Events',
        icon: Icons.event,
        page: EventsController(),
      ),
      NavigationItem(
        label: 'Messages',
        icon: Icons.message,
        page: MessageScreen(
          userId: widget.alumnoId,
          role: widget.role,
          alumnoId: widget.alumnoId,
          professorId: widget.profesorId,
        ),
      ),
      NavigationItem(
        label: 'Search',
        icon: Icons.search,
        page: SearchScreen(),
      ),
      NavigationItem(
        label: 'Student Profile',
        icon: Icons.person,
        page: StudentProfileScreen(studentId: widget.alumnoId,),
      ),
    ];

    final List<Widget> pages = navItems.map((item) => item.page).toList();

    final List<BottomNavigationBarItem> bottomNavItems = navItems
        .map(
          (item) => BottomNavigationBarItem(
        icon: Icon(item.icon),
        label: item.label,
      ),
    ).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('Home Page'),
        backgroundColor: Colors.white54,
      ),
      body: pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: bottomNavItems,
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        backgroundColor: Colors.black,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white54,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}

class NavigationItem{
  final String label;
  final IconData icon;
  final Widget page;

  NavigationItem({
    required this.icon,
    required this.label,
    required this.page,
  });

}