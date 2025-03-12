import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:provider/provider.dart';
import 'package:proyecto_rr_principal/screens/NavigationBar/Events/events.dart';
import 'package:proyecto_rr_principal/screens/NavigationBar/chat/message_screen.dart';
import 'package:proyecto_rr_principal/screens/NavigationBar/Search/search_screen.dart';
import 'package:proyecto_rr_principal/screens/NavigationBar/Profiles/StudentProfile/student_profile_screen_personal.dart';
import 'package:proyecto_rr_principal/screens/NavigationBar/Profiles/teacherProfile/teacher_profile_screen_personal.dart';
import 'package:proyecto_rr_principal/screens/Settings/settings.dart';
import '../mysql.dart';

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
  String? userEmail; // No usamos un valor por defecto
  bool isLoading = true; // Indicador de carga

  @override
  void initState() {
    super.initState();
    fetchUserEmail();
  }

  Future<void> fetchUserEmail() async {
    try {
      final conn = await MySQLHelper.connect();
      final result = await conn.query(
        'SELECT email FROM users WHERE id = ?',
        [widget.userID],
      );
      await conn.close();

      if (result.isNotEmpty) {
        setState(() {
          userEmail = result.first['email']; // Asigna el correo correctamente
          isLoading = false; // Detiene la carga
        });
      } else {
        setState(() {
          isLoading = false; // Detiene la carga sin asignar un valor a `userEmail`
        });
      }
    } catch (e) {
      print('Error fetching user email: $e');
      setState(() {
        isLoading = false; // Detiene la carga en caso de error
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final SettingsProvider themeProvider = Provider.of<SettingsProvider>(context, listen: false);

    // Si aún está cargando, muestra un indicador de carga
    if (isLoading) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // Si `userEmail` sigue siendo `null`, muestra un mensaje de error en lugar de romper el código
    if (userEmail == null) {
      return Scaffold(
        body: Center(
          child: Text('Error: No se pudo obtener el email del usuario'),
        ),
      );
    }

    print('UserRole : ${widget.role}');

    final List<NavigationItem> navItems = widget.role.trim().toLowerCase() == 'teacher'
        ? [
      NavigationItem(label: 'Events', icon: Icons.event, page: EventsController()),
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
        page: SearchScreen(userEmail: userEmail!), // Aquí ya sabemos que `userEmail` no es null
      ),
      NavigationItem(
        label: 'Teacher Profile',
        icon: Icons.person,
        page: TeacherProfileScreenPersonal(userId: widget.userID),
      ),
    ]
        : [
      NavigationItem(label: 'Events', icon: Icons.event, page: EventsController()),
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
        page: SearchScreen(userEmail: userEmail!), // Aquí ya sabemos que `userEmail` no es null
      ),
      NavigationItem(
        label: 'Student Profile',
        icon: Icons.person,
        page: StudentProfileScreenPersonal(studentId: widget.alumnoId),
      ),
    ];

    final List<Widget> pages = navItems.map((item) => item.page).toList();

    return Scaffold(
      body: pages[_selectedIndex],
      bottomNavigationBar: CurvedNavigationBar(
        backgroundColor: themeProvider.isDarkMode == true ? Colors.grey[900] ?? Colors.grey : Colors.grey[100] ?? Colors.grey,
        color: themeProvider.isDarkMode == true ? Colors.black : Colors.blue[800] ?? Colors.grey,
        buttonBackgroundColor: themeProvider.isDarkMode == true ? Colors.black : Colors.blue[800],
        height: 70,
        items: navItems.asMap().entries.map((entry) {
          int index = entry.key;
          var item = entry.value;
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_selectedIndex != index) SizedBox(height: 20),
              Icon(
                item.icon,
                size: 30,
                color: Colors.white,
              ),
              if (_selectedIndex != index)
                Text(
                  item.label,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                  ),
                ),
            ],
          );
        }).toList(),
        index: _selectedIndex,
        animationDuration: Duration(milliseconds: 300),
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        letIndexChange: (index) => true,
        animationCurve: Curves.easeInOut,
      ),
    );
  }
}

class NavigationItem {
  final String label;
  final IconData icon;
  final Widget page;

  NavigationItem({
    required this.icon,
    required this.label,
    required this.page,
  });
}