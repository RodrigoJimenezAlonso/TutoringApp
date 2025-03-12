import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:proyecto_rr_principal/ArtificialIntelligence/quiz_screen.dart';
import 'package:proyecto_rr_principal/mysql.dart';
import 'package:proyecto_rr_principal/screens/NavigationBar/Search/teacher_list_screen.dart';
import '../../../providers/user_provider.dart';
import 'create_subject.dart';
import 'package:proyecto_rr_principal/screens/Settings/settings.dart';



class SearchScreen extends StatefulWidget {
  final String userEmail;

  SearchScreen({
    required this.userEmail
});

  @override
  _SearchScreenState createState()=> _SearchScreenState();
}


class _SearchScreenState extends State<SearchScreen> {
  String? userRole;


  @override
  void initState() {
    super.initState();
    _getUserRole();
  }


  String query = '';
  final List<String> subjects = [
    'Mathematics',
    'English Language and Literature',
    'Science',
    'History',
    'Geography',
    'Physical Education (P.E.)',
    'Biology',
    'Chemistry',
    'Physics',
    'Art and Design',
    'Music',
    'Information and Communication Technology (ICT)',
    'Business Studies',
    'Foreign Languages',
    'Religious Education (R.E.)',
  ];

  Future<List<Map<String, dynamic>>> getTeachersBySubject(String subject) async {
    final conn = await MySQLHelper.connect();
    final result = await conn.query(
      'SELECT t.name, t.subject FROM teachers t WHERE t.subject LIKE ?',
      ['%$subject%'],
    );
    await conn.close();

    return result.map((row) => row.fields).toList();
  }

  @override
  Widget build(BuildContext context) {
    final SettingsProvider themeProvider = Provider.of<SettingsProvider>(context, listen: false);
    return Scaffold(
      backgroundColor: themeProvider.isDarkMode == true ? Colors.grey[800] : Colors.grey[100],
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: themeProvider.isDarkMode == true ? Colors.black : Colors.grey[100],
        centerTitle: true,
        title: Text('Search', style:
          TextStyle(
            color: themeProvider.isDarkMode == true ? Colors.white : Colors.black,
          ),
        ),
        actions: <Widget>[
          if(userRole == 'teacher')
            IconButton(
              icon: Icon(Icons.add),
              onPressed: () async {
                final selectedDate = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CreateSubjectScreen()),
                );
              },
            ),
        ],
      ),
      body: Column(
        children: [
          Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                onChanged: (value) {
                  setState(() {
                    query = value;
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Search a Subject...',
                  filled: true,
                  fillColor: themeProvider.isDarkMode == true ? Colors.grey[900] : Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: BorderSide.none,
                  ),
                  prefixIcon: Icon(Icons.search, color: Colors.blue,),
                  contentPadding: EdgeInsets.symmetric(
                    vertical: 14,
                  ),
                ),
              ),
          ),
          Expanded(
              child: ListView.builder(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16,
                  ),
                  itemCount: subjects.length,
                  itemBuilder: (context, index){
                    final subject = subjects[index];
                    if(query.isEmpty || subject.toLowerCase().contains(query.toLowerCase())){
                      return GestureDetector(
                        onTap: (){
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context)=> TeacherListScreen(subject:subject, userEmail: widget.userEmail,)
                              ),
                          );
                        },
                        child: Card(
                          margin: EdgeInsets.symmetric(
                            vertical: 8,
                          ),
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListTile(
                            leading: Icon(Icons.menu_book, color: themeProvider.isDarkMode == true ? Colors.white : Colors.blue[600],),
                            title: Text(
                              subject,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            trailing: Icon(Icons.arrow_forward_ios, color: Colors.grey,),

                          ),
                        ),
                      );
                    }
                    return SizedBox.shrink();
                  },

              ),
          ),
        ],
      ),
    );
  }
  Widget _buildSubjectList() {
    return ListView.builder(
        itemCount: subjects.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(subjects[index]),
            onTap: () {
              setState(() {
                query = subjects[index];
              });
            },
          );

        }
    );
  }

  Future<void> _getUserRole() async {
    try {
      final userId = Provider.of<UserProvider>(context, listen: false).userId;

      final conn = await MySQLHelper.connect();
      final result = await conn.query(
        'SELECT role FROM users WHERE id = ?',
        [userId], // 👈 Ahora usa el userId del Provider
      );

      if (result.isNotEmpty) {
        setState(() {
          userRole = result.first.fields['role'];
        });
      }

      await conn.close();
    } catch (e) {
      print("Error obteniendo el rol del usuario: $e");
    }
  }





}