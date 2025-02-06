import 'package:flutter/material.dart';
import 'package:proyecto_rr_principal/mysql.dart';
import 'package:proyecto_rr_principal/screens/teacher_list_screen.dart';


class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState()=> _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {

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
    return Scaffold(
      appBar: AppBar(title: Text('Search a Subject')),
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
                  fillColor: Colors.white,
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
                                  builder: (context)=> TeacherListScreen(subject:subject)
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
                            leading: Icon(Icons.menu_book, color: Colors.blue,),
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
}